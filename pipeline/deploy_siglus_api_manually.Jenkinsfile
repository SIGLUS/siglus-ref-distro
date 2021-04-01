pipeline{
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '50'))
    }
    parameters {
        string(defaultValue: "latest", description: 'Image tag is git revision number. \nDockerHub: https://hub.docker.com/r/siglusdevops/siglusapi/tags?page=1', name: 'IMAGE_TAG')
        choice(choices: ['qa','integ', 'uat', 'prod'], description: 'Which environment?', name: 'ENV')
    }
    environment {
        IMAGE_REPO = "siglusdevops/siglusapi"
        SERVICE_NAME = "siglusapi"
    }
    stages {
        stage('Pull Image') {
            steps {
                sh '''
                    echo ${IMAGE_TAG}
                    echo ${ENV}
                    docker pull siglusdevops/siglusapi:${IMAGE_TAG}
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
        withEnv(["APP_ENV=${app_env}", "CONSUL_HOST=${app_env}.siglus.us.internal:8500", "DOCKER_HOST=tcp://${app_env}.siglus.us.internal:2376"]) {
            sh '''
                rm -f docker-compose.${APP_ENV}.yml .env settings.${APP_ENV}.env
                wget https://raw.githubusercontent.com/SIGLUS/siglus-ref-distro/master/docker-compose.${APP_ENV}.yml
                echo "OL_SIGLUSAPI_VERSION=${IMAGE_TAG}" > .env
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
                    mkdir config
                    docker-compose -H ${DOCKER_HOST} -f docker-compose.${APP_ENV}.yml -p siglus-ref-distro up --no-deps --force-recreate -d ${SERVICE_NAME}
                fi
            '''
        }
    }
}
