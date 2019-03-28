workflow "Lint with vale on push" {
  resolves = ["vale-lint"]
  on = "push"
}

action "vale-lint" {
  uses = "./"
}
