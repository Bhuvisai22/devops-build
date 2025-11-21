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
                git branch: 'dev',
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
    }
}

