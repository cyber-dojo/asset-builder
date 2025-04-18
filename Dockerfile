FROM cyberdojo/sinatra-base:db948c1@sha256:3abb65e0e8f3b780a64da6fe0c7a3123162d9b0d40a03e4668fef03d441e398b
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

WORKDIR /app
COPY source .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /app/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/config/up.sh" ]
