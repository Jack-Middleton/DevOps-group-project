FROM maven:3.6.0-jdk-11-slim AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package

FROM openjdk:11-jre-slim
COPY --from=build /home/app/target/spring-petclinic-rest-2.6.2.jar /usr/local/lib/application.jar
EXPOSE 9966
ENTRYPOINT ["java","-jar","/usr/local/lib/application.jar"]