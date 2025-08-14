pipeline {
    agent any
    environment {
        // Adjust this if you have a different workspace subdir
        REPORTS_DIR = "reports"
    }
    stages {

        // ---------------------------------------------
        // Build & Scan Stages (existing implementation)
        // ---------------------------------------------
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Application') {
            steps {
                sh 'bash scripts/01_build.sh'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'bash scripts/02_build_image.sh'
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh 'bash scripts/03_trivy_fs_scan.sh'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'bash scripts/04_trivy_image_scan.sh'
            }
        }

        stage('Publish Reports') {
  steps {
    sh 'bash scripts/05_publish_reports.sh'
    publishHTML(target: [
      reportDir: "reports",
      reportFiles: "index.html",
      reportName: "Security Reports",
      keepAll: true,
      alwaysLinkToLastBuild: true,
      allowMissing: true
    ])
  }
}


        // ---------------------------------------------
        // Deployment Decision Engine
        // ---------------------------------------------
        stage('Deployment Decision') {
            steps {
                script {
                    env.DEPLOY_APPROVED = "false"
                    def reportPath = "${REPORTS_DIR}/trivy-image.json"
                    def criticalCount = "0"
                    def highCount     = "0"

                    if (fileExists(reportPath)) {
                        criticalCount = sh(
                            script: "grep -c CRITICAL ${reportPath} || true",
                            returnStdout: true
                        ).trim()
                        highCount = sh(
                            script: "grep -c HIGH ${reportPath} || true",
                            returnStdout: true
                        ).trim()
                    } else {
                        echo "⚠️ ${reportPath} not found. Treating vulnerability counts as 0."
                    }

                    echo "Found CRITICAL vulnerabilities: ${criticalCount}"
                    echo "Found HIGH vulnerabilities: ${highCount}"

                    def maxCriticalAllowed = 0
                    def maxHighAllowed     = 5

                    if (criticalCount.toInteger() > maxCriticalAllowed ||
                        highCount.toInteger() > maxHighAllowed) {
                        echo "🚫 Deployment Blocked: Vulnerability threshold exceeded."
                        currentBuild.result = 'UNSTABLE'
                    } else {
                        echo "✅ Deployment Approved: Vulnerabilities within safe limits."
                        env.DEPLOY_APPROVED = "true"
                    }
                }
            }
        }

        // ---------------------------------------------
        // Vulnerability History Tracking
        // ---------------------------------------------
        stage('Record Vulnerability History') {
            steps {
                script {
                    def reportPath = "${REPORTS_DIR}/trivy-image.json"
                    sh 'touch vuln_history.csv'
                    sh """
                        CRIT=\$(grep -c CRITICAL ${reportPath} 2>/dev/null || true)
                        HIGH=\$(grep -c HIGH ${reportPath} 2>/dev/null || true)
                        CRIT=\${CRIT:-0}
                        HIGH=\${HIGH:-0}
                        echo "\$(date +%Y-%m-%d),\$CRIT,\$HIGH" >> vuln_history.csv
                    """
                    echo "📊 Vulnerability counts added to history log."
                }
            }
        }

        // ---------------------------------------------
        // Deploy Application (local test run)
        // ---------------------------------------------
        stage('Deploy Application') {
    steps {
        script {
            echo "🚀 Deploying latest image..."
            sh 'bash scripts/06_deploy.sh'
        }
    }
}


        // ---------------------------------------------
        // Optional: Push to Docker Hub
        // ---------------------------------------------
        // stage('Push Image') {
        //     when { expression { env.DEPLOY_APPROVED == "true" } }
        //     steps {
        //         withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
        //             sh '''
        //                 FULL_TAG=$(cat image_tag.txt)
        //                 echo "$PASS" | docker login -u "$USER" --password-stdin
        //                 docker tag "$FULL_TAG" "$USER/myapp:latest"
        //                 docker push "$USER/myapp:latest"
        //             '''
        //         }
        //     }
        // }

    }

    post {
        always {
            echo "Pipeline finished. Reports archived under build artifacts."
            archiveArtifacts artifacts: "${REPORTS_DIR}/**", fingerprint: true
            archiveArtifacts artifacts: 'vuln_history.csv', fingerprint: true
        }
    }
}
