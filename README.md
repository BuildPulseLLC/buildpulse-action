# GitHub Action for BuildPulse [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Workshop64/buildpulse-action/main/LICENSE)

Easily connect your GitHub Actions CI workflows to [BuildPulse][buildpulse.io] to help you identify and eliminate flaky tests.

## Usage

1. Locate the BuildPulse credentials for your account at [buildpulse.io][]
2. In the GitHub settings for your repository, [create an encrypted secret](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#creating-encrypted-secrets) named `BUILDPULSE_ACCESS_KEY_ID` and set its value to the `BUILDPULSE_ACCESS_KEY_ID` for your account
3. Create another encrypted secret named `BUILDPULSE_SECRET_ACCESS_KEY` and set its value to the `BUILDPULSE_SECRET_ACCESS_KEY` for your account
4. Add a step to your GitHub Actions workflow to use this action to send your test results to BuildPulse:

    ```yaml
    steps:
    - name: Check out code
      uses: actions/checkout@v2

    - name: Run tests
      run: echo "Run your tests and generate XML reports for your test results"

    - name: Upload test results to BuildPulse for flaky test detection
      if: '!cancelled()' # Run this step even when the tests fail. Skip if the workflow is cancelled.
      uses: Workshop64/buildpulse-action@main
      with:
        account: <buildpulse-account-id>
        repository: <buildpulse-repository-id>
        path: <path-to-xml-reports>
        key: ${{ secrets.BUILDPULSE_ACCESS_KEY_ID }}
        secret: ${{ secrets.BUILDPULSE_SECRET_ACCESS_KEY }}
    ```

## Inputs

### `account`

**Required** The unique numeric identifier for the BuildPulse account that owns the repository.

### `repository`

**Required** The unique numeric identifier for the repository being built.

### `path`

**Required** The path to the XML file(s) for the test results. Can be a directory (e.g., `test/reports`), a single file (e.g., `reports/junit.xml`), or a glob (e.g., `app/*/results/*.xml`).

### `key`

**Required** The `BUILDPULSE_ACCESS_KEY_ID` for the account that owns the repository.

### `secret`

**Required** The `BUILDPULSE_SECRET_ACCESS_KEY` for the account that owns the repository.

### `commit`

_Optional_ The SHA for the commit that produced the test results (default: the value of [`${{ github.sha }}`](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context), which is the commit that triggered the workflow).

If your workflow checks out a _different_ commit than the commit that triggered the workflow, then use this input to specify the commit SHA that your workflow checked out. For example, if your workflow is triggered by the [`pull_request` event](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#pull_request), but you [customize the workflow to check out the pull request HEAD commit](https://github.com/actions/checkout/tree/v3.0.2#checkout-pull-request-head-commit-instead-of-merge-commit), then you'll want to set this input to the pull request HEAD commit SHA.

### `repository-path`

_Optional_ The path to the local git clone of the repository (default: ".").


[buildpulse.io]: https://buildpulse.io
