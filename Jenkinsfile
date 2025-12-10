pipeline {
    agent any

    environment {
        GIT_REPO = "https://github.com/Bhuvisai22/devops-build.git"
        DEV_REPO = "saidoc540/dev"
        PROD_REPO = "saidoc540/prod"

        DOCKERHUB_CRED = "dockerhub-cred"
        GITHUB_CRED = "github-cred"
        EC2_SSH_CRED = "ec2-ssh-cred"
        EC2_HOST = "ec2-xx-xx-xx-xx.compute.amazonaws.com"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    userRemoteConfigs: [[
                        url: "${GIT_REPO}",
                        credentialsId: "${GITHUB_CRED}"
                    ]],
                    branches: [[name: "*/${BRANCH_NAME}"]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    IMAGE_TAG = "${BRANCH_NAME}-${BUILD_NUMBER}"

                    if (BRANCH_NAME == "dev") {
                        IMAGE_NAME = "${DEV_REPO}:${IMAGE_TAG}"
                    } else if (BRANCH_NAME == "master") {
                        IMAGE_NAME = "${PROD_REPO}:${IMAGE_TAG}"
                    }

                    echo "Building image: ${IMAGE_NAME}"

                    dockerImage = docker.build(IMAGE_NAME)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing image to DockerHub..."

                    docker.withRegistry('https://registry.hub.docker.com', "${DOCKERHUB_CRED}") {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to AWS EC2') {
            when {
                anyOf {
                    branch "dev"
                    branch "master"
                }
            }
            steps {
                script {
                    echo "Deploying on EC2: ${EC2_HOST}"

                    def runCommand = """
                        docker pull ${IMAGE_NAME}
                        docker stop app || true
                        docker rm app || true
                        docker run -d -p 80:80 --name app ${IMAGE_NAME}
                    """

                    sshagent(credentials: ["${EC2_SSH_CRED}"]) {
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_HOST} '${runCommand}'"
                    }
                }
            }
        }
    }
}
