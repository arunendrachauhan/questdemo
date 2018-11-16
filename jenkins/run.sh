#!/bin/bash
set -x

echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
bash -c 'echo LC_ALL="en_US.UTF-8" >> /etc/default/locale'
wget -q -O - https://get.docker.io/gpg | sudo apt-key add -
sudo echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
sudo apt-get -y install docker.io
sudo apt-get -y update

# Host Machine IP
hostname -I
host_IP=$(hostname -I | cut -f1 -d' ')

# Install Jenkins
sudo useradd jenkins
echo Hello, begin the script
#sudo apt-get install -y default-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
echo deb https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list
#sudo apt-get update -y
sudo apt-get install -y jenkins

JENKINS_UID=$(id -u jenkins)
JENKINS_GID=$(id -g jenkins)
sudo useradd -u ${JENKINS_UID} -g ${JENKINS_GID} -m -d /var/lib/jenkins -s /bin/bash jenkins

#Open firewall ports
sudo ufw --force enable
sudo ufw allow 8080
sudo ufw allow ssh
sudo ufw status

# Install Docker
#sudo apt-get -y install docker.io
sudo adduser jenkins docker
sudo usermod -aG docker jenkins

JENKINS_HOME="/var/lib/jenkins"

sudo mkdir -p /opt/demo
#Fetch git repository
pushd /opt/demo
sudo git init
GITUSER="arunendrachauhan"
GITREPO="questdemo"
sudo git clone https://github.com/${GITUSER}/${GITREPO}.git

#Configuring JENKINS
pushd /opt/demo/${GITREPO}/jenkins
sudo cp install-plugins.sh /usr/local/bin/install-plugins.sh
sudo cp plugins.txt ${JENKINS_HOME}/plugins.txt
sudo /usr/local/bin/install-plugins.sh < ${JENKINS_HOME}/plugins.txt
sudo mkdir ${JENKINS_HOME}/jobs/demoseedjob
sudo cp jobs/jobSeeding.xml ${JENKINS_HOME}/jobs/demoseedjob/config.xml
sudo cp config/config.xml ${JENKINS_HOME}/config.xml
sudo cp config/hudson.tasks.Maven.xml ${JENKINS_HOME}/hudson.tasks.Maven.xml
sudo cp config/hudson.plugins.groovy.Groovy.xml ${JENKINS_HOME}/hudson.plugins.groovy.Groovy.xml
sudo cp config/maven-global-settings-files.xml ${JENKINS_HOME}/org.jenkinsci.plugins.configfiles.GlobalConfigFiles.xml
sudo cp config/credentials.xml ${JENKINS_HOME}/credentials.xml

sudo chown -R jenkins:jenkins ${JENKINS_HOME}

sudo systemctl start jenkins
sudo systemctl status jenkins
sudo cat ${JENKINS_HOME}/secrets/initialAdminPassword > /opt/pass.txt
JENKINS_USER="arun"
JENKINS_PWD="arun"
sudo curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar
pass=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`\
 && echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("${JENKINS_USER}", "${JENKINS_PWD}")'\
 | sudo java -jar jenkins-cli.jar -auth admin:$pass -s http://localhost:8080/ groovy =

sudo service docker restart
# Restart jenkins service

sudo service jenkins restart
popd
#================================================================================================================================================
#Create Jenkins Admin user


sudo rm -rf /opt/demo/*
echo Jenkins Container is ready
#================================================================================================================================================
