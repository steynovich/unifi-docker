FROM debian:jessie

MAINTAINER github@steynhuizinga.nl

VOLUME ["/var/lib/unifi", "/var/log/unifi", "/var/run/unifi", "/usr/lib/unifi/work"]

ENV DEBIAN_FRONTEND noninteractive

# Add mongodb repo
RUN echo "deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen" \
    > /etc/apt/sources.list.d/21mongodb.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10

# Install mongodb, openjdk, etc
RUN echo "deb http://http.debian.net/debian stretch main contrib non-free" \
    > /etc/apt/sources.list.d/stretch.list && \
    apt-get -q update && \
    apt-get install -qy curl openjdk-8-jre-headless binutils jsvc mongodb-10gen && \
    apt-get -q clean && \
    rm -rf /var/lib/apt/lists/*

ENV UNIFI_URL "https://www.ubnt.com/downloads/unifi/5.6.12-d503e7daad/unifi_sysvinit_all.deb"

RUN curl -Lo unifi_sysvinit_all.deb "${UNIFI_URL}" && \
    dpkg -i unifi_sysvinit_all.deb && \
    rm unifi_sysvinit_all.deb

RUN ln -s /var/lib/unifi /usr/lib/unifi/data

EXPOSE 8080/tcp 8081/tcp 8443/tcp 8843/tcp 8880/tcp 3478/udp 6789/tcp

WORKDIR /var/lib/unifi
ENTRYPOINT ["/usr/bin/java", "-Xmx1024M", "-jar", "/usr/lib/unifi/lib/ace.jar"]
CMD ["start"]
