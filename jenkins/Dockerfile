FROM ubuntu:16.04

MAINTAINER arun

RUN apt-get update \
      && apt-get install -y sudo curl build-essential\
      && apt-get install -y git-core maven\
      && apt-get install -y libltdl7 apt-utils\
      && rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN bash -c 'echo LC_ALL="en_US.UTF-8" >> /etc/default/locale'
RUN apt-get install -y default-jdk
EXPOSE 8080

RUN mkdir -p /opt
ADD run.sh /opt/run.sh
ENTRYPOINT ["/opt/run.sh"]
