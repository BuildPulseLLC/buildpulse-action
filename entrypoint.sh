#!/bin/sh -l

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

METADATA_PATH=${REPORT_PATH}/buildpulse.yml
TIMESTAMP=$(date -Iseconds)
UUID=$(cat /proc/sys/kernel/random/uuid)
cat << EOF > "$METADATA_PATH"
---
:build_url: https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID
:check: ${INPUT_CHECK:-github-actions}
:ci-provider: github-actions
:commit: $GITHUB_SHA
:github_actions_actor: $GITHUB_ACTOR
:github_actions_base_ref: $GITHUB_BASE_REF
:github_actions_head_ref: $GITHUB_HEAD_REF
:github_actions_run_id: $GITHUB_RUN_ID
:github_actions_run_number: $GITHUB_RUN_NUMBER
:github_actions_workflow: $GITHUB_WORKFLOW
:ref: $GITHUB_REF
:repo_name_with_owner: $GITHUB_REPOSITORY
:timestamp: '$TIMESTAMP'
EOF

ARCHIVE_PATH=/tmp/buildpulse-${UUID}.gz
tar -zcf "${ARCHIVE_PATH}" "${REPORT_PATH}"
S3_URL=s3://$ACCOUNT_ID.buildpulse-uploads/$REPOSITORY_ID/

AWS_ACCESS_KEY_ID="${INPUT_KEY}" \
  AWS_SECRET_ACCESS_KEY="${INPUT_SECRET}" \
  AWS_DEFAULT_REGION=us-east-2 \
  aws s3 cp "${ARCHIVE_PATH}" "${S3_URL}"
