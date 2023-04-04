FROM debian:buster
#MAINTAINER Mitry Pyostrovsky <mitrypyostrovsky@gmail.com>


ENV DEBIAN_FRONTEND=noninteractive
# Update packages and install necessary utilities
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
    && apt-get upgrade -y \
    && apt-get install -y wget locales gnupg dirmngr \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Nimble Streaming Server and move configuration files
RUN echo "deb http://nimblestreamer.com/debian/ buster/" > /etc/apt/sources.list.d/nimblestreamer.list \
    && wget -q -O - http://nimblestreamer.com/gpg.key | apt-key add - \
    && apt-get update \
    && apt-get install -y nimble \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir /etc/nimble.conf \
    && mv /etc/nimble/* /etc/nimble.conf

# Create volumes for configuration and cache files
VOLUME /etc/nimble
VOLUME /var/cache/nimble

# Set environment variables for WMS-panel (if needed)
 ENV WMSPANEL_USER   "drunkod@gmail.com"
 ENV WMSPANEL_PASS   "AJzd8TTgBjw"
 ENV WMSPANEL_SLICES ""

# Copy configuration files into container
COPY files/my_init.d /etc/my_init.d
COPY files/service /etc/service
COPY files/logrotate.d /etc/logrotate.d

# Expose ports for streaming
EXPOSE 1935 8081

# Set command to start Nimble Streaming Server
#CMD bash -c "service nimble start && tail -f /dev/null"
CMD ["/bin/bash"]

