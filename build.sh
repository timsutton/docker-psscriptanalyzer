#!/bin/bash

set -eu -o pipefail

IMAGE_NAME="timsutton/psscriptanalyzer"

compare_published_image_with_module_version() {
	published_tags=$(curl -sSfL https://index.docker.io/v1/repositories/timsutton/psscriptanalyzer/tags | jq --raw-output '.[].name')

	module_version=$(docker run mcr.microsoft.com/powershell:6.2.2-debian-stretch-slim pwsh -c "Write-Output (find-module PSScriptAnalyzer).Version")

	if echo "${published_tags}" | grep -q "${module_version}"; then
		echo -e "Version ${module_version} already present in published Docker image tags:\n${published_tags}.\n"
		echo "Nothing more to do here."
		exit
	fi
}

tag_and_push() {
	source_image=$1
	dest_image=$2
	docker tag "${source_image}" "${dest_image}"
	docker push "${dest_image}"
}

docker_login() {
	echo -n $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
}

compare_published_image_with_module_version

# if the module version we just installed in the image wasn't contained in any published docker image tags,
# then publish a new one with the version and also tag it as 'latest'

docker_login
docker build . -t "${IMAGE_NAME}:dev"
module_version=$(docker run "${IMAGE_NAME}:dev" pwsh -Command "\$ErrorActionPreference = \"Stop\"; Write-Output (Find-Module PSScriptAnalyzer).Version")
echo "PSScriptAnalyzer module version installed: $module_version"

tag_and_push "${IMAGE_NAME}:dev" "${IMAGE_NAME}:${module_version}"
tag_and_push "${IMAGE_NAME}:dev" "${IMAGE_NAME}:latest"
