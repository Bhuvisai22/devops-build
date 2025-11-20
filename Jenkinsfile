pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')     // Username + Password
        AWS_CREDENTIALS       = credentials('aws-creds')            // Access key + Secret
        AWS_REGION            = 'ap-south-1'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                script {
                    env.BRANCH = sh(script: "echo ${GIT_BRANCH} | sed 's|origin/||'", returnStdout: true).trim()
                    echo "Building for branch: ${env.BRANCH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    if (env.BRANCH == 'dev') {
                        env.IMAGE = "${DOCKERHUB_CREDENTIALS_USR}/dev:${BUILD_NUMBER}"
                    } else if (env.BRANCH == 'master') {
                        env.IMAGE = "${DOCKERHUB_CREDENTIALS_USR}/prod:${BUILD_NUMBER}"
                    } else {
                        error "Unsupported branch: ${env.BRANCH}"
                    }
                }

                sh """
                    echo "Building Docker image: ${env.IMAGE}"
                    docker build -t ${env.IMAGE} .
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh """
                    echo "Login to DockerHub..."
                    docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW}

                    echo "Pushing image..."
                    docker push ${env.IMAGE}
                """
            }
        }

        stage('Deploy to AWS EC2') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'master'
                }
            }
            steps {
                sh """
                    export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
                    export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
                    export AWS_DEFAULT_REGION=${AWS_REGION}

                    ssh -o StrictHostKeyChecking=no ec2-user@YOUR_EC2_PUBLIC_IP << EOF
                        docker stop app || true
                        docker rm app || true

                        echo "Pulling latest image..."
                        docker pull ${env.IMAGE}

                        echo "Starting container..."
                        docker run -d --name app -p 80:80 ${env.IMAGE}
                    EOF
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully."
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
