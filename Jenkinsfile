pipeline {
    agent any

    environment {
        // Docker image name base
        DOCKERHUB_USERNAME = 'saidoc540'
        APP_NAME = 'my-app'  // Change to your app name
        AWS_REGION = 'us-east-1'  // Adjust as needed
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Determine target repo based on branch
                    if (env.BRANCH_NAME == 'dev') {
                        env.DOCKER_REPO = "${DOCKERHUB_USERNAME}/${APP_NAME}-dev"
                    } else if (env.BRANCH_NAME == 'master') {
                        env.DOCKER_REPO = "${DOCKERHUB_USERNAME}/${APP_NAME}-prod"
                    } else {
                        error "Deployment only allowed from 'dev' or 'master' branches"
                    }

                    // Build image with tag
                    sh "docker build -t ${env.DOCKER_REPO}:${env.BUILD_NUMBER} ."
                    sh "docker tag ${env.DOCKER_REPO}:${env.BUILD_NUMBER} ${env.DOCKER_REPO}:latest"
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${env.DOCKER_REPO}:${env.BUILD_NUMBER}
                            docker push ${env.DOCKER_REPO}:latest
                            docker logout
                        """
                    }
                }
            }
        }

        stage('Deploy to AWS') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        sh 'echo "Deploying DEV version to AWS..."'
                        // Example: Update ECS dev service
                        // aws ecs update-service --cluster dev-cluster --service my-app-dev-service --force-new-deployment --region ${AWS_REGION}
                    } else if (env.BRANCH_NAME == 'master') {
                        sh 'echo "Deploying PROD version to AWS..."'
                        // Example: Update ECS prod service
                        // aws ecs update-service --cluster prod-cluster --service my-app-prod-service --force-new-deployment --region ${AWS_REGION}
                    }

                    // 🔧 Replace above with your actual deployment commands:
                    // - ECS task definition update + service reload
                    // - Or EC2 script (e.g., pull image + restart container)
                    // - Or use AWS CodeDeploy, etc.
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
