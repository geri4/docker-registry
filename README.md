# Docker registry #

This is repo contain docker compose file for docker registry, it is also include script for remove old images.

## Installation ##
```
docker compose up -d
```

## Clean registry ##
Use api.sh script from this repository to remove old images tags.
Examples:
```
./api.sh repos #get all repositories
./api.sh tags repo #get all tags for specified repo
./api.sh rmtag repo tag #mark specified tag for removal
./api.sh gc #remove all unused layers
```
