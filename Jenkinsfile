pipeline {
    agent any

    tools {
        maven 'Maven-3.9'
    }

    stages {
        stage('检出代码') {
            steps {
                checkout scm
            }
        }
        stage('Maven 构建与测试') {
            steps {
                sh 'mvn clean compile test'
            }
        }
    }

    post {
        failure {
            script {
                withCredentials([usernamePassword(
                    credentialsId: 'f2b502f5-3a0c-4cc3-97c9-9bb03f490378',
                    usernameVariable: 'JENKINS_USER',
                    passwordVariable: 'JENKINS_TOKEN'
                )]) {
                    sh '''
                        export JOB_NAME="${JOB_NAME}"
                        export BUILD_NUMBER="${BUILD_NUMBER}"
                        echo "构建失败，触发 Hermes 诊断..."
                        if [ -f ./scripts/hermes-diagnose.sh ]; then
                            bash ./scripts/hermes-diagnose.sh
                        else
                            echo "警告：诊断脚本不存在，跳过"
                        fi
                    '''
                }
            }
        }
    }
}