pipeline{
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '50'))
    }
    parameters {
        string(defaultValue: "latest", description: 'Image tag example: master-14. \nDockerHub: https://hub.docker.com/r/siglusdevops/reference-ui/tags?page=1', name: 'IMAGE_TAG')
        choice(choices: ['dev','qa','integ', 'uat'], description: 'Which environment?', name: 'ENV')
    }

   stages {
       stage('Pull Image') {
            steps {
                sh '''
                    echo ${IMAGE_TAG}
                    echo ${ENV}
                    docker pull siglusdevops/reference-ui:${IMAGE_TAG}
                '''
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
            echo "OL_REFERENCE_UI_VERSION=${IMAGE_TAG}" > .env
            SERVICE_NAME=reference-ui
            CONTAINER_NAME=$(docker ps | grep ${SERVICE_NAME} | awk '{print $NF}')

            echo "dergregister reference-ui on ${APP_ENV} consul"
            docker -H ${DOCKER_HOST} exec $CONTAINER_NAME node consul/registration.js -c deregister -f consul/config.json
            docker -H ${DOCKER_HOST} stop $CONTAINER_NAME

            docker-compose -H ${DOCKER_HOST} -f docker-compose.yml -p siglus-ref-distro up --no-deps --force-recreate -d ${SERVICE_NAME}
        '''
      }
    }
}