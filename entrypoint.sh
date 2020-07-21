#!/bin/sh -el

set -e

if ! echo $INPUT_ACCOUNT | egrep -q '^[0-9]+$'
then
  echo "🐛 The given value is not a valid account ID: ${INPUT_ACCOUNT}"
  echo "🧰 To resolve this issue, set the 'account' parameter to your numeric BuildPulse Account ID."
  exit 1
fi
ACCOUNT_ID=$INPUT_ACCOUNT

if ! echo $INPUT_REPOSITORY | egrep -q '^[0-9]+$'
then
  echo "🐛 The given value is not a valid repository ID: ${INPUT_REPOSITORY}"
  echo "🧰 To resolve this issue, set the 'repository' parameter to your numeric BuildPulse Repository ID."
  exit 1
fi
REPOSITORY_ID=$INPUT_REPOSITORY

if [ ! -d "$INPUT_PATH" ]
then
  echo "🐛 The given path is not a directory: ${INPUT_PATH}"
  echo "🧰 To resolve this issue, set the 'path' parameter to the directory that contains your test report(s)."
  exit 1
fi
REPORT_PATH="${INPUT_PATH}"

wget --quiet https://github.com/buildpulse/test-reporter/releases/latest/download/test-reporter-linux-amd64 --output-document ./buildpulse-test-reporter

chmod +x ./buildpulse-test-reporter

BUILDPULSE_ACCESS_KEY_ID="${INPUT_KEY}" \
  BUILDPULSE_SECRET_ACCESS_KEY="${INPUT_SECRET}" \
  ./buildpulse-test-reporter submit "${REPORT_PATH}" --account-id $ACCOUNT_ID --repository-id $REPOSITORY_ID
