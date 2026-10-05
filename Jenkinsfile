pipeline {
    agent { label 'windows-docker' }

    environment {
        BUILDER_IMAGE = 'talk-desktop-windows-builder:2.3.2'
    }

    stages {
        stage('Build builder image') {
            steps {
                powershell '''
                    $ErrorActionPreference = "Stop"
                    docker build -f Dockerfile.windows-builder -t $env:BUILDER_IMAGE .
                    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                '''
            }
        }

        stage('Build MSI') {
            steps {
                powershell '''
                    $ErrorActionPreference = "Stop"
                    docker run --rm --mount "type=bind,source=$env:WORKSPACE,target=C:\work" $env:BUILDER_IMAGE powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File C:\work\build-windows.ps1
                    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                '''
            }
        }

        stage('Archive MSI') {
            steps {
                archiveArtifacts artifacts: 'out/**/*.msi', fingerprint: true
            }
        }
    }
}
