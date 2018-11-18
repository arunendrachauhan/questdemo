#!/bin/bash
set -x

JENKINS_HOME="/var/lib/jenkins"
GITUSER="arunendrachauhan"
GITREPO="questdemo"
REPO_PATH="/opt/demo/${GITREPO}"

#Configuring JENKINS
pushd ${REPO_PATH}/jenkins
sudo cp install-plugins.sh /usr/local/bin/install-plugins.sh
sudo chmod +x /usr/local/bin/install-plugins.sh
sudo cp plugins.txt ${JENKINS_HOME}/plugins.txt
sudo /usr/local/bin/install-plugins.sh < ${JENKINS_HOME}/plugins.txt
sudo mkdir ${JENKINS_HOME}/jobs/demoseedjob
sudo cp jobs/jobSeeding.xml ${JENKINS_HOME}/jobs/demoseedjob/config.xml
sudo cp config/config.xml ${JENKINS_HOME}/config.xml
sudo cp config/hudson.tasks.Maven.xml ${JENKINS_HOME}/hudson.tasks.Maven.xml
sudo cp config/hudson.plugins.groovy.Groovy.xml ${JENKINS_HOME}/hudson.plugins.groovy.Groovy.xml
sudo cp config/maven-global-settings-files.xml ${JENKINS_HOME}/org.jenkinsci.plugins.configfiles.GlobalConfigFiles.xml
sudo cp config/credentials.xml ${JENKINS_HOME}/credentials.xml
sudo cp config/settings.xml /etc/maven/settings.xml
#Restart jenkins service
sudo chown -R jenkins:jenkins ${JENKINS_HOME}
sudo service jenkins restart
popd
