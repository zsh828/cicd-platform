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
                echo "构建失败，触发 Hermes 诊断..."
                if [ -f ./scripts/hermes-diagnose.sh ]; then
                    bash ./scripts/hermes-diagnose.sh
                else
                    echo "警告：诊断脚本不存在，跳过"
                fi
            }
        }
    }
}