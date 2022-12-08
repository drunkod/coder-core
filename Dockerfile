FROM node:16.3.0-alpine
# Installs
# Installs shell related tools
RUN apk --no-cache add sudo tini shadow bash \
# Installs compatibility libs
  gcompat libc6-compat libgcc libstdc++ \
# Installs some basic tools
  git curl socat openssh-client nano unzip brotli zstd xz
# Installs node and npm
#   npm=9.1.2-r0

 # Add PNPM
ARG PNPM_VERSION=7.18.1
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME
RUN apk add --no-cache curl && \
  curl -fsSL "https://github.com/pnpm/pnpm/releases/download/v${PNPM_VERSION}/pnpm-linuxstatic-arm64" -o /bin/pnpm && chmod +x /bin/pnpm && \
  apk del curl
  
ARG USERNAME=coder
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Add group and user # addgroup $USERNAME -g $USER_GID && \
RUN adduser -G node -u $USER_UID -s /bin/bash -D $USERNAME && \
    echo $USERNAME ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/nopasswd

# Change user
USER $USERNAME

ENV PNPM_HOME=/home/$USERNAME/.local/share/pnpm

ENV PATH=$PATH:$PNPM_HOME
RUN sudo pnpm setup

# Configure a nice terminal
RUN echo "export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /home/$USERNAME/.bashrc && \
# Fake poweroff (stops the container from the inside by sending SIGHUP to PID 1)
    echo "alias poweroff='kill -1 1'" >> /home/$USERNAME/.bashrc

WORKDIR /home/$USERNAME
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash"]
