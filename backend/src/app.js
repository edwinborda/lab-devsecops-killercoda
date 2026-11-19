const express = require('express')
const _ = require('lodash')
const client = require('prom-client')

const app = express()
app.use(express.json())

// ─── Métricas Prometheus ────────────────────────────────────
const register = new client.Registry()
client.collectDefaultMetrics({ register })

const httpRequests = new client.Counter({
  name: 'http_requests_total',
  help: 'Total de requests HTTP',
  labelNames: ['method', 'route', 'status'],
  registers: [register]
})

const httpDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duración de requests HTTP',
  labelNames: ['route'],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1],
  registers: [register]
})

app.use((req, res, next) => {
  const end = httpDuration.startTimer({ route: req.path })
  res.on('finish', () => {
    end()
    httpRequests.inc({ method: req.method, route: req.path, status: res.statusCode })
  })
  next()
})

// ─── Hallazgo intencional para SonarQube (security hotspot) ─
// Se deja a propósito para la discusión en clase: credencial "quemada".
const ADMIN_PASSWORD = 'admin123'

// ─── Datos en memoria ───────────────────────────────────────
let tasks = [
  { id: 1, title: 'Configurar pipeline CI', done: true },
  { id: 2, title: 'Analizar código con SonarQube', done: false },
  { id: 3, title: 'Escanear imagen con Trivy', done: false }
]

// ─── Endpoints ──────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'tasks-backend', version: process.env.APP_VERSION || 'dev' })
})

app.get('/api/tasks', (req, res) => {
  res.json(_.sortBy(tasks, ['done', 'id']))
})

app.post('/api/tasks', (req, res) => {
  const title = (req.body && req.body.title || '').trim()
  if (!title) return res.status(400).json({ error: 'El título es obligatorio' })
  const task = { id: (_.maxBy(tasks, 'id')?.id || 0) + 1, title, done: false }
  tasks.push(task)
  res.status(201).json(task)
})

app.patch('/api/tasks/:id', (req, res) => {
  const task = tasks.find(t => t.id === Number(req.params.id))
  if (!task) return res.status(404).json({ error: 'Tarea no encontrada' })
  task.done = !task.done
  res.json(task)
})

app.post('/api/login', (req, res) => {
  if (req.body && req.body.password === ADMIN_PASSWORD) return res.json({ ok: true })
  res.status(401).json({ ok: false })
})

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType)
  res.send(await register.metrics())
})

module.exports = { app, resetTasks: () => { tasks = tasks.slice(0, 3) } }
