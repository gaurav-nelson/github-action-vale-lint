workflow "Lint with vale on push" {
  resolves = ["vale-lint"]
  on = "push"
}

action "vale-lint" {
  uses = "./"
}

workflow "Lint with vale on PR" {
  on = "pull_request"
  resolves = ["vale-lint-PR"]
}

action "vale-lint-PR" {
  uses = "./"
}
