pipeline{
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '50'))
    }
    parameters {
        string(defaultValue: "latest", description: 'Image tag example: 6efd8f1a79ea8be908837f5b09afe78d85b0a3e7. \nDockerHub: https://hub.docker.com/r/siglusdevops/siglusapi/tags?page=1', name: 'IMAGE_TAG')
        choice(choices: ['dev','qa','integ', 'uat'], description: 'Which environment?', name: 'ENV')
    }

   stages {
       stage('Check Image') {
            steps {
                sh 'echo ${IMAGE_TAG}'
                sh 'echo ${ENV}'
            }
       }

       stage('Deploy') {
            steps {
                deploy "${ENV}"
            }
       }
   }
}

def deploy(app_env){
    withCredentials([file(credentialsId: "setting_env", variable: 'SETTING_ENV')]) {
        withEnv(["APP_ENV=${app_env}",  "CONSUL_HOST=${app_env}.siglus.us.internal:8500","DOCKER_HOST=tcp://${app_env}.siglus.us.internal:2376"]){
        sh '''
            rm -f docker-compose*
            rm -f .env
            rm -f settings.env
            rm -rf siglus-ref-distro
            git clone https://github.com/SIGLUS/siglus-ref-distro
            cd siglus-ref-distro

            cp $SETTING_ENV settings.env
            sed -i "s#<APP_ENV>#${APP_ENV}#g" settings.env
            echo "OL_SIGLUSAPI_VERSION=${IMAGE_TAG}" > .env
            SERVICE_NAME=siglusapi

            echo "deregister ${SERVICE_NAME} on ${APP_ENV} consul"
            curl -s http://${CONSUL_HOST}/v1/health/service/${SERVICE_NAME} | \
            jq -r '.[] | "curl -XPUT http://${CONSUL_HOST}/v1/agent/service/deregister/" + .Service.ID' > clear.sh
            chmod a+x clear.sh && ./clear.sh

            echo "deploy ${SERVICE_NAME} on ${APP_ENV}"
            docker-compose -H ${DOCKER_HOST} -f docker-compose.yml -p siglus-ref-distro up --no-deps --force-recreate -d ${SERVICE_NAME}
        '''
      }
    }
}