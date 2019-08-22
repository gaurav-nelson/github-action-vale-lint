FROM jdkato/vale
RUN apk add --no-cache bash git jq python3 curl && pip3 install requests
LABEL "com.github.actions.name"="vale-lint"
LABEL "com.github.actions.description"="Vale - linter for prose "
LABEL "com.github.actions.icon"="check-circle"
LABEL "com.github.actions.color"="blue"
LABEL "repository"="https://github.com/gaurav-nelson/github-action-vale-lint.git"
LABEL "homepage"="https://github.com/gaurav-nelson/github-action-vale-lint"
LABEL "maintainer"="Gaurav Nelson"
ADD entrypoint.sh /entrypoint.sh
COPY /post_message.py /post_message.py
RUN chmod u+x /entrypoint.sh && \
chmod u+x /post_message.py
ENTRYPOINT ["/entrypoint.sh"]