pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sarananbu17/blue-green-app"
        VERSION = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Saran-SNU/BlueGreenDeployment.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker build --no-cache -t ${DOCKER_IMAGE}:${VERSION} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub-credentials-id', url: '']) {
                        bat "docker push ${DOCKER_IMAGE}:${VERSION}"
                    }
                }
            }
        }

        stage('Deploy to Blue/Green') {
            steps {
                script {
                    def activeColor = fileExists('active_color.txt') ? readFile('active_color.txt').trim() : 'blue'
                    def newColor = (activeColor == 'blue') ? 'green' : 'blue'
                    def port = (newColor == 'blue') ? 8081 : 8082

                    echo "🔄 Active: ${activeColor}, deploying new version to: ${newColor} on port ${port}"

                    // Stop and remove existing container if it exists
                    def existing = bat(script: "docker ps -a -q -f name=${newColor}", returnStdout: true).trim()
                    if (existing) {
                        bat "docker rm -f ${newColor}"
                        echo "🧹 Removed existing ${newColor} container"
                    }

                    // Check if port is in use and free it
                    try {
                        bat "netstat -ano | findstr :${port} && for /f \"tokens=5\" %i in ('netstat -ano ^| findstr :${port}') do taskkill /PID %i /F || echo Port ${port} is free"
                    } catch (e) {
                        echo "Port ${port} is already free"
                    }

                    // Run new container
                    bat "docker run -d -p ${port}:3000 --name ${newColor} ${DOCKER_IMAGE}:${VERSION}"

                    // Wait for container to start
                    echo "⏳ Waiting for container to start..."
                    bat "ping -n 10 127.0.0.1 >nul"

                    // Test deployment
                    def response = bat(script: "curl -s -o nul -w \"%{http_code}\" http://localhost:${port}", returnStdout: true).trim()
                    if (response != "200") {
                        error "❌ Deployment failed on ${newColor}. HTTP code: ${response}"
                    }

                    // Update active color
                    writeFile file: 'active_color.txt', text: newColor
                    echo "✅ Successfully switched traffic to ${newColor} environment."
                }
            }
        }

        stage('Cleanup Old Environment') {
            steps {
                script {
                    def activeColor = readFile('active_color.txt').trim()
                    def oldColor = (activeColor == 'blue') ? 'green' : 'blue'
                    
                    def existing = bat(script: "docker ps -a -q -f name=${oldColor}", returnStdout: true).trim()
                    if (existing) {
                        bat "docker rm -f ${oldColor}"
                        echo "🧹 Cleaned up old ${oldColor} environment."
                    } else {
                        echo "No old container to clean"
                    }
                }
            }
        }
    }
}
