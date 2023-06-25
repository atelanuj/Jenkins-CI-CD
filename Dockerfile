FROM openjdk:8-jdk-alpine

VOLUME /c/Users/eresh.gorantla/

ADD ${WORKSPACE}/target/*.jar .

EXPOSE 8081

ENTRYPOINT [ "java", "-jar", "devops-integration.jar" ]