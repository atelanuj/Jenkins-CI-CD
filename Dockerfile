FROM openjdk:8

VOLUME /c/Users/eresh.gorantla/

ADD ${WORKSPACE}/target/*.jar .

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "devops-integration.jar" ]