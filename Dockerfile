ARG OPENJDK_VERSION='12-jdk-oracle'

FROM openjdk:${OPENJDK_VERSION}
LABEL maintainer="Integr8"

# Jenkins Variables
ARG JENKINS_AGENT_VERSION='3.33'
ARG JENKINS_USERNAME=jenkins
ARG JENKINS_UID=1000
ARG JENKINS_GID=1000
ARG JENKINS_GROUP=jenkins

ENV HOME /home/${JENKINS_USERNAME}
ENV AGENT_WORKDIR ${HOME}/agent

COPY jenkins-slave /usr/local/bin/jenkins-slave

RUN yum install -y curl bash git git-lfs openssh-client openssl procps\
    && groupadd -g ${JENKINS_GID} ${JENKINS_GROUP} \
    && adduser -d /home/${JENKINS_USERNAME} -u ${JENKINS_UID} -g ${JENKINS_GROUP} ${JENKINS_USERNAME} \
    && curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_AGENT_VERSION}/remoting-${JENKINS_AGENT_VERSION}.jar \
    && mkdir ${HOME}/.jenkins ${HOME}/agent \
    && chown ${JENKINS_USERNAME}:${JENKINS_GROUP} ${HOME} -R \
    && chmod 755 /usr/share/jenkins && chmod 644 /usr/share/jenkins/slave.jar \
    && chmod +x /usr/local/bin/jenkins-slave \
    && yum clean all && rm -rf /var/cache/yum

USER ${JENKINS_USERNAME}

VOLUME ${HOME}/.jenkins
VOLUME ${AGENT_WORKDIR}

WORKDIR ${HOME}

ENTRYPOINT ["jenkins-slave"]