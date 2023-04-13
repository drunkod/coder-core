ARG RESTREAMER_UI_IMAGE=datarhei/restreamer-ui:latest

ARG CORE_IMAGE=ghcr.io/drunkod/media-core:alpine-core-latest

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


 
COPY core /usr/bin/
RUN chmod +x /usr/bin/core
RUN chmod +x /core/bin/run.sh
RUN chmod -R 775 /core

RUN mkdir -p /etc/skel/

RUN echo "export CORE_CONFIGFILE=$CORE_CONFIGFILE \
    export CORE_DB_DIR=$CORE_DB_DIR \
    export CORE_ROUTER_UI_PATH=$CORE_ROUTER_UI_PATH \
    export CORE_STORAGE_DISK_DIR=$CORE_STORAGE_DISK_DIR \
    export CORE_STORAGE_DISK_DIR2=$CORE_STORAGE_DISK_DIR" >> /etc/profile
RUN echo "echo 'Hello, world! /etc/skel/.ashrc'" >> /etc/skel/.ashrc
RUN echo "echo 'Hello, world! /etc/skel/.bashrc'" >> /etc/skel/.bashrc 
RUN echo "echo 'Hello, world! /etc/skel/.profile'" >> /etc/skel/.profile
RUN echo "echo 'Hello, world! /etc/profile'" >> /etc/profile

RUN mkdir -p /home/core/
# # save env in user 
ENV ENV="/home/core/.ashrc"
ENV ENV_BSH="/home/core/.bashrc"
RUN echo "echo 'Hello, world! /home/core/.ashrc'" >> "$ENV"
RUN echo "echo 'Hello, world! /home/core/.bashrc'" >> "$ENV_BSH"
RUN echo "echo 'Hello, world! /home/core/.profile'" >> /home/core/.profile
#  ENTRYPOINT ["entrypoint-su-exec", "/core/bin/run.sh"]
ENTRYPOINT ["/bin/sh"]
#  ENTRYPOINT ["/core/bin/run.sh"]
WORKDIR /home/core
#  CMD ["--bind-addr 0.0.0.0:8080"]
