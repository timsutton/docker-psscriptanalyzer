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

tag_and_push "${IMAGE_NAME}:dev" "${IMAGE_NAME}:${module_version}"
tag_and_push "${IMAGE_NAME}:dev" "${IMAGE_NAME}:latest"
