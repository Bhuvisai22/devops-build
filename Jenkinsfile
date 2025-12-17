pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'saidoc540'
        APP_NAME = 'react-app'
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Automatically set by Multibranch Pipeline
                    echo "Running pipeline for branch: ${env.BRANCH_NAME}"

                    // Allow only dev and main
                    if (env.BRANCH_NAME == 'dev') {
                        env.DOCKER_REPO = "${DOCKERHUB_USERNAME}/${APP_NAME}-dev"
                    } else if (env.BRANCH_NAME == 'main') {
                        env.DOCKER_REPO = "${DOCKERHUB_USERNAME}/${APP_NAME}-prod"
                    } else {
                        echo "Skipping build for branch: ${env.BRANCH_NAME}"
                        currentBuild.result = 'ABORTED'
                        error "Only 'dev' and 'main' branches are allowed for deployment"
                    }

                    sh "docker build -t ${env.DOCKER_REPO}:${env.BUILD_NUMBER} ."
                    sh "docker tag ${env.DOCKER_REPO}:${env.BUILD_NUMBER} ${env.DOCKER_REPO}:latest"
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                        docker push ${env.DOCKER_REPO}:${env.BUILD_NUMBER}
                        docker push ${env.DOCKER_REPO}:latest
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to AWS') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds',
                    usernameVariable: 'AWS_ACCESS_KEY_ID',
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    script {
                        if (env.BRANCH_NAME == 'dev') {
                            sh '''
                                echo "🚀 Deploying DEV to AWS (ap-south-1)..."
                                export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                                export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                                export AWS_DEFAULT_REGION=ap-south-1
                                # aws ecs update-service --cluster react-dev --service react-app-dev --force-new-deployment
                            '''
                        } else if (env.BRANCH_NAME == 'main') {
                            sh '''
                                echo "🚀 Deploying PROD to AWS (ap-south-1)..."
                                export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                                export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                                export AWS_DEFAULT_REGION=ap-south-1
                                # aws ecs update-service --cluster react-prod --service react-app-prod --force-new-deployment
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        success { echo "✅ ${env.BRANCH_NAME} pipeline succeeded!" }
        failure { echo "❌ ${env.BRANCH_NAME} pipeline failed!" }
        aborted { echo "⚠️ ${env.BRANCH_NAME} pipeline was skipped/aborted." }
    }
}
