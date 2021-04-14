#!/bin/bash

echo ">>>>>>>>> docker stack rm siglus"
docker stack rm siglus
sleep 5

echo ">>>>>>>>> deregister consul"
export CONSUL_HOST=10.1.0.81:8500
for SERVICE_NAME in auth fulfillment notification reference-ui referencedata report requisition siglusapi stockmanagement
do
    echo "Deregistering service siglus_"$SERVICE_NAME
    curl -s http://$CONSUL_HOST/v1/health/service/$SERVICE_NAME | jq -r '.[] | "curl -XPUT http://$CONSUL_HOST/v1/agent/service/deregister/" + .Service.ID' >> clear.sh
done
chmod a+x clear.sh && ./clear.sh
rm -f clear.sh
sleep 5

echo ">>>>>>>>> docker stack deploy siglus"
docker stack deploy -c docker-compose.prod.yml siglus
sleep 30

echo ">>>>>>>>> restart prod nginx"
docker service update --force siglus-config_nginx