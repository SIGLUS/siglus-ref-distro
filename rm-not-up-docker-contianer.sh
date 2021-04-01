#!/bin/bash

echo "remove not up docker contianers -- manager"
eval $(docker-machine env manager)
sleep 1
docker rm $(docker ps -qf status=exited -qf status=created)

echo "remove not up docker contianers -- worker1"
eval $(docker-machine env worker1)
sleep 1
docker rm $(docker ps -qf status=exited -qf status=created)

echo "remove not up docker contianers -- worker2"
eval $(docker-machine env worker2)
sleep 1
docker rm $(docker ps -qf status=exited -qf status=created)

echo "remove not up docker contianers -- elk"
eval $(docker-machine env elk)
sleep 1
docker rm $(docker ps -qf status=exited -qf status=created)

echo "switch to manager"
eval $(docker-machine env manager)
