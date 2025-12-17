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
                    echo "Building branch: ${env.BRANCH_NAME}"  // ✅ Auto-set by Multibranch

                    if (env.BRANCH_NAME == 'dev') {
                        env.DOCKER_REPO = "${DOCKERHUB_USERNAME}/${APP_NAME}-dev"
                    } else if (env.BRANCH_NAME == 'main') {
                        env.DOCKER_REPO = "${DOCKERHUB_USERNAME}/${APP_NAME}-prod"
                    } else {
                        currentBuild.result = 'ABORTED'
                        error "Only 'dev' and 'main' branches are allowed"
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
                            sh 'echo "Deploying DEV to AWS..."'
                            // Add real AWS dev deploy command
                        } else if (env.BRANCH_NAME == 'main') {
                            sh 'echo "Deploying PROD to AWS..."'
                            // Add real AWS prod deploy command
                        }
                    }
                }
            }
        }
    }

    post {
        success { echo "✅ Success on branch ${env.BRANCH_NAME}" }
        failure { echo "❌ Failed on branch ${env.BRANCH_NAME}" }
    }
}
