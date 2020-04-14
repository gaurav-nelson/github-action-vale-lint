# DEPRECATED ⛔️ 
Use the official Vale action available at https://github.com/errata-ai/vale-action

## Github action: Lint with Vale ✅❎

Automatically lint all modified text files in your GitHub pull requests. This GitHub action uses [Vale](https://errata-ai.github.io/vale/) to lint prose.

![Lint with Vale](https://raw.githubusercontent.com/gaurav-nelson/github-action-vale-lint/master/images/lint-with-vale.png)

The `github-action-vale-lint` checks all modified text (including markup) files and reports failure on error. 

![Vale error list](https://raw.githubusercontent.com/gaurav-nelson/github-action-vale-lint/master/images/vale-error-list.png)

## Prerequisite
You must have [Vale configuration file](https://errata-ai.github.io/vale/config/) `.vale.ini` in your repository.

## How to use
1. Create a new file in your repository `.github/workflows/action.yml`.
   ```bash
   touch .github/workflows/pull_request.yml
   ```
1. Copy-paste the folloing workflow in your `pull_request.yml` file:

   ```yml
   name: Lint PRs with Vale
   on: pull_request
   jobs:
     vale-lint-PR:
       runs-on: ubuntu-latest
       steps:
       - uses: actions/checkout@master
         with:
           fetch-depth: 1
       - uses: gaurav-nelson/github-action-vale-lint@v0.1.0
         env:
           GH_COMMENT_TOKEN: ${{ secrets.GH_COMMENT_TOKEN }}
   ```
1. Or, if you want to lint all files (or files in a specific folder)
   and not just modified files, use the following workflow in your
   `pull_request.yml` file:

   ```yml
   name: Lint PRs with Vale
   on: pull_request
   jobs:
     vale-lint-PR:
       runs-on: ubuntu-latest
       steps:
       - uses: actions/checkout@master
         with:
           fetch-depth: 1
       - uses: gaurav-nelson/github-action-vale-lint@v0.1.0
         with:
           lint-all-files: 'yes' 
           dir-to-lint: 'directory/path/to/lint'
         env:
           GH_COMMENT_TOKEN: ${{ secrets.GH_COMMENT_TOKEN }}
   ```

### Add Vale errors as comments on PR
If you want to show errors as comments on the pull request, in your repository:
1. Go to **Settings** > **Secrets**, and slect **Add a new secret**.
1. Enter **GH_COMMENT_TOKEN** for **Name**, and enter your secret token as
   **Value**.
1. Select **Add secret**.
