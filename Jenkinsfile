pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'saidoc540'
        APP_NAME           = 'react-app'
        DEV_IMAGE          = "${DOCKERHUB_USERNAME}/dev"
        PROD_IMAGE         = "${DOCKERHUB_USERNAME}/prod"
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
                    def tag = env.BUILD_NUMBER

                    if (env.BRANCH_NAME == 'dev') {
                        echo "Building Docker image for DEV branch..."
                        sh "docker build -t ${DEV_IMAGE}:${tag} ."
                    } else if (env.BRANCH_NAME == 'prod') {
                        echo "Building Docker image for PROD branch..."
                        sh "docker build -t ${PROD_IMAGE}:${tag} ."
                    } else {
                        error("Unsupported branch: ${env.BRANCH_NAME}. Only 'dev' and 'prod' allowed.")
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        if (env.BRANCH_NAME == 'dev') {
                            echo "Pushing to Docker Hub: ${DEV_IMAGE}:${env.BUILD_NUMBER}"
                            sh "docker push ${DEV_IMAGE}:${env.BUILD_NUMBER}"
                            // Optional: update 'latest' tag
                            sh "docker tag ${DEV_IMAGE}:${env.BUILD_NUMBER} ${DEV_IMAGE}:latest"
                            sh "docker push ${DEV_IMAGE}:latest"
                        } else if (env.BRANCH_NAME == 'prod') {
                            echo "Pushing to Docker Hub: ${PROD_IMAGE}:${env.BUILD_NUMBER}"
                            sh "docker push ${PROD_IMAGE}:${env.BUILD_NUMBER}"
                            // Optional: update 'latest' tag
                            sh "docker tag ${PROD_IMAGE}:${env.BUILD_NUMBER} ${PROD_IMAGE}:latest"
                            sh "docker push ${PROD_IMAGE}:latest"
                        }
                    }
                }
            }
        }

        stage('Deploy (Optional)') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        echo "Deploying to DEV environment..."
                        // Example: sh 'kubectl --context=dev apply -f k8s/dev/'
                    } else if (env.BRANCH_NAME == 'prod') {
                        echo "Deploying to PROD environment..."
                        // Example: sh 'kubectl --context=prod apply -f k8s/prod/'
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "❌ Pipeline failed for branch: ${env.BRANCH_NAME}"
        }
    }
}
