pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')   // DockerHub username/password
        AWS_CREDENTIALS       = credentials('aws-creds')          // AWS Access Key / Secret
        AWS_REGION            = 'ap-south-1'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Bhuvisai22/devops-build.git'

                script {
                    env.BRANCH = sh(
                        script: "git rev-parse --abbrev-ref HEAD",
                        returnStdout: true
                    ).trim()

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
                    docker build -t ${env.IMAGE} .
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh """
                    docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW}
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

                    ssh -o StrictHostKeyChecking=no ec2-user@3.7.70.117 << EOF
                        docker stop app || true
                        docker rm app || true

                        docker pull ${env.IMAGE}
                        docker run -d --name app -p 80:80 ${env.IMAGE}
EOF
                """
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully for branch ${env.BRANCH}"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
