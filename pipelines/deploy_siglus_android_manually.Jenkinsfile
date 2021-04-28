pipeline{
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '50'))
    }
    parameters {
        choice(choices: ['master', 'release-87'], description: 'Which branch? \n - v3: master \n - v2: release-87', name: 'BRANCH')
        choice(choices: ['dev', 'qa', 'integ', 'uat', 'training', 'prd'], description: 'Which environment?', name: 'ENV')
    }
    stages {
        stage('Generate apk') {
            steps {
                sh '''
                    echo "Branch: ${BRANCH}"
                    echo "Environment: ${ENV}"
                    cd /var/lib/jenkins/workspace/siglus-android_${BRANCH}
                    ./gradlew assemble${ENV}Release
                '''
            }
        }
        stage('Push apk to apk-updater') {
            steps {
                sh '''
                    cd /var/lib/jenkins/workspace/siglus-android_${BRANCH}/app/build/outputs/apk/${ENV}/release
                    cp *.apk /home/ec2-user/apk-updater/apks/
                '''
            }
        }
        stage('Push apk to app-center') {
            steps {
                sh '''
                    cd /var/lib/jenkins/workspace/siglus-android_${BRANCH}
                    ./gradlew appCenterUpload${ENV}Release
                    cd /var/lib/jenkins/workspace/siglus-android_${BRANCH}/app/build/outputs/apk/${ENV}/release
                    rm -f *.apk
                '''
            }
        }
    }
}
