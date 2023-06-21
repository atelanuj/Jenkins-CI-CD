FROM openjdk:8

ADD ${WORKSPACE}/target/*.jar .

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "devops-integration.jar" ]