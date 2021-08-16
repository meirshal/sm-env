#!/usr/bin/env bash

set -o pipefail

programname=$0
version=1.0.0
aws_profile='default'
environment=$NODE_ENV
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

version() {
  echo "${version}"
}

usage() {
  echo "Usage:"
  echo ""
  echo "$programname [-p <aws profile>] -s <secret name> -e <environment>"
  echo ""
  echo "  -s   Service name"
  echo "  -p   AWS profile (default: \"default\")"
  echo "  -h   Display this help"
  echo "  -v   Display version"
  exit 1
}

# get the options and set flags
while getopts "p:s:e:hv" OPTION; do
  case $OPTION in
  v)
    version
    exit 0
    ;;
  h)
    usage
    exit 1
    ;;
  p)
    aws_profile=$OPTARG
    ;;
  s)
    secret=$OPTARG
    ;;
  *)
    echo "Incorrect options provided"
    exit 1
    ;;
  esac
done

create_exports () {
 AWS_PROFILE=${aws_profile} aws secretsmanager get-secret-value --secret-id "${secret}" | \
 jq '.SecretString' | \
 sed 's/\\"/\"/g; s/\"{/{/g; s/\}"/}/g' | \
 ${parent_path}/parse-secrets-json.sh
}

exports=$(create_exports)
eval ${exports}
