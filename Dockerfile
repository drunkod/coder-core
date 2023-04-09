FROM jrottenberg/ffmpeg:6.0-alpine
# Installs
# Installs shell related tools
RUN apk --no-cache add sudo tini shadow bash \
# Installs compatibility libs
  gcompat libc6-compat libgcc libstdc++ \
# Installs some basic tools
  git curl socat openssh-client nano unzip brotli zstd xz
  
ARG USERNAME=coder
# По умолчанию идентификатор пользователя 1000 присваивается первому не root-пользователю, созданному в Linux-системах.
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Add group and user
# это создает новую группу с именем и ID
RUN addgroup $USERNAME -g $USER_GID && \
# это создает нового пользователя с именем, ID и оболочкой, указанными ARG-переменными $USERNAME, $USER_UID и /bin/bash.
# Опция -D означает, что пользователь создается без пароля. 
# Опция -G означает, что пользователь будет добавлен в группу, указанную $USERNAME.
    adduser -G $USERNAME -u $USER_UID -s /bin/bash -D $USERNAME && \
# это записывает строку в файл /etc/sudoers.d/nopasswd, которая дает пользователю, указанному в $USERNAME, 
# возможность выполнять любые команды от имени любого пользователя без пароля.
# Это делается для удобства и безопасности, так как позволяет пользователю установить или запустить все,
# что ему нужно в контейнере, не раскрывая свой пароль.    
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
