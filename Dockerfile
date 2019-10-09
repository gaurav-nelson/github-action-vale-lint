FROM jdkato/vale
RUN apk add --no-cache bash git jq python3 curl && pip3 install requests
ADD entrypoint.sh /entrypoint.sh
COPY /post_message.py /post_message.py
RUN chmod u+x /entrypoint.sh && \
chmod u+x /post_message.py
ENTRYPOINT ["/entrypoint.sh"]
