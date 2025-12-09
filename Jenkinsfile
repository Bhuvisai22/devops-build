pipeline {
  agent any

  environment {
    // credential IDs in Jenkins
    DOCKERHUB_CRED = 'dockerhub-creds'    
    GITHUB_CRED    = 'github-creds'       
    REGISTRY_DEV   = '$saidoc540/dev'   
    REGISTRY_PROD  = '$saidoc540/prod' 
  
    SHORT_COMMIT = "${env.GIT_COMMIT?.take(8)}"
  }

  options {
    // keep a reasonable number of builds
    buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '5'))
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          // ensure GIT_COMMIT is available
          env.GIT_COMMIT = sh(script: 'git rev-parse --verify HEAD', returnStdout: true).trim()
        }
      }
    }

    stage('Build & Unit Tests') {
      steps {
        // run your project's build and tests
        sh '''
           echo "Run build and unit tests here"
           # example for maven: mvn -B clean package
           # example for node: npm ci && npm test
        '''
      }
    }

   stage('Push Docker Image') {
  steps {
    script {
      withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'

        def branch = env.BRANCH_NAME ?: (env.GIT_BRANCH ?: 'unknown').replaceAll('origin/', '')
        // Ensure registry variables are set correctly (no leading slash)
        if (!env.REGISTRY_DEV) {
          error "REGISTRY_DEV not set. Please set env.REGISTRY_DEV to <dockerhub-user>/<repo>-dev"
        }
        if (!env.REGISTRY_PROD) {
          error "REGISTRY_PROD not set. Please set env.REGISTRY_PROD to <dockerhub-user>/<repo>-prod"
        }

        // compute destination and push only for dev/master
        if (branch == 'dev') {
          def dest = "${env.REGISTRY_DEV}:${env.IMAGE_TAG}"
          sh """
            docker tag temp-image:${env.IMAGE_TAG} ${dest}
            docker push ${dest}
            docker tag temp-image:${env.IMAGE_TAG} ${env.REGISTRY_DEV}:latest-dev
            docker push ${env.REGISTRY_DEV}:latest-dev
          """
        } else if (branch == 'master' || branch == 'main') {
          def dest = "${env.REGISTRY_PROD}:${env.IMAGE_TAG}"
          sh """
            docker tag temp-image:${env.IMAGE_TAG} ${dest}
            docker push ${dest}
            docker tag temp-image:${env.IMAGE_TAG} ${env.REGISTRY_PROD}:latest
            docker push ${env.REGISTRY_PROD}:latest
          """
        } else {
          echo "Branch ${branch} - skipping push (only dev/master push to dockerhub)"
        }

        sh "docker logout"
      }
    }
  }
}


    stage('Deploy (optional)') {
      when {
        anyOf {
          branch 'dev'
          branch 'master'
        }
      }
      steps {
        script {
          def branch = env.BRANCH_NAME ?: (env.GIT_BRANCH ?: 'unknown').replaceAll('origin/', '')
          if (branch == 'dev') {
            echo "Triggering dev deployment"
            // example: kubectl set image or helm upgrade
            // sh "kubectl --kubeconfig=/path/to/kubeconfig set image deployment/myapp myapp=${REGISTRY_DEV}:${env.IMAGE_TAG}"
          } else if (branch == 'master' || branch == 'main') {
            echo "Triggering prod deployment"
            // sh "kubectl --kubeconfig=/path/to/kubeconfig set image deployment/myapp myapp=${REGISTRY_PROD}:${env.IMAGE_TAG}"
          }
        }
      }
    }
  }

  post {
    success {
      echo "Build, push & (optional) deploy succeeded."
      // optionally notify Slack/email
    }
    failure {
      echo "Build failed."
    }
    always {
      // cleanup local image
      sh 'docker rmi temp-image:${IMAGE_TAG} || true'
    }
  }
}


