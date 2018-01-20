#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/ Usage: {repos|tags repo|rmtag repo tag|gc}
#/ Description: Script for remove specified docker image tags
#/ Examples:
#/   ./api.sh repos :get all repositories
#/   ./api.sh tags repo :get all tags for specified repo
#/   ./api.sh rmtag repo tag :mark specified tag for removal
#/   ./api.sh gc :remove all unused layers
#/ Options:
#/   --help: Display this help message

REGISTRY="http://localhost:5000"

usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }

gettags() {
    curl -s "${REGISTRY}"/v2/"$1"/tags/list |jq .tags[] | sed s/\"//g
}

repolist() {
    curl -s "${REGISTRY}"/v2/_catalog|jq .repositories[] | sed s/\"//g
}

removetag() {
    DIGEST=$(curl -Is -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' "${REGISTRY}/v2/$1/manifests/$2" | grep Docker-Content-Digest: | awk '{ print $2 }')
    curl -s -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' -X DELETE "${REGISTRY}/v2/$1/manifests/${DIGEST%$'\r'}"
    echo "Deleted ${DIGEST}"
}

collectgarbage() {
    docker exec -ti hub_registry_1 bin/registry garbage-collect  /etc/docker/registry/config.yml
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    case "${1:-help}" in
            repos)
                repolist
                ;;
            tags)
                gettags "$2"
                ;;
            rmtag)
                removetag "$2" "$3"
                ;;
            gc)
                collectgarbage
                ;;
            *)
                usage
                exit 1
    esac
fi
