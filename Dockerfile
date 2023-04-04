FROM debian:buster
#MAINTAINER Mitry Pyostrovsky <mitrypyostrovsky@gmail.com>


ENV DEBIAN_FRONTEND=noninteractive
# Update packages and install necessary utilities
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
    && apt-get upgrade -y \
    && apt-get install -y wget locales gnupg dirmngr runit \
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
 ENV WMSPANEL_USER=drunkod@gmail.com
 ENV WMSPANEL_PASS=AJzd8TTgBjw
 ENV WMSPANEL_SLICES= 

# Copy configuration files into container
COPY files/my_init.d /etc/my_init.d
COPY files/service /etc/service
COPY files/logrotate.d /etc/logrotate.d

RUN chown -R nimble:root /etc/service/nimble \
    && chmod -R 777 /etc/service/nimble

 # Make nimble user the owner of the log directory and rules.conf file
RUN mkdir -p /var/log/nimble && \
    chown -R nimble:root /var/log/nimble && \
    chown -R nimble:root /etc/nimble && \
    chmod 664 /etc/nimble   

# Make nimble user the owner of the run directory
RUN mkdir -p /var/run/nimble && \
    chown -R nimble:root /var/run/nimble && \
    chmod 775 /var/run/nimble    

# Expose ports for streaming
EXPOSE 1935 8081

# Set command to start Nimble Streaming Server
#CMD bash -c "runsvdir /etc/service && tail -f /dev/null"
USER nimble
CMD ["/bin/bash"]

