pipeline {
    agent any

    options {
        timestamps()
        // ansiColor('xterm')
    }

    environment {
        JAVA_OPTS = "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=86400"
    }

    stages {
		stage('Clean Target Folder') {
			steps {
				sh 'rm -rf target || true'
			}
		}

        stage('Checkout Source') {
            steps {
                git url: 'https://github.com/dabbang123/Demo-Project-for-Thesis.git', branch: 'main'
            }
        }

        stage('Build with Maven') {
            steps {
                sh '''
                    echo "🚀 Starting Maven Build"
                    mvn clean package -Dmaven.test.skip=true
                '''
            }
        }

        // Comment rest of stages to test speed
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
