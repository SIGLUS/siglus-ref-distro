#!/bin/bash

echo "restart prod nginx"
docker service update --force siglus-config_nginx
