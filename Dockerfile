FROM jdkato/vale
RUN apk add --no-cache bash git
LABEL "com.github.actions.name"="vale-lint"
LABEL "com.github.actions.description"="Vale - linter for prose "
LABEL "com.github.actions.icon"="check-circle"
LABEL "com.github.actions.color"="blue"
LABEL "repository"="https://github.com/gaurav-nelson/github-action-vale-lint.git"
LABEL "homepage"="https://github.com/gaurav-nelson/github-action-vale-lint"
LABEL "maintainer"="Gaurav Nelson"
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]