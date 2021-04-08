#!/bin/bash

machines="manager worker1 worker2 elk uat integ qa nonprod-elk"

for machine in $machines
do
  echo "remove not up docker contianers -- $machine"
  # shellcheck disable=SC2046
  eval $(docker-machine env "$machine")
  sleep 1
  # shellcheck disable=SC2046
  docker rm $(docker ps -qf status=exited -qf status=created | xargs)
done

echo "switch to manager"
# shellcheck disable=SC2046
eval $(docker-machine env manager)
