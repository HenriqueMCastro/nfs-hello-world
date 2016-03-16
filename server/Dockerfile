FROM ubuntu:15.04

ENV DEBIAN_FRONTEND noninteractive
# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN apt-get update -qq 
RUN touch /etc/init.d/statd 
RUN touch /etc/init.d/gssd
RUN touch /etc/init.d/idmapd
RUN apt-get install -y nfs-common
RUN apt-get install -y nfs-kernel-server runit inotify-tools -qq
#RUN apt-get install -y nfs-kernel-server
