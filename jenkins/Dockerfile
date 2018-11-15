FROM ubuntu:16.04

MAINTAINER arun
USER root
useradd jenkins
RUN apt-get update \
      && apt-get install -y sudo curl build-essential\
      && apt-get install -y git-core maven\
      && apt-get install -y libltdl7 apt-utils\
      && rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN bash -c 'echo LC_ALL="en_US.UTF-8" >> /etc/default/locale'

RUN wget -q -O - https://get.docker.io/gpg | sudo apt-key add -
RUN sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
RUN apt-get -y update
RUN apt-get install -y default-jdk

RUN apt-get -y install docker.io

RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
RUN sh -c "echo deb https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list"
RUN apt-get update -y
RUN apt-get install -y jenkins

RUN systemctl start jenkins

RUN usermod -aG docker jenkins
RUN service docker restart
EXPOSE 8080

USER jenkins
RUN mkdir -p /opt
ADD run.sh /opt/run.sh
CMD ["/opt/run.sh"]
