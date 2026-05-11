pipeline {
    agent any

    tools {
        maven 'Maven-3.9'   // 名字要和你之前在 Jenkins 里配置的完全一致
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
            // 构建失败时，调用我们准备好的诊断脚本
            sh '''
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