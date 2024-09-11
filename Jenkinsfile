pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/davidab265/2bcloud-APP'
        ACR_NAME = 'davids.azurecr.io/'
        IMAGE_NAME = 'samples/gpt-human' 
        AKS_KUBECONFIG = '/path/to/kubeconfig' 
        HELM_REPO = 'https://github.com/davidab265/2bcloud-Helm' 
       // DOCKER_CREDENTIALS_ID = 'acr-docker-credentials'
       // GIT_CREDENTIALS_ID = 'github-credentials' 
    }

    stages {
        stage('Clone GitHub Repo') {
            steps {
                git credentialsId: "${GIT_CREDENTIALS_ID}", url: "${GIT_REPO}"
            }
        }

        stage('Get Latest Tag and Bump') {
            steps {
                script {
                    def lastTag = sh(script: "git describe --tags `git rev-list --tags --max-count=1`", returnStdout: true).trim()
                    def (major, minor, patch) = lastTag.tokenize('.')
                    def newTag = "${major}.${minor}.${patch.toInteger() + 1}"
                    sh "git tag ${newTag}"
                    sh "git push origin ${newTag}"
                }
            }
        }

        stage('Build and Tag Docker Image') {
            steps {
                script {
                    def newTag = sh(script: "git describe --tags", returnStdout: true).trim()
                    sh "docker build -t ${IMAGE_NAME}:${newTag} ."
                    sh "docker tag ${IMAGE_NAME}:${newTag} ${ACR_NAME}/${IMAGE_NAME}:${newTag}"
                }
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo ${DOCKER_PASS} | docker login ${ACR_NAME} -u ${DOCKER_USER} --password-stdin"
                    sh "docker push ${ACR_NAME}/${IMAGE_NAME}:${newTag}"
                }
            }
        }

        stage('Clone Helm Repo and Update Image Tag') {
            steps {
                dir('helm-repo') {
                    git credentialsId: "${GIT_CREDENTIALS_ID}", url: "${HELM_REPO}"
                    script {
                        sh """
                        sed -i 's|image:.*|image: ${ACR_NAME}/${IMAGE_NAME}:${newTag}|g' values.yaml
                        git add values.yaml
                        git commit -m 'Update image tag to ${newTag}'
                        git push origin main
                        """
                    }
                }
            }
        }

        stage('Connect to AKS Cluster using kubectl') {
            steps {
                script {
                    // Assuming kubeconfig is already available, set the kubeconfig environment variable for kubectl
                    sh "export KUBECONFIG=${AKS_KUBECONFIG}"
                }
            }
        }

        stage('Perform Helm Upgrade') {
            steps {
                dir('helm-repo') {
                    sh "helm upgrade --install my-release . -f values.yaml"
                }
            }
        }
    }
}
