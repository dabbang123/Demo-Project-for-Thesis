pipeline {
    agent any

    environment {
        JAVA_OPTS = "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=86400"
    }

    stages {
        stage('Checkout Source') {
            steps {
                git url: 'https://github.com/dabbang123/Demo-Project-for-Thesis.git', branch: 'main'
            }
        }

        stage('Build with Maven') {
            steps {
                dir('') { 
                    sh '''
                        echo "🚀 Starting Maven Build"
                        mvn clean package -DskipTests
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t hello-world-app .
                '''
            }
        }

        stage('Run Trivy Scan') {
            steps {
                sh '''
                    trivy image --format json --output trivy-report.json hello-world-app
                '''
            }
        }

        stage('Filter Vulnerabilities') {
            steps {
                sh '''
                    cat trivy-report.json | jq '.Results[].Vulnerabilities[] | select(.Severity=="CRITICAL" or .Severity=="HIGH")' > filtered-report.json
                '''
            }
        }

        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: '**/*.json', allowEmptyArchive: true
            }
        }
    }

    post {
        always {
            echo "Pipeline finished"
        }
    }
}
