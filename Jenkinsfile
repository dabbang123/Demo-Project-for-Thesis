pipeline {
  agent any

  environment {
    IMAGE_NAME = 'local/demo-thesis'     // change if you want
    SKIP_TESTS = 'true'                  // flip to 'false' when ready
  }

  options {
    timestamps()
    ansiColor('xterm')
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