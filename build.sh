#!/bin/bash

set -eu -o pipefail

IMAGE_NAME="timsutton/psscriptanalyzer"

tag_and_push() {
	source_image=$1
	dest_image=$2
	docker tag "${source_image}" "${dest_image}"
	docker push "${dest_image}"
}

docker_login() {
	echo -n $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
}

docker_login

docker build . -t "${IMAGE_NAME}:dev"
module_version=$(docker run "${IMAGE_NAME}:dev" pwsh -Command "\$ErrorActionPreference = \"Stop\"; Write-Output (Find-Module PSScriptAnalyzer).Version")
echo "PSScriptAnalyzer module version installed: $module_version"

published_tags=$(curl -sSfL https://index.docker.io/v1/repositories/timsutton/psscriptanalyzer/tags | jq --raw-output '.[].name')

if echo "${published_tags}" | grep -q "${module_version}"; then
	echo -e "Version ${module_version} already present in published Docker image tags:\n${published_tags}.\n"
	echo "Nothing more to do here."
	exit
fi

# if the module version we just installed in the image wasn't contained in any published docker image tags,
# then publish a new one with the version and also tag it as 'latest'
tag_and_push "${IMAGE_NAME}:dev" "${IMAGE_NAME}:${module_version}"
tag_and_push "${IMAGE_NAME}:dev" "${IMAGE_NAME}:latest"
