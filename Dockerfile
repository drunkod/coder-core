ARG RESTREAMER_UI_IMAGE=datarhei/restreamer-ui:latest

ARG CORE_IMAGE=datarhei/base:alpine-core-latest

ARG FFMPEG_IMAGE=ghcr.io/drunkod/coder-core:ffmpeg

FROM $RESTREAMER_UI_IMAGE as restreamer-ui

FROM $CORE_IMAGE as core

FROM $FFMPEG_IMAGE

COPY --from=core /core /core
COPY --from=restreamer-ui /ui/build /core/ui

ADD https://raw.githubusercontent.com/datarhei/restreamer/2.x/CHANGELOG.md /core/ui/CHANGELOG.md
COPY ./run.sh /core/bin/run.sh
COPY ./ui-root /core/ui-root

RUN ffmpeg -buildconf

ENV CORE_CONFIGFILE=/core/config/config.json
ENV CORE_DB_DIR=/core/config
ENV CORE_ROUTER_UI_PATH=/core/ui
ENV CORE_STORAGE_DISK_DIR=/core/data

EXPOSE 8080/tcp
EXPOSE 8181/tcp
EXPOSE 1935/tcp
EXPOSE 1936/tcp
EXPOSE 6000/udp

VOLUME ["/core/data", "/core/config"]

# ENTRYPOINT ["/core/bin/run.sh"]
# ENTRYPOINT ["entrypoint-su-exec", "/core/bin/run.sh"]
 WORKDIR /core
 
 ENV \
   # container/su-exec UID \
   EUID=1001 \
   # container/su-exec GID \
   EGID=1001 \
   # container/su-exec user name \
   EUSER=core \
   # container/su-exec group name \
   EGROUP=core \
   # should user shell set to nologin? (yes/no) \
   ENOLOGIN=no \
   # container user home dir \
   EHOME=/core \
   # code-server version \
   VERSION=3.12.0

 ENTRYPOINT ["entrypoint-su-exec", "/core/bin/run.sh"]
 CMD ["--bind-addr 0.0.0.0:8080"]
