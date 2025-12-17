pipeline {
    agent any

    environment {
        // Docker image name base
        DOCKERHUB_USERNAME = 'saidoc540'
        APP_NAME = 'react-app'  // Change to your app name
        AWS_REGION = 'ap-south-1'  // Adjust as needed
        BRANCH_NAME = ''  // Will be populated in Checkout stage
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                    // Manually capture current branch name
                    env.BRANCH_NAME = sh(
                        script: 'git rev-parse --abbrev-ref HEAD',
                        returnStdout: true
                    ).trim()
                    echo "_Checked out branch: ${env.BRANCH_NAME}_"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Determine target repo based on branch
                    if (env.BRANCH_NAME == 'dev') {
                        env.DOCKER_REPO = "${DOCKERHUB_USERNAME}/${APP_NAME}-dev"
                    } else if (env.BRANCH_NAME == 'main') {
                        env.DOCKER_REPO = "${DOCKERHUB_USERNAME}/${APP_NAME}-prod"
                    } else {
                        error "Deployment only allowed from 'dev' or 'main' branches"
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
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
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
                        // Example for dev environment (ECS)
                        // withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        //     sh "aws ecs update-service --cluster react-dev-cluster --service react-app-dev --force-new-deployment --region ${AWS_REGION}"
                        // }
                    } else if (env.BRANCH_NAME == 'main') {
                        sh 'echo "Deploying PROD version to AWS..."'
                        // Example for prod environment (ECS)
                        // withCredentials([usernamePassword(credentialsId: 'aws-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        //     sh "aws ecs update-service --cluster react-prod-cluster --service react-app-prod --force-new-deployment --region ${AWS_REGION}"
                        // }
                    }
                    // 🔧 Uncomment and customize the AWS commands above when ready
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
