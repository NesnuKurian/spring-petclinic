pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'spring-petclinic'
        REGISTRY_CREDENTIALS = 'DOCKER'
        SONARQUBE_TOKEN = credentials('SONAR')
        GIT_BRANCH = 'main'
    }
    stages {
        stage('Clone Repository') {
            steps {
                git credentialsId: 'nesnukurian', url: 'https://github.com/NesnuKurian/spring-petclinic.git', branch: 'main'
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    sh 'mvn clean test'
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar') {
                        sh """
                        ./mvnw sonar:sonar \
                        -Dsonar.projectKey=spring-petclinic \
                        -Dsonar.host.url=http://35.183.236.229:9000/ \
                        -Dsonar.login=${SONARQUBE_TOKEN}
                        """
                    }
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh './mvnw clean package -DskipTests'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${DOCKER_IMAGE} .
                    """
                }
            }
        }
        
        stage('PUSH TO DOCKERHUB') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: REGISTRY_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                        echo $DOCKER_PASSWORD | docker login --username $DOCKER_USER --password-stdin
                        docker tag spring-petclinic nesnukurian/spring-petclinic
                        docker push nesnukurian/spring-petclinic
                        '''
                    }
                }
            }
        }
        
        stage('Deploy to GitHub') {
            steps {
                script {
                    def artifactPath = 'target/spring-petclinic-3.4.0-SNAPSHOT.jar'
                    
                    if (sh(script: "test -f ${artifactPath}", returnStatus: true) == 0) {
                        withCredentials([usernamePassword(credentialsId: 'nesnukurian', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN')]) {
                            sh '''
                            git config --global user.name "Jenkin"
                            git config --global user.email "nk@gmail.com.com"
        
                            git add -f target/spring-petclinic-3.4.0-SNAPSHOT.jar
        
                            git commit -m "Add JAR artifact"
                            
                            git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/NesnuKurian/spring-petclinic.git $GIT_BRANCH
        
                            '''
                        }
                    } 
                    
                    else {
                        echo "Artifact not found. Skipping commit and push."
                    }
                }
            }
        }

    }

        
        

}

