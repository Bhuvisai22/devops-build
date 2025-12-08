pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'saidoc540'
        APP_NAME           = 'my-app'
        DEV_IMAGE          = "${DOCKERHUB_USERNAME}/${APP_NAME}-dev"
        PROD_IMAGE         = "${DOCKERHUB_USERNAME}/${APP_NAME}-prod"
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
                        echo "Skipping build: only 'dev' and 'prod' branches are supported."
                        currentBuild.result = 'ABORTED'
                        error("Unsupported branch: ${env.BRANCH_NAME}")
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    def tag = env.BUILD_NUMBER

                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        if (env.BRANCH_NAME == 'dev') {
                            echo "Pushing to Docker Hub: ${DEV_IMAGE}:${tag}"
                            sh "docker push ${DEV_IMAGE}:${tag}"
                            // Optional: update 'latest' tag for dev
                            sh "docker tag ${DEV_IMAGE}:${tag} ${DEV_IMAGE}:latest"
                            sh "docker push ${DEV_IMAGE}:latest"
                        } else if (env.BRANCH_NAME == 'prod') {
                            echo "Pushing to Docker Hub: ${PROD_IMAGE}:${tag}"
                            sh "docker push ${PROD_IMAGE}:${tag}"
                            // Optional: update 'latest' for prod (use cautiously!)
                            sh "docker tag ${PROD_IMAGE}:${tag} ${PROD_IMAGE}:latest"
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
                        // Example: kubectl --context=dev apply -f k8s/dev/
                        // Or docker-compose -f docker-compose.dev.yml up -d
                    } else if (env.BRANCH_NAME == 'prod') {
                        echo "Deploying to PROD environment..."
                        // Example: kubectl --context=prod apply -f k8s/prod/
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "Pipeline failed for branch: ${env.BRANCH_NAME}"
        }
    }
}
