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

if [ ! -d "$INPUT_REPOSITORY_PATH" ]
then
  echo "🐛 The given path is not a directory: ${INPUT_REPOSITORY_PATH}"
  echo "🧰 To resolve this issue, set the 'repository-path' parameter to the directory that contains the local git clone of your repository."
  exit 1
fi
REPOSITORY_PATH="${INPUT_REPOSITORY_PATH}"

if test -z "$INPUT_KEY" && test -z "$INPUT_SECRET" && test "$GITHUB_ACTOR" = "dependabot[bot]"
then
  echo "::warning ::No value available for the 'key' parameter or the 'secret' parameter. Skipping upload to BuildPulse."
  echo "⚠️ ⚠️ ⚠️ As of March 1, 2021, Dependabot PRs cannot access secrets in GitHub Actions. See details on the GitHub blog at https://git.io/Jm5au"
  echo "⚠️ ⚠️ ⚠️ Secrets are necessary in order to authenticate with external services like BuildPulse."
  echo "⚠️ ⚠️ ⚠️ Since secrets aren't available in this build, the build cannot authenticate with BuildPulse to upload test results."
  exit 0
fi

CLI_URL="${INPUT_CLI_URL:-https://github.com/buildpulse/test-reporter/releases/latest/download/test-reporter-linux-amd64}"

wget --quiet "${CLI_URL}" --output-document ./buildpulse-test-reporter

chmod +x ./buildpulse-test-reporter

BUILDPULSE_ACCESS_KEY_ID="${INPUT_KEY}" \
  BUILDPULSE_SECRET_ACCESS_KEY="${INPUT_SECRET}" \
  ./buildpulse-test-reporter submit "${REPORT_PATH}" --account-id $ACCOUNT_ID --repository-id $REPOSITORY_ID --repository-dir "${REPOSITORY_PATH}"
