#!/bin/bash
export CONSUL_HOST=10.1.0.81:8500

for SERVICE_NAME in auth fulfillment notification reference-ui referencedata report requisition siglusapi stockmanagement
do
    echo "deregister service: "$SERVICE_NAME
    curl -s http://$CONSUL_HOST/v1/health/service/$SERVICE_NAME | jq -r '.[] | "curl -XPUT http://$CONSUL_HOST/v1/agent/service/deregister/" + .Service.ID' >> clear.sh
done

chmod a+x clear.sh && ./clear.sh
rm -f clear.sh
