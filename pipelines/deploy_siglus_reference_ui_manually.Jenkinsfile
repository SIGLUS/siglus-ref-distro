pipeline{
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '50'))
    }
    parameters {
        string(defaultValue: "latest", description: 'Image tag example: master-14. \nDockerHub: https://hub.docker.com/r/siglusdevops/reference-ui/tags?page=1', name: 'IMAGE_TAG')
        choice(choices: ['qa','integ', 'uat', 'prod'], description: 'Which environment?', name: 'ENV')
    }
    environment {
        IMAGE_REPO = "siglusdevops/reference-ui"
        SERVICE_NAME = "reference-ui"
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

def deploy(app_env) {
    withCredentials([file(credentialsId: "settings.${app_env}.env", variable: 'SETTING_ENV')]) {
        withEnv(["APP_ENV=${app_env}", "CONSUL_HOST=${app_env}.siglus.us.internal:8500"]) {
            sh '''
                rm -f docker-compose.${APP_ENV}.yml .env settings.${APP_ENV}.env
                wget https://raw.githubusercontent.com/SIGLUS/siglus-ref-distro/master/docker-compose.${APP_ENV}.yml
                echo "OL_REFERENCE_UI_VERSION=${IMAGE_TAG}" > .env
                cp $SETTING_ENV settings.${APP_ENV}.env

                echo "deregister ${SERVICE_NAME} on ${APP_ENV} consul"
                curl -s http://${CONSUL_HOST}/v1/health/service/${SERVICE_NAME} | jq -r '.[] | "curl -XPUT http://${CONSUL_HOST}/v1/agent/service/deregister/" + .Service.ID' > clear.sh
                chmod a+x clear.sh && ./clear.sh

                echo "deploy ${SERVICE_NAME} on ${APP_ENV}"
                if [ "${APP_ENV}" = "prod" ]; then
                    docker-machine ls
                    eval $(docker-machine env manager)
                    docker service update --image ${IMAGE_REPO}:${IMAGE_TAG} siglus_${SERVICE_NAME}
                else
                    eval $(docker-machine env ${APP_ENV})
                    docker-machine ls
                    docker-compose -f docker-compose.${APP_ENV}.yml -p siglus-ref-distro up --no-deps --force-recreate -d ${SERVICE_NAME}
                fi
            '''
        }
    }
}
