
FROM docker:dind
LABEL maintainer="Hidenori Sugiyama <madogiwa@gmail.com>"

## tini
RUN wget -O /tini https://github.com/krallin/tini/releases/download/v0.18.0/tini-static-amd64 && \
    chmod +x /tini

## install OpenJDK8 JRE
RUN \
  apk add --update --no-cache openjdk8-jre-base

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

## install jenkins
ARG AGENT_VERSION=3.20

RUN \
  addgroup -g 1000 jenkins && \
  adduser -G jenkins -u 1000 -D jenkins && \
  mkdir -p /home/jenkins/workspace

RUN \
  mkdir -p /usr/share/jenkins && \
  wget -O /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${AGENT_VERSION}/remoting-${AGENT_VERSION}.jar

COPY jenkins-slave /jenkins-slave
RUN \
  chmod +x /jenkins-slave

USER root
ENTRYPOINT ["/tini", "--", "dockerd-entrypoint.sh"]

USER jenkins
WORKDIR /home/jenkins
CMD ["/jenkins-slave"]
