
pipeline {
    agent any

    environment {
        GITHUB_CREDENTIALS        = credentials('Bhuvisai22')
        DOCKERHUB_CREDENTIALS     = credentials('saidoc540')
        AWS_CREDENTIALS           = credentials('saipadma628')
        AWS_REGION                = 'ap-south-1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm

                script {
                    env.BRANCH_NAME = sh(
                        script: 'echo $GIT_BRANCH | sed "s|origin/||"',
                        returnStdout: true
                    ).trim()

                    echo "Building for branch: ${env.BRANCH_NAME}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        env.DOCKER_IMAGE = "${DOCKERHUB_CREDENTIALS_USR}/react-app-dev:${BUILD_NUMBER}"
                    } else if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        env.DOCKER_IMAGE = "${DOCKERHUB_CREDENTIALS_USR}/react-app-prod:${BUILD_NUMBER}"
                    } else {
                        error "Unsupported branch: ${env.BRANCH_NAME}. Only 'dev', 'main', or 'master' allowed."
                    }
                }

                sh """
                    echo "Building Docker image: ${env.DOCKER_IMAGE}"
                    docker build -t ${env.DOCKER_IMAGE} .
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh """
                    docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW}
                    docker push ${env.DOCKER_IMAGE}
                """
            }
        }

        stage('Deploy to AWS') {
            steps {
                sh """
                    if ! command -v aws &> /dev/null; then
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        unzip awscliv2.zip
                        sudo ./aws/install
                    fi

                    export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
                    export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
                    export AWS_DEFAULT_REGION=${AWS_REGION}

                    ssh -o StrictHostKeyChecking=no ec2-user@YOUR_EC2_PUBLIC_IP << EOF
                        docker stop trend-app || true
                        docker rm trend-app || true
                        docker pull ${env.DOCKER_IMAGE}
                        docker run -d --name trend-app -p 80:80 ${env.DOCKER_IMAGE}
EOF
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}
