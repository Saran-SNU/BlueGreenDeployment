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
                    sh "docker build -t ${DOCKER_IMAGE}:${VERSION} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                        sh "docker push ${DOCKER_IMAGE}:${VERSION}"
                    }
                }
            }
        }

        stage('Deploy to Blue/Green') {
            steps {
                script {
                    def activeColor = sh(script: "cat active_color.txt", returnStdout: true).trim()
                    def newColor = (activeColor == 'blue') ? 'green' : 'blue'

                    echo "Active: ${activeColor}, Deploying to: ${newColor}"

                    // Run container on new environment
                    sh "docker rm -f ${newColor} || true"
                    sh "docker run -d -p 8080:3000 --name ${newColor} ${DOCKER_IMAGE}:${VERSION}"

                    // Health check
                    sh "sleep 10 && curl -f http://localhost:8080 || exit 1"

                    // Switch traffic
                    sh "echo ${newColor} > active_color.txt"
                    echo "Traffic switched to ${newColor}"
                }
            }
        }

        stage('Cleanup Old Environment') {
            steps {
                script {
                    def activeColor = sh(script: "cat active_color.txt", returnStdout: true).trim()
                    def oldColor = (activeColor == 'blue') ? 'green' : 'blue'
                    sh "docker rm -f ${oldColor} || true"
                    echo "${oldColor} environment cleaned up."
                }
            }
        }
    }
}
