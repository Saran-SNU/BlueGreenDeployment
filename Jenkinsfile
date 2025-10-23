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
                    bat "docker build -t %DOCKER_IMAGE%:%VERSION% ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                        bat "docker push %DOCKER_IMAGE%:%VERSION%"
                    }
                }
            }
        }

        stage('Deploy to Blue/Green') {
            steps {
                script {
                    def activeColor = 'blue'
                    if (fileExists('active_color.txt')) {
                        activeColor = readFile('active_color.txt').trim()
                    }

                    def newColor = (activeColor == 'blue') ? 'green' : 'blue'
                    echo "Active: ${activeColor}, Deploying new version to: ${newColor}"

                    // Stop existing container if it exists
                    bat "docker ps -a -q -f name=${newColor} && docker rm -f ${newColor} || echo No ${newColor} container"

                    // Run new container on a different port
                    def port = (newColor == 'blue') ? 8081 : 8082
                    bat "docker run -d -p ${port}:3000 --name ${newColor} ${DOCKER_IMAGE}:${VERSION}"

                    // Wait and test new deployment
                    bat "ping -n 10 127.0.0.1 >nul"
                    bat "curl http://localhost:${port} || exit /b 1"

                    // If OK, switch traffic
                    writeFile file: 'active_color.txt', text: newColor
                    echo "✅ Switched active environment to ${newColor}"
                }
            }
        }

        stage('Cleanup Old Environment') {
            steps {
                script {
                    def activeColor = readFile('active_color.txt').trim()
                    def oldColor = (activeColor == 'blue') ? 'green' : 'blue'
                    bat "docker ps -a -q -f name=${oldColor} && docker rm -f ${oldColor} || echo No old container"
                    echo "🧹 Cleaned up old ${oldColor} environment."
                }
            }
        }
    }
}
