FROM node:16.3.0-alpine
# Installs
# Installs shell related tools
RUN apk --no-cache add sudo tini shadow bash \
# Installs compatibility libs
  gcompat libc6-compat libgcc libstdc++ \
# Installs some basic tools
  git curl socat openssh-client nano unzip brotli zstd xz
  
ARG USERNAME=coder
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Add group and user # addgroup $USERNAME -g $USER_GID && \
RUN adduser -G node -u $USER_UID -s /bin/bash -D $USERNAME && \
    echo $USERNAME ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/nopasswd

# Change user
USER $USERNAME

# Configure a nice terminal
RUN echo "export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /home/$USERNAME/.bashrc && \
# Fake poweroff (stops the container from the inside by sending SIGHUP to PID 1)
    echo "alias poweroff='kill -1 1'" >> /home/$USERNAME/.bashrc

WORKDIR /home/$USERNAME
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash"]
