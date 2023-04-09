FROM jrottenberg/ffmpeg:6.0-alpine
# Installs
# Installs shell related tools
RUN apk --no-cache add sudo tini shadow bash \
# Installs compatibility libs
  gcompat libc6-compat libgcc libstdc++ \
# Installs some basic tools
  git curl socat openssh-client nano unzip brotli zstd xz
  

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash"]
