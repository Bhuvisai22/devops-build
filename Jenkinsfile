pipeline {
    agent any

    environment {
        IMAGE_NAME = "react-app"
        TAG = "latest"                          // you can change this
        DOCKERHUB_CREDENTIALS = "dockerhub-cred" // Jenkins credential ID

        // EC2 details
        EC2_HOST = "13.203.213.54"
        EC2_USER = "ubuntu"
        SSH_CREDENTIALS = "ec2-ssh-key"         // Jenkins SSH credential ID
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Bhuvisai22/devops-build.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                      docker build -t ${IMAGE_NAME}:${TAG} .
                    """
                }
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKERHUB_CREDENTIALS,
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                      echo "Logging into DockerHub..."
                      echo "$PASS" | docker login -u "$USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                      docker push ${IMAGE_NAME}:${TAG}
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    sshagent(credentials: [env.SSH_CREDENTIALS]) {
                        sh """
                          ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                            set -e

                            echo "Pulling latest image ${IMAGE_NAME}:${TAG}..."
                            docker pull ${IMAGE_NAME}:${TAG}

                            echo "Stopping old container (if any)..."
                            docker stop react-app || true
                            docker rm react-app || true

                            echo "Starting new container..."
                            docker run -d --name react-appcontainer -p 80:80 ${IMAGE_NAME}:${TAG}

                            echo "Deployment completed on EC2"
                          '
                        """
                    }
                }
            }
        }
    }
}

