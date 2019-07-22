workflow "Lint with vale on PR" {
  on = "pull_request"
  resolves = ["vale-lint-PR"]
}

action "vale-lint-PR" {
  uses = "./"
  secrets = ["GH_COMMENT_TOKEN"]
}
