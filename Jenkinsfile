pipeline {
  agent any

  environment {
    IMAGE_NAME = 'local/demo-thesis'     // change if you want
    SKIP_TESTS = 'true'                  // flip to 'false' when ready
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build (Maven)') {
      steps { sh 'scripts/01_build.sh' }
    }

    stage('Docker Build') {
      steps { sh 'scripts/02_build_image.sh' }
    }

    stage('Trivy FS Scan') {
      steps { sh 'scripts/03_trivy_fs_scan.sh' }
    }

    stage('Trivy Image Scan') {
      steps { sh 'scripts/04_trivy_image_scan.sh' }
    }

    stage('Publish Reports') {
      steps {
        sh 'scripts/05_publish_reports.sh'
        archiveArtifacts artifacts: 'reports/**', fingerprint: true
        publishHTML(target: [
          reportDir: 'reports/html',
          reportFiles: 'trivy-fs.txt,trivy-image.txt',
          reportName: 'Security Reports',
          keepAll: true, alwaysLinkToLastBuild: true, allowMissing: true
        ])
      }
    }
    // ---------------------------------------------
    // 🚀 Stage: Deployment Decision Engine
  // ---------------------------------------------
	stage('Deployment Decision') {
    steps {
        script {
            def criticalCount = "0"
            def highCount = "0"

            if (fileExists('trivy-image-report.json')) {
                criticalCount = sh(
                    script: "grep -c CRITICAL trivy-image-report.json || true",
                    returnStdout: true
                ).trim()

                highCount = sh(
                    script: "grep -c HIGH trivy-image-report.json || true",
                    returnStdout: true
                ).trim()
            } else {
                echo "⚠️ No Trivy image report found, skipping vulnerability check."
            }

            echo "Found CRITICAL vulnerabilities: ${criticalCount}"
            echo "Found HIGH vulnerabilities: ${highCount}"

            def maxCriticalAllowed = 0
            def maxHighAllowed = 5

            if (criticalCount.toInteger() > maxCriticalAllowed || highCount.toInteger() > maxHighAllowed) {
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
	// 🚀 Stage: Vulnerability History Tracking
	// ---------------------------------------------
	stage('Record Vulnerability History') {
		steps {
			script {
				// Ensure history file exists
				sh 'touch vuln_history.csv'
            
				// Append date and vulnerability counts
				sh '''
					CRIT=$(grep -c CRITICAL trivy-image-report.json || true)
					HIGH=$(grep -c HIGH trivy-image-report.json || true)
					echo "$(date +%Y-%m-%d),$CRIT,$HIGH" >> vuln_history.csv
				'''
            
				echo "📊 Vulnerability counts added to history log."
			}
		}
	}

	// ---------------------------------------------
	// 🚀 Stage: Conditional Deployment
	// ---------------------------------------------
	stage('Deploy Application') {
		when {
			expression { env.DEPLOY_APPROVED == "true" }
		}
		steps {
			script {
				echo "🚀 Deploying latest image..."
				sh """
					docker stop myapp || true
					docker rm myapp || true
					docker run -d --name myapp -p 8080:8080 $DOCKER_USER/myapp:latest
				"""
			}
		}
	}
    // Optional: push image later
    stage('Push Image') {
      when { expression { return false } } // set to true when you add creds
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh '''
            FULL_TAG=$(cat image_tag.txt)
            echo "$PASS" | docker login -u "$USER" --password-stdin
            docker push "$FULL_TAG"
          '''
        }
      }
    }
  }

  post {
    always { echo 'Pipeline finished. Reports archived under build artifacts.' }
  }
}
