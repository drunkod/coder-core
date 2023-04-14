# Ubuntu 22.04 + SSL
# Uncomment SSL lines if SSL configuration is needed

FROM ubuntu:22.04
#MAINTAINER Sergei Ovchinnikov (https://wmspanel.com/help)
LABEL	description="Nimble Streamer with SRT"

RUN	apt-get update -y
RUN	apt-get install wget gnupg sudo vim less -y

ENV	TZ=Asia/Vladivostok
RUN	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN    wget -q -O - http://nimblestreamer.com/gpg.key | sudo apt-key add -
RUN    apt-get update -y
RUN    echo "deb http://nimblestreamer.com/raspbian/ buster/" >> /etc/apt/sources.list
RUN    echo "deb http://us-east-2.ec2.ports.ubuntu.com/ubuntu-ports/ bionic universe" >> /etc/apt/sources.list
RUN    apt-get update -y
RUN    apt-get install nimble nimble-srt nimble-transcoder -y


# Fill in variables for Nimble Server name, WMSPanel account and password below
ARG	WMSPANEL_SERVER_NAME=SRT-Ubuntu_22.04
ARG	WMSPANEL_ACCOUNT=kekave9641@fectode.com
ARG	WMSPANEL_PASS=KI0Tt+TnUC8

RUN	sudo /usr/bin/nimble_regutil -u $WMSPANEL_ACCOUNT -p $WMSPANEL_PASS --server-name $WMSPANEL_SERVER_NAME --host nimble.wmspanel.com
RUN	sudo echo "management_listen_interfaces = *" >> /etc/nimble/nimble.conf 

## Uncomment for SSL config
# Place SSL certificate files to the same directory as Dockerfile and fill its file names in respective variables
#ARG	NIMBLE_SSL_CERT=
#ARG	NIMBLE_SSL_KEY=

#ADD 	$NIMBLE_SSL_CERT /etc/nimble
#ADD 	$NIMBLE_SSL_KEY /etc/nimble
#RUN	sudo echo "ssl_port = 443" >> /etc/nimble/nimble.conf 
#RUN	sudo echo "ssl_certificate = /etc/nimble/$NIMBLE_SSL_CERT" >> /etc/nimble/nimble.conf 
#RUN	sudo echo "ssl_certificate_key = /etc/nimble/$NIMBLE_SSL_KEY" >> /etc/nimble/nimble.conf 
#RUN	sudo echo "ssl_http2_enabled = true" >> /etc/nimble/nimble.conf 
##

EXPOSE 8081 1935 554 443 4444/udp
ENTRYPOINT	["/usr/bin/nimble", "--conf-dir=/etc/nimble", "--log-dir=/var/log/nimble","--pidfile=/var/run/nimble.pid"]
