#!/bin/bash
set -x

if [ "${1:0:1}" != '-' ]; then
	exec "$@"
fi
SONARQUBE_JDBC_URL="jdbc:postgresql://sonardb:5432/sonar"
SONARQUBE_JDBC_USERNAME="sonar"
SONARQUBE_JDBC_PASSWORD="sonar"
exec java -jar lib/sonar-application-$SONAR_VERSION.jar \
	-Dsonar.log.console=true \
  -Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
  -Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
  -Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
  -Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
	"$@"
echo 'creating the Domain Admins group...'
curl -s -u admin:admin -X POST localhost:9000/api/user_groups/create -d 'name=Admins'
admins_permissions=(
    'admin'
    'profileadmin'
    'gateadmin'
    'provisioning'
)
for permission in "${admins_permissions[@]}"; do
    echo "adding the $permission permission to the Admins group..."
    curl -s -u admin:admin -X POST localhost:9000/api/permissions/add_group -d 'groupName=Admins' -d "permission=$permission"
done
