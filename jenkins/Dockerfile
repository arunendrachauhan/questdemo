FROM ubuntu:16.04

MAINTAINER arun

RUN apt-get update \
      && apt-get install -y sudo curl build-essential\
      && apt-get install -y git-core maven\
      && apt-get install -y libltdl7 apt-utils\
      && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

RUN mkdir -p /opt
ADD run.sh /opt/run.sh
ENTRYPOINT ["/opt/run.sh"]
