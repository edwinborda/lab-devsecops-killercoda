// Pipeline CD — Jenkins
// Requisitos en el agente: Docker, Trivy, kubectl con acceso al cluster.
// Credenciales en Jenkins: 'dockerhub-creds' (usuario/token) y 'sonar-token' (secret text).
pipeline {
  agent any

  environment {
    REGISTRY      = 'docker.io/TU_USUARIO'
    VERSION       = "1.0.${BUILD_NUMBER}"
    BACKEND_IMG   = "${REGISTRY}/tasks-backend:${VERSION}"
    FRONTEND_IMG  = "${REGISTRY}/tasks-frontend:${VERSION}"
    SONAR_HOST    = 'http://sonarqube:9000'
  }

  options {
    timestamps()
    timeout(time: 30, unit: 'MINUTES')
  }

  stages {

    stage('Clonar repositorio') {
      steps {
        checkout scm
      }
    }

    stage('Pruebas unitarias') {
      steps {
        dir('backend') {
          sh 'npm ci && npm test'
        }
      }
    }

    stage('Análisis estático — SonarQube') {
      steps {
        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
          sh '''
            docker run --rm -v "$PWD:/usr/src" \
              -e SONAR_HOST_URL=$SONAR_HOST -e SONAR_TOKEN=$SONAR_TOKEN \
              sonarsource/sonar-scanner-cli:11
          '''
        }
      }
    }

    stage('Construir imágenes Docker') {
      parallel {
        stage('Backend')  { steps { sh "docker build -t ${BACKEND_IMG} backend/" } }
        stage('Frontend') { steps { sh "docker build -t ${FRONTEND_IMG} frontend/" } }
      }
    }

    stage('Escaneo de imágenes — Trivy') {
      steps {
        sh "trivy image --severity HIGH,CRITICAL --format table --output trivy-backend.txt ${BACKEND_IMG}"
        sh "trivy image --severity HIGH,CRITICAL --format table --output trivy-frontend.txt ${FRONTEND_IMG}"
        // Quality gate: detiene el pipeline si hay vulnerabilidades CRITICAL con solución disponible
        sh "trivy image --severity CRITICAL --ignore-unfixed --exit-code 1 ${BACKEND_IMG}"
      }
      post {
        always { archiveArtifacts artifacts: 'trivy-*.txt', allowEmptyArchive: true }
      }
    }

    stage('Publicar en el registro') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'REG_USER',
                                          passwordVariable: 'REG_PASS')]) {
          sh 'echo "$REG_PASS" | docker login -u "$REG_USER" --password-stdin'
          sh "docker push ${BACKEND_IMG}"
          sh "docker push ${FRONTEND_IMG}"
        }
      }
    }

    stage('Desplegar en Kubernetes') {
      steps {
        sh '''
          kubectl apply -f k8s/00-namespace.yaml
          kubectl apply -f k8s/10-backend.yaml -f k8s/20-frontend.yaml
          kubectl -n tareas set image deploy/backend  backend=$BACKEND_IMG
          kubectl -n tareas set image deploy/frontend frontend=$FRONTEND_IMG
          kubectl -n tareas rollout status deploy/backend  --timeout=120s
          kubectl -n tareas rollout status deploy/frontend --timeout=120s
        '''
      }
    }

    stage('Smoke test') {
      steps {
        sh 'kubectl -n tareas run smoke --rm -i --restart=Never --image=curlimages/curl -- curl -sf http://frontend/api/health'
      }
    }
  }

  post {
    failure {
      sh 'kubectl -n tareas rollout undo deploy/backend  || true'
      sh 'kubectl -n tareas rollout undo deploy/frontend || true'
    }
  }
}
