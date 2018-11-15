#!/bin/bash
set -x

#Install basic tools
sudo apt-get -y install build-essential wget curl git-core
sudo bash -c 'echo LC_ALL="en_US.UTF-8" >> /etc/default/locale'
wget -q -O - https://get.docker.io/gpg | sudo apt-key add -
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get -y update
sudo apt-get install -y maven
sudo apt-get -y upgrade
#sudo apt-get install -y python-pip
#sudo pip install -y docker-compose==1.3.0
sudo apt-get install -y apt-utils
#sudo apt-get install -y docker-compose
sudo apt-get install -y default-jdk
sudo apt-get update -y
# Host Machine IP
hostname -I
host_IP=$(hostname -I | cut -f2 -d' ')

# Install Jenkins
sudo useradd jenkins
echo Hello, begin the script
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c "echo deb https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list"
sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl start jenkins
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
sudo systemctl status jenkins
sleep 5
#download cli
pushd /opt
sudo curl -O http://${host_IP}:8080/jnlpJars/jenkins-cli.jar
#create jenkins user
pass=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`\
 && echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("arun", "arun")'\
 | sudo java -jar jenkins-cli.jar -auth admin:$pass -s http://localhost:8080/ groovy =
popd

#JENKINS_UID=$(id -u jenkins)
#JENKINS_GID=$(id -g jenkins)
#sudo useradd -u ${JENKINS_UID} -g ${JENKINS_GID} -m -d /var/lib/jenkins -s /bin/bash jenkins

#Open firewall ports
sudo ufw --force enable
sudo ufw allow 8080
sudo ufw allow ssh
sudo ufw allow 9000
sudo ufw allow 8081
sudo ufw allow 8089
sudo ufw status

# Install Docker
sudo apt-get -y install docker.io
sudo adduser vagrant docker
sudo adduser vagrant jenkins
sudo adduser jenkins docker
sudo usermod -aG docker jenkins
sudo service docker restart

# Install jenkins plugins
#Plugin_url="https://updates.jenkins-ci.org/download/plugins"
#cat <<EOL | sudo -u jenkins xargs -P 5 -n 1 wget -nv -T 60 -t 3 -P /var/lib/jenkins/plugins
#${Plugin_url}/ansicolor/0.5.2/ansicolor.hpi
#${Plugin_url}/ssh/2.6.1/ssh.hpi
#${Plugin_url}/ssh-agent/1.17/ssh-agent.hpi
#${Plugin_url}/sonar/2.8.1/sonar.hpi
#${Plugin_url}/nexus-jenkins-plugin/3.3.20181102-112614.a65c3f1/nexus-jenkins-plugin.hpi
#EOL

JENKINS_HOME="/var/lib/jenkins"
GITUSER="arunendrachauhan"
GITREPO="questdemo"
sudo mkdir /opt/demo
sudo cat ${JENKINS_HOME}/secrets/initialAdminPassword > /opt/pass.txt

#Fetch git repository
pushd /opt/demo
sudo git init

sudo git clone https://github.com/${GITUSER}/${GITREPO}.git
REPO_PATH="/opt/demo/${GITREPO}"

#Configuring JENKINS
pushd ${REPO_PATH}/jenkins
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
# Restart jenkins service
sudo chown -R jenkins:jenkins ${JENKINS_HOME}
sudo service jenkins restart

#configure nexus/sonar settings
sudo sed -i -E "s,^#?(<url>http://).*:8081/repositories/maven-public</url>,\1${host_IP}," /etc/maven/settings.xml
sudo sed -i -E "s,^#?(<url>http://).*:9000</sonar.host.url>,\1${host_IP}," /etc/maven/settings.xml
popd
#================================================================================================================================================
#Build and deploy docker container for SONARQUBE
pushd ${REPO_PATH}/sonar
sudo chmod +x run.sh
sudo docker build -t sonarimg .
#------------------------------------------------------------------------------------------------------------------------------------------------sudo docker run -d -p=9000:9000 --name=sonar sonarimg
sudo docker run -d -p=9000:9000 --name=sonar sonarimg
#================================================================================================================================================
popd

#Build and deploy docker container for nexus
pushd ${REPO_PATH}/nexus
sudo docker build -t nexusimg .
#================================================================================================================================================
sudo docker run -d -p=8081:8081 --name=nexus nexusimg
#================================================================================================================================================ popd

#================================================================================================================================================
echo Access Jenkins server using below address..
echo "http://${host_IP}:8080"
echo access nexus using...
echo "http://${host_IP}:8081"
echo access sonar using...
echo "http://${host_IP}:9000"
