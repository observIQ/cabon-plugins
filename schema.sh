#!/usr/bin/env bash

set -eE

mkdir temp/
cd temp/
mkdir plugins/
git clone https://github.com/nrkno/yaml-schema-validator-github-action.git
cd yaml-schema-validator-github-action
docker build -t schema:latest .
cd ../../

clean () {
    rm -rf temp/
}
trap clean ERR
#
# FOR EACH PLUGIN FILE
#


for f in $(ls ./plugins)
do

sed 's/{{//; s/}}//' "./plugins/$f" > "./temp/plugins/$f"

export INPUT_SCHEMA=./schemas/$f
export INPUT_TARGET=./temp/plugins/$f

docker run \
     --workdir /github/workspace \
    --rm \
    -e INPUT_SCHEMA \
    -e INPUT_TARGET \
    -e INPUT_STRICT \
    -e HOME \
    -e GITHUB_JOB \
    -e GITHUB_REF \
    -e GITHUB_SHA \
    -e GITHUB_REPOSITORY \
    -e GITHUB_REPOSITORY_OWNER \
    -e GITHUB_RUN_ID \
    -e GITHUB_RUN_NUMBER \
    -e GITHUB_RETENTION_DAYS \
    -e GITHUB_ACTOR \
    -e GITHUB_WORKFLOW \
    -e GITHUB_HEAD_REF \
    -e GITHUB_BASE_REF \
    -e GITHUB_EVENT_NAME \
    -e GITHUB_SERVER_URL \
    -e GITHUB_API_URL \
    -e GITHUB_GRAPHQL_URL \
    -e GITHUB_WORKSPACE \
    -e GITHUB_ACTION \
    -e GITHUB_EVENT_PATH \
    -e GITHUB_ACTION_REPOSITORY \
    -e GITHUB_ACTION_REF -e GITHUB_PATH -e GITHUB_ENV -e RUNNER_OS \
    -e RUNNER_TOOL_CACHE -e RUNNER_TEMP -e RUNNER_WORKSPACE -e ACTIONS_RUNTIME_URL -e ACTIONS_RUNTIME_TOKEN \
    -e ACTIONS_CACHE_URL -e GITHUB_ACTIONS=true -e CI=true \
    -v "$(pwd)":"/github/workspace" \
    schema:latest
done

clean