# siglus-ref-distro

## deploy qa
docker-compose -f docker-compose.qa.yml up --build  -d
docker-compose -f docker-compose.qa.yml down -v

## deploy integ
docker-compose -f docker-compose.integ.yml up --build  -d
docker-compose -f docker-compose.integ.yml down -v

## deploy uat
docker-compose -f docker-compose.uat.yml up --build  -d
docker-compose -f docker-compose.uat.yml down -v

## Config Talisman

Talisman is a tool that installs a hook to your repository to ensure that potential secrets or sensitive information do not leave the developer's workstation.
It validates the outgoing changeset for things that look suspicious - such as potential SSH keys, authorization tokens, private keys etc.

```
# download the talisman binary
curl https://thoughtworks.github.io/talisman/install.sh > ~/install-talisman.sh
chmod +x ~/install-talisman.sh
# go to project
cd siglus-api
# delete pre-push if existed
rm .git/hooks/pre-push
# install new pre-push hook
~/install-talisman.sh
```
