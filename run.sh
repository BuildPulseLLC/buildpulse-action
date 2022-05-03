#!/bin/bash

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

for path in $INPUT_PATH; do
	if [ ! -e "$path" ]
	then
		echo "🐛 The given path does not exist: $path"
		echo "🧰 To resolve this issue, set the 'path' parameter to the location of your XML test report(s)."
		exit 1
	fi
done
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
	echo "⚠️ ⚠️ ⚠️ As of March 1, 2021, Dependabot PRs cannot access secrets in GitHub Actions. See details on the GitHub blog at https://bit.ly/3KAoIBf"
	echo "⚠️ ⚠️ ⚠️ Secrets are necessary in order to authenticate with external services like BuildPulse."
	echo "⚠️ ⚠️ ⚠️ Since secrets aren't available in this build, the build cannot authenticate with BuildPulse to upload test results."
	exit 0
fi

case "$RUNNER_OS" in
	Linux)
		BUILDPULSE_TEST_REPORTER_BINARY=test-reporter-linux-amd64
		;;
	macOS)
		BUILDPULSE_TEST_REPORTER_BINARY=test-reporter-darwin-amd64
		;;
	Windows)
		BUILDPULSE_TEST_REPORTER_BINARY=test-reporter-windows-amd64.exe
		;;
	*)
		echo "::error::Unrecognized operating system. Expected RUNNER_OS to be one of \"Linux\", \"macOS\", or \"Windows\", but it was \"$RUNNER_OS\"."
		exit 1
esac

BUILDPULSE_TEST_REPORTER_HOSTS=(
	https://get.buildpulse.io
	https://github.com/buildpulse/test-reporter/releases/latest/download
)
[ -n "${INPUT_CLI_HOST}" ] && BUILDPULSE_TEST_REPORTER_HOSTS=("${INPUT_CLI_HOST}" "${BUILDPULSE_TEST_REPORTER_HOSTS[@]}")

getcli() {
	local rval=-1
	for host in "${BUILDPULSE_TEST_REPORTER_HOSTS[@]}"; do
		url="${host}/${BUILDPULSE_TEST_REPORTER_BINARY}"
		if (set -x; curl -fsSL --retry 3 --retry-connrefused --connect-timeout 5 "$url" > "$1"); then
			return 0
		else
			rval=$?
		fi
	done;

	return $rval
}

if getcli ./buildpulse-test-reporter; then
	: # Successfully fetched binary. Great!
else
	msg=$(cat <<-eos
		::warning::Unable to send test results to BuildPulse. See details below.

		Downloading the BuildPulse test-reporter failed with status $?.

		We never want BuildPulse to make your builds unstable. Since we're having
		trouble downloading the BuildPulse test-reporter, we're skipping the
		BuildPulse analysis for this build.

		If you continue seeing this problem, please get in touch at
		https://buildpulse.io/contact so we can look into this issue.
	eos
	)

	echo "${msg//$'\n'/%0A}" # Replace newlines with URL-encoded newlines for proper formatting in GitHub Actions annotations (https://github.com/actions/toolkit/issues/193#issuecomment-605394935)
	exit 0
fi

chmod +x ./buildpulse-test-reporter

set -x

BUILDPULSE_ACCESS_KEY_ID="${INPUT_KEY}" \
	BUILDPULSE_SECRET_ACCESS_KEY="${INPUT_SECRET}" \
	./buildpulse-test-reporter submit $REPORT_PATH --account-id $ACCOUNT_ID --repository-id $REPOSITORY_ID --repository-dir "${REPOSITORY_PATH}"
