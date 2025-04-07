pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Aryaman200314/React-application-jenkins.git' 
        DOCKER_IMAGE_NAME = 'react-webapp-container'
        S3_BUCKET = 'react-jenkins-artifect-files'
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Clean Docker') {
            steps {
                sh '''
                    echo "Stopping and removing all Docker containers..."
                    docker ps -aq | xargs -r docker stop
                    docker ps -aq | xargs -r docker rm

                    echo "Removing all Docker images..."
                    docker images -aq | xargs -r docker rmi -f

                    echo "Everything cleared"
                '''
            }
        }

        stage('Clone Repository') {
            steps {
                sh '''
                    sudo rm -rf react-app
                    git clone ${GIT_REPO} react-app
                '''
            }
        }

        stage('Build React App') {
            steps {
                sh '''
                    docker run --rm -v $PWD/react-app:/usr/src/app -w /usr/src/app node:lts bash -c "npm install && npm run build"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE_NAME} react-app
                '''
            }
        }

        stage('Run Container') {
            steps {
                sh '''
                    docker run -d -p 3000:80 --name react-webapp ${DOCKER_IMAGE_NAME}
                '''
            }
        }

        stage('Upload Build to S3') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-cred-for-s3-access', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region $AWS_DEFAULT_REGION
                        aws s3 cp --recursive react-app/build s3://$S3_BUCKET/
                    '''
                }
            }
        }

        stage('Archive Build Locally') {
            steps {
                sh '''
                    mkdir -p artifacts
                    cp -r react-app/build/* artifacts/
                '''
            }
        }
    }

    post {
        success {
            emailext (
                to: '200314arya@gmail.com',
                subject: "SUCCESS: ${env.JOB_NAME} Build #${env.BUILD_NUMBER}",
                body: "Good news! The build for ${env.JOB_NAME} succeeded.\nCheck it at ${env.BUILD_URL}"
            )
        }

        failure {
            emailext (
                to: '200314arya@gmail.com',
                subject: "FAILURE: ${env.JOB_NAME} Build #${env.BUILD_NUMBER}",
                body: "Uh oh! The build for ${env.JOB_NAME} failed.\nCheck it at ${env.BUILD_URL}"
            )
        }
    }
}
