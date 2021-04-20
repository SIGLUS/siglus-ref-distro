pipeline{
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '50'))
    }
    parameters {
        choice(choices: ['master', 'release-87'], description: 'Which branch? \n - v3: master \n - v2: release-87', name: 'BRANCH')
        choice(choices: ['dev', 'qa', 'integ', 'uat', 'prod'], description: 'Which environment?', name: 'ENV')
    }
    stages {
        stage('Generate apk') {
            steps {
                sh '''
                    echo "Generate apk of ${BRANCH} in ${ENV}"
                    cd /var/lib/jenkins/workspace/siglus-android_${BRANCH}
                    if [ "${ENV}" = "dev" ]; then
                        ./gradlew assembleDevRelease
                    elif [ "${ENV}" = "qa" ]; then
                        ./gradlew assembleQaRelease
                    elif [ "${ENV}" = "integ" ]; then
                        ./gradlew assembleIntegRelease
                    elif [ "${ENV}" = "uat" ]; then
                        ./gradlew assembleUatRelease
                    elif [ "${ENV}" = "prod" ]; then
                        ./gradlew assembleProdRelease
                    fi
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
    }
}
