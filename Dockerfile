
FROM docker:dind
LABEL maintainer="Hidenori Sugiyama <madogiwa@gmail.com>"

## tini
RUN \
  wget -O /tini https://github.com/krallin/tini/releases/download/v0.18.0/tini-static-amd64 && \
  chmod +x /tini

## tiny-rc
RUN \
  wget -O /tiny-rc https://github.com/madogiwa/tiny-rc/releases/download/v0.1.7/tiny-rc && \
  chmod +x /tiny-rc

## install OpenJDK8 JRE
RUN \
  apk add --update --no-cache openjdk8-jre-base && \
  apk add --update --no-cache sudo

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

## install jenkins
ARG AGENT_VERSION=3.20
ARG ROOT_DIR=/var/jenkins

RUN \
  addgroup -g 1000 jenkins && \
  adduser -G jenkins -u 1000 -h ${ROOT_DIR} -D jenkins && \
  mkdir "${ROOT_DIR}/workspace" && \
  chown jenkins:jenkins "${ROOT_DIR}/workspace" && \
  chmod 775 "${ROOT_DIR}/workspace"

RUN \
  mkdir -p /usr/share/jenkins && \
  wget -O /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${AGENT_VERSION}/remoting-${AGENT_VERSION}.jar

## make docker group
RUN \
  addgroup -g 500 docker && \
  addgroup jenkins docker

## launch dockerd as service
RUN \
  mkdir /tiny-rc.d && \
  ln -s /usr/local/bin/dockerd-entrypoint.sh /tiny-rc.d/dockerd.service

COPY jenkins-slave /jenkins-slave
COPY jenkins-slave.sh /jenkins-slave.sh

ENTRYPOINT ["/tini", "--", "/tiny-rc"]

WORKDIR $ROOT_DIR
CMD ["/jenkins-slave"]

