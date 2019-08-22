# Github action: Lint with Vale ✅❎

Automatically lint all modified text files in your GitHub pull requests. This GitHub action uses [Vale](https://errata-ai.github.io/vale/) to lint prose.

![Lint with Vale](https://raw.githubusercontent.com/gaurav-nelson/github-action-vale-lint/master/images/lint-with-vale.png)

The `github-action-vale-lint` checks all modified text (including markup) files and reports failure on error. 

![Vale error list](https://raw.githubusercontent.com/gaurav-nelson/github-action-vale-lint/master/images/vale-error-list.png)

## Prerequisite
You must have [Vale configuration file](https://errata-ai.github.io/vale/config/) `.vale.ini` in your repository.

## Workflow file
Sample workflow file `pull_request.yml`:

![Lint with Vale on PR](https://raw.githubusercontent.com/gaurav-nelson/github-action-vale-lint/master/images/lint-with-vale-on-pr.png)

```
on: pull_request
name: Lint with vale on PR
jobs:
  vale-lint-PR:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: vale-lint-PR
      uses: ./
      env:
        GH_COMMENT_TOKEN: ${{ secrets.GH_COMMENT_TOKEN }}
```

## Add Vale errors as comments on PR

In your repository:
1. Go to **Settings** > **Secrets**, and slect **Add a new secret**.
1. Enter **GH_COMMENT_TOKEN** for **Name**, and enter your secret token as
   **Value**.
1. Select **Add secret**.
