# Github action: Lint with Vale ✅❎

Automatically lint all modified text files in your GitHub pull requests. This GitHub action uses [Vale](https://errata-ai.github.io/vale/) to lint prose.

![Lint with Vale](https://raw.githubusercontent.com/gaurav-nelson/github-action-vale-lint/master/images/lint-with-vale.png)

The `github-action-vale-lint` checks all modified text (including markup) files and reports failure on error. 

![Vale error list](https://raw.githubusercontent.com/gaurav-nelson/github-action-vale-lint/master/images/vale-error-list.png)

## Prerequisite
You must have [Vale configuration file](https://errata-ai.github.io/vale/config/) `.vale.ini` in your repository.

## Workflow action

![Lint with Vale on PR](https://raw.githubusercontent.com/gaurav-nelson/github-action-vale-lint/master/images/lint-with-vale-on-pr.png)

```
workflow "Lint with vale on PR" {
  on = "pull_request"
  resolves = ["vale-lint-PR"]
}

action "vale-lint-PR" {
  uses = "./"
}
```

