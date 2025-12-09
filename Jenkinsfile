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

    stage('Build Docker Image') {
      steps {
        script {
          // compute image name and tag based on branch
          def branch = env.BRANCH_NAME ?: (env.GIT_BRANCH ?: 'unknown').replaceAll('origin/', '')
          def imgTag = "${branch}-${env.SHORT_COMMIT}-${env.BUILD_NUMBER}"
          env.IMAGE_TAG = imgTag
          echo "Branch: ${branch}  Image tag: ${imgTag}"

          // Build using docker CLI (docker pipeline alternative also available)
          sh "docker build -t temp-image:${imgTag} ."
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          // login to Docker Hub, then tag & push to the correct repo
          withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh '''
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            '''

            def branch = env.BRANCH_NAME ?: (env.GIT_BRANCH ?: 'unknown').replaceAll('origin/', '')
            if (branch == 'dev') {
              sh """
                docker tag temp-image:${env.IMAGE_TAG} ${REGISTRY_DEV}:${env.IMAGE_TAG}
                docker push ${REGISTRY_DEV}:${env.IMAGE_TAG}
                docker tag temp-image:${env.IMAGE_TAG} ${REGISTRY_DEV}:latest-dev
                docker push ${REGISTRY_DEV}:latest-dev
              """
            } else if (branch == 'master' || branch == 'main') {
              // prod push
              sh """
                docker tag temp-image:${env.IMAGE_TAG} ${REGISTRY_PROD}:${env.IMAGE_TAG}
                docker push ${REGISTRY_PROD}:${env.IMAGE_TAG}
                # optional semantic tag: latest for production
                docker tag temp-image:${env.IMAGE_TAG} ${REGISTRY_PROD}:latest
                docker push ${REGISTRY_PROD}:latest
              """
            } else {
              // for feature branches, you may choose to push to a dev repo or skip push
              echo "Branch ${branch} - not pushing to Docker Hub (only dev and master are pushed by policy)"
            }

            // logout
            sh "docker logout"
          } // withCredentials
        } // script
      } // steps
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

