#!/bin/bash
docker service scale siglus-config_nginx=0
sleep 10
docker service scale siglus-config_nginx=3
