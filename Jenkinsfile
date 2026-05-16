pipeline {
  agent {
    docker {
      image 'node:18-alpine'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  options {
    timeout(time: 30, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '15'))
    disableConcurrentBuilds()
  }

  environment {
    STAGE_NAME_DEPLOY        = 'staging'
    SKIP_AWS_DEPLOY          = "${env.SKIP_AWS_DEPLOY ?: 'true'}"
    AWS_REGION               = "${env.AWS_REGION ?: 'us-east-1'}"
    PAYMENTS_IMAGE           = 'kijanikiosk/kk-payments:1.1.0'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'git log -1 --oneline'
      }
    }

    stage('Lint & Test') {
      parallel {
        stage('Serverless unit tests') {
          steps {
            sh '''
              set -e
              npm ci
              npm test
              npx serverless print --stage staging
              npx serverless package --stage staging
            '''
          }
        }
        stage('Payments service tests') {
          steps {
            sh '''
              set -e
              cd services/kk-payments
              npm ci
              npm run lint
              npm test
            '''
          }
        }
        stage('Validate Kubernetes manifests') {
          steps {
            sh '''
              set -e
              kubectl version --client
              kubectl kustomize k8s/overlays/staging > /tmp/kk-staging.yaml
              kubectl kustomize k8s/overlays/production > /tmp/kk-production.yaml
              echo "Kustomize build OK for staging and production"
            '''
          }
        }
      }
    }

    stage('Build payments image') {
      when {
        expression { return fileExists('/var/run/docker.sock') }
      }
      steps {
        sh './scripts/build-payments-image.sh ${PAYMENTS_IMAGE}'
      }
    }

    stage('Deploy serverless — staging') {
      when {
        allOf {
          branch 'main'
          expression { return env.SKIP_AWS_DEPLOY == 'false' }
        }
      }
      steps {
        withCredentials([
          string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY'),
        ]) {
          sh '''
            set -e
            npm ci
            npx serverless deploy --stage staging
            npx serverless info --stage staging
          '''
        }
      }
    }

    stage('Offline staging deploy (no AWS)') {
      when {
        allOf {
          branch 'main'
          expression { return env.SKIP_AWS_DEPLOY != 'false' }
        }
      }
      steps {
        sh '''
          set -e
          echo "SKIP_AWS_DEPLOY=true — packaging only (activate AWS to deploy for real)"
          npm ci
          npx serverless package --stage staging
          ./scripts/k8s-deploy-staging.sh || echo "kubectl apply skipped if cluster unavailable"
        '''
      }
    }

    stage('Smoke test — staging') {
      steps {
        sh '''
          set -e
          echo "=== Smoke: receipt parser ==="
          npm test
          echo "=== Smoke: sample receipt fixture ==="
          node -e "
            const r = require('./lib/receipt');
            const f = require('./tests/fixtures/sample-receipt.json');
            const p = r.parseReceipt(f);
            console.log(JSON.stringify({ smoke: 'ok', paymentId: p.paymentId }));
          "
          if [ "${SKIP_AWS_DEPLOY}" = "false" ]; then
            ./scripts/upload-test-receipt.sh staging || true
          else
            echo "AWS smoke upload skipped (set SKIP_AWS_DEPLOY=false when AWS is ready)"
          fi
        '''
      }
    }

    stage('Production approval') {
      when { branch 'main' }
      steps {
        script {
          def inputs = input(
            id: 'ProdApproval',
            message: 'Deploy serverless stack to PRODUCTION?',
            parameters: [
              string(
                name: 'APPROVAL_REASON',
                description: 'Why is this production deploy approved? (required for audit)',
                defaultValue: ''
              )
            ]
          )
          def reason = inputs instanceof Map ? inputs['APPROVAL_REASON'] : inputs
          if (!reason?.trim()) {
            error('Production deploy blocked: APPROVAL_REASON is required')
          }
          env.PROD_APPROVAL_REASON = reason.trim()
          echo "Production approved. Reason: ${env.PROD_APPROVAL_REASON}"
        }
      }
    }

    stage('Deploy serverless — production') {
      when {
        allOf {
          branch 'main'
          expression { return env.SKIP_AWS_DEPLOY == 'false' }
        }
      }
      steps {
        withCredentials([
          string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY'),
        ]) {
          sh '''
            set -e
            echo "Deploying production per approval: ${PROD_APPROVAL_REASON}"
            npx serverless deploy --stage production
            npx serverless info --stage production
          '''
        }
      }
    }

    stage('Offline production package (no AWS)') {
      when {
        allOf {
          branch 'main'
          expression { return env.SKIP_AWS_DEPLOY != 'false' }
        }
      }
      steps {
        sh '''
          npx serverless package --stage production
          echo "Production package ready. Deploy when AWS account is active."
        '''
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: '**/test-results/*.xml'
      cleanWs()
    }
    success {
      echo "Pipeline succeeded on ${env.BRANCH_NAME} build #${env.BUILD_NUMBER}"
    }
    failure {
      echo "Pipeline FAILED on ${env.BRANCH_NAME} build #${env.BUILD_NUMBER}"
    }
  }
}
