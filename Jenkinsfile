pipeline {
    agent any

    environment {
        DEV_REGISTRY = "saidoc540/dev"
        PROD_REGISTRY = "saidoc540/prod"
        IMAGE_NAME = "react-app"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Bhuvisai22/devops-build.git',
                    branch: "${dev}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'chmod +x build.sh'
                sh './build.sh'
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'saidoc540',
                        passwordVariable: 'dckr_pat_PUsA_CJquw1Af99L4nUO4fybpAM'
                    )]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"

                        if (env.BRANCH_NAME == 'dev') {
                            sh "docker tag react-static-app:latest $DEV_REGISTRY:$IMAGE_TAG"
                            sh "docker push $DEV_REGISTRY:$IMAGE_TAG"
                        } else if (env.BRANCH_NAME == 'master') {
                            sh "docker tag react-app:latest $PROD_REGISTRY:$IMAGE_TAG"
                            sh "docker push $PROD_REGISTRY:$IMAGE_TAG"
                        } else {
                            echo "Branch is neither dev nor master. Skipping Docker push."
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'chmod +x deploy.sh'
                sh './deploy.sh'
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully for branch ${BRANCH_NAME}!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
