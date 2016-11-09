FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive

# Docker
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
COPY docker.list /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-engine

# guestfs
RUN apt-get install -y wget
RUN apt-get install -y libguestfs-tools
RUN apt-get install -y linux-image-amd64

COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
