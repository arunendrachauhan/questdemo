#!/bin/bash
set -ex

# Host Machine IP
hostname -I
host_IP=$(hostname -I | cut -f1 -d' ')
JENKINS_UID=$(id -u jenkins)
JENKINS_GID=$(id -g jenkins)
useradd -u ${JENKINS_UID} -g ${JENKINS_GID} -m -d /var/lib/jenkins -s /bin/bash jenkins

JENKINS_HOME="/var/lib/jenkins"

mkdir /opt/demo
cat ${JENKINS_HOME}/secrets/initialAdminPassword > /opt/pass.txt

#Fetch git repository
pushd /opt/demo
git init
GITUSER="arunendrachauhan"
GITREPO="questdemo"
git clone https://github.com/${GITUSER}/${GITREPO}.git

#Configuring JENKINS
pushd /opt/demo/${GITREPO}/jenkins
cp plugins.txt /usr/share/jenkins/plugins.txt
cp install-plugins.sh /usr/local/bin/
/usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt
mkdir -p ${JENKINS_HOME}/jobs/demoseedjob
cp jobs/jobSeeding.xml ${JENKINS_HOME}/jobs/demoseedjob/config.xml
cp cp config/config.xml ${JENKINS_HOME}/config.xml
cp config/hudson.tasks.Maven.xml ${JENKINS_HOME}/hudson.tasks.Maven.xml
cp config/hudson.plugins.groovy.Groovy.xml ${JENKINS_HOME}/hudson.plugins.groovy.Groovy.xml
cp config/maven-global-settings-files.xml ${JENKINS_HOME}/org.jenkinsci.plugins.configfiles.GlobalConfigFiles.xml
cp config/credentials.xml ${JENKINS_HOME}/credentials.xml
# Restart jenkins service
sudo chown -R jenkins:jenkins ${JENKINS_HOME}
sudo service jenkins restart
popd
#================================================================================================================================================
#Create Jenkins Admin user
JENKINS_USER="arun"
JENKINS_PWD="arun"
curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar
pass=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`\
 && echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("${JENKINS_USER}", "${JENKINS_PWD}")'\
 | sudo java -jar jenkins-cli.jar -auth admin:$pass -s http://localhost:8080/ groovy =

sudo rm -rf /opt/demo/*
echo Jenkins Container is ready
#================================================================================================================================================
