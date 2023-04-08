ARG BUILD_IMAGE=alpine:3.17

FROM $BUILD_IMAGE as builder

ARG FREETYPE_VERSION=2.12.1-r0
ARG XML2_VERSION=2.10.3-r1
ARG SRT_VERSION=1.5.1-r0
ARG X264_L_VERSION=0.164_git20220602-r0
ARG X264_VERSION=0.164_git20220602-r0
ARG X265_VERSION=3.5-r3
ARG VPX_VERSION=1.12.0-r1
ARG LAME_VERSION=3.100-r2
ARG OPUS_VERSION=1.3.1-r1
ARG VORBIS_VERSION=1.3.7-r0
ARG FBDEV_VERSION=0.5.0-r3
ARG V4L_VERSION=1.22.1-r2
ARG FFMPEG_VERSION=5.1.3

ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig \
  SRC=/usr

# install build packages
RUN apk add --update \
  autoconf \
  automake \
  bash \
  binutils \
  bzip2 \
  ca-certificates \
  cmake \
  coreutils \
  curl \
  diffutils \
  g++ \
  gcc \
  libgcc \
  libssl1.1 \
  libtool \
  linux-headers \
  make \
  musl-dev \
  nasm \
  openssl-dev \
  patch \
  tar \
  zlib-dev

# install shared ffmpeg libs
RUN apk add -U \
  freetype-dev=${FREETYPE_VERSION} \
  libxml2-dev=${XML2_VERSION} \
  libsrt-dev=${SRT_VERSION} \
  x264-libs=${X264_L_VERSION} \
  x264-dev=${X264_VERSION} \
  x265-dev=${X265_VERSION} \
  libvpx-dev=${VPX_VERSION} \
  lame-dev=${LAME_VERSION} \
  opus-dev=${OPUS_VERSION} \
  libvorbis-dev=${VORBIS_VERSION} \
  v4l-utils-dev=${V4L_VERSION}

# install and patch ffmpeg
RUN mkdir -p /dist && cd /dist && \
  curl -OLk http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
  tar -xvz -f ffmpeg-${FFMPEG_VERSION}.tar.gz && \
  rm ffmpeg-${FFMPEG_VERSION}.tar.gz

COPY ./contrib /contrib

RUN cd /dist/ffmpeg-${FFMPEG_VERSION} && \
  patch -p1 < /contrib/ffmpeg-jsonstats.patch && \
  patch -p1 < /contrib/ffmpeg-hlsbitrate.patch && \
  ./configure \
  --extra-version=datarhei \
  --prefix="${SRC}" \
  --extra-libs="-lpthread -lxml2 -lm -lz -lsupc++ -lstdc++ -lssl -lcrypto -lz -lc -ldl" \
  --enable-nonfree \
  --enable-gpl \
  --enable-version3 \
  --enable-postproc \
  --enable-static \
  --enable-openssl \
  --enable-libxml2 \
  --enable-libv4l2 \
  --enable-v4l2_m2m \
  --enable-libfreetype \
  --enable-libsrt \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --disable-ffplay \
  --disable-debug \
  --disable-doc \
  --disable-shared && \
  make -j$(nproc) && \
  make install

# export shared ffmpeg libraries
RUN mkdir -p /ffmpeg/lib && \
  cp \
  /usr/lib/libfreetype.so.6 \
  /usr/lib/libbrotlidec.so.1 \
  /usr/lib/libbrotlicommon.so.1 \
  /usr/lib/libbz2.so.1 \
  /usr/lib/libpng16.so.16 \
  /usr/lib/libxml2.so.2 \
  /usr/lib/liblzma.so.5 \
  /usr/lib/libsrt.so.1.5 \
  /usr/lib/libx264.so \
  /usr/lib/libx264.so.164 \
  /usr/lib/libx265.so.199 \
  /usr/lib/libnuma.so.1 \
  /usr/lib/libvpx.so.7 \
  /usr/lib/libmp3lame.so.0 \
  /usr/lib/libopus.so.0 \
  /usr/lib/libvorbis.so.0 \
  /usr/lib/libogg.so.0 \
  /usr/lib/libvorbisenc.so.2 \
  /usr/lib/libgcc_s.so.1 \
  /usr/lib/libstdc++.so.6 \
  /ffmpeg/lib

FROM $BUILD_IMAGE as final

ENV \
   # container/su-exec UID \
   EUID=1001 \
   # container/su-exec GID \
   EGID=1001 \
   # container/su-exec user name \
   EUSER=docker-user \
   # container/su-exec group name \
   EGROUP=docker-group \
   # container user home dir \
   EHOME= \
   # should user created/updated to use nologin shell? (yes/no) \
   ENOLOGIN=yes \
   # should user home dir get chown'ed? (yes/no) \
   ECHOWNHOME=no \
   # additional directories to create + chown (space separated) \
   ECHOWNDIRS= \
   # additional files to create + chown (space separated) \
   ECHOWNFILES= \
   # container timezone \
   TZ=UTC

# Install shadow (for usermod and groupmod) and su-exec
RUN \
   apk --no-cache --update add \
   shadow \
   su-exec \
   tzdata

COPY \
   chown-path \
   set-user-group-home \
   entrypoint-crond \
   entrypoint-exec \
   entrypoint-su-exec \
   /usr/bin/

RUN \
   chmod +x \
   /usr/bin/chown-path \
   /usr/bin/set-user-group-home \
   /usr/bin/entrypoint-crond \
   /usr/bin/entrypoint-exec \
   /usr/bin/entrypoint-su-exec


COPY --from=builder /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=builder /ffmpeg/lib/* /usr/lib/

ARG FBDEV_VERSION=0.5.0-r3
ARG V4L_VERSION=1.22.1-r2

RUN apk add --no-cache \
  ca-certificates \
  tzdata \
  xf86-video-fbdev=${FBDEV_VERSION} \
  v4l-utils=${V4L_VERSION} && \
  ffmpeg -buildconf

WORKDIR /tmp
ENTRYPOINT ["/usr/bin/ffmpeg"]
CMD ["-version"]
