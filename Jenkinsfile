pipeline {
    agent any

    environment {
        // These will be injected from Jenkins credentials
        GITHUB_CREDENTIALS = credentials('Bhuvisai22')      // Bhuvisai22 + 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

        DOCKERHUB_CREDENTIALS = credentials('saidoc540') // saidoc540 + Charvi@143
        AWS_CREDENTIALS = credentials('saipadma628')     // AKIA4HEHQHG7C5CZB4N6 + cRy0PVn8+m2U3QBfv1TVhVrYOWHCyn6gZlTYyk3M



        // Set region and other defaults
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Extract branch name without 'origin/'
                    env.BRANCH_NAME = sh(
                        script: 'echo $GIT_BRANCH | sed "s|origin/||"',
                        returnStdout: true
                    ).trim()
                    echo "✅ Building for branch: ${env.BRANCH_NAME}"
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
                        error "🚫 Unsupported branch: ${env.BRANCH_NAME}. Only 'dev', 'main', or 'master' allowed."
                    }
                }
                sh """
                    echo "📦 Building Docker image: ${env.DOCKER_IMAGE}"
                    docker build -t ${env.DOCKER_IMAGE} .
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh """
                    echo "🔓 Logging into DockerHub..."
                    docker login -u ${DOCKERHUB_CREDENTIALS_USR} -p ${DOCKERHUB_CREDENTIALS_PSW}
                    echo "⬆️ Pushing image: ${env.DOCKER_IMAGE}"
                    docker push ${env.DOCKER_IMAGE}
                """
            }
        }

        stage('Deploy to AWS') {
            steps {
                sh """
                    echo "🚀 Deploying to AWS..."

                    # Install AWS CLI if not present
                    if ! command -v aws &> /dev/null; then
                        echo "Installing AWS CLI v2..."
                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        unzip awscliv2.zip
                        sudo ./aws/install
                    fi

                    # Configure AWS credentials from Jenkins
                    export AWS_ACCESS_KEY_ID=${AWS_CREDENTIALS_USR}
                    export AWS_SECRET_ACCESS_KEY=${AWS_CREDENTIALS_PSW}
                    export AWS_DEFAULT_REGION=${AWS_REGION}

                    # Example: SSH into EC2 and deploy (replace IP)
                    # ⚠️ Replace 'ec2-user@3.80.123.45' with your actual EC2 public IP
                    ssh -o StrictHostKeyChecking=no ec2-user@YOUR_EC2_PUBLIC_IP << 'EOF'
                        echo "Stopping old container..."
                        docker stop trend-app || true
                        docker rm trend-app || true
                        echo "Pulling new image..."
                        docker pull ${env.DOCKER_IMAGE}
                        echo "Starting new container..."
                        docker run -d --name trend-app -p 80:80 ${env.DOCKER_IMAGE}
                    EOF

                    echo "✅ Deployment completed successfully!"
                """
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline succeeded for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
