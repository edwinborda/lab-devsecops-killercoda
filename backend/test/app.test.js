const { test, before, after } = require('node:test')
const assert = require('node:assert')
const { app } = require('../src/app')

let server
let base

before(async () => {
  server = app.listen(0)
  await new Promise(r => server.once('listening', r))
  base = `http://127.0.0.1:${server.address().port}`
})

after(() => server.close())

test('GET /api/health responde ok', async () => {
  const res = await fetch(`${base}/api/health`)
  assert.strictEqual(res.status, 200)
  const body = await res.json()
  assert.strictEqual(body.status, 'ok')
})

test('GET /api/tasks devuelve la lista inicial', async () => {
  const res = await fetch(`${base}/api/tasks`)
  const body = await res.json()
  assert.ok(Array.isArray(body))
  assert.ok(body.length >= 3)
})

test('POST /api/tasks crea una tarea', async () => {
  const res = await fetch(`${base}/api/tasks`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ title: 'Desplegar en Kubernetes' })
  })
  assert.strictEqual(res.status, 201)
  const body = await res.json()
  assert.strictEqual(body.title, 'Desplegar en Kubernetes')
})

test('POST /api/tasks sin título responde 400', async () => {
  const res = await fetch(`${base}/api/tasks`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
  })
  assert.strictEqual(res.status, 400)
})

test('GET /metrics expone métricas Prometheus', async () => {
  const res = await fetch(`${base}/metrics`)
  const text = await res.text()
  assert.match(text, /http_requests_total/)
})
