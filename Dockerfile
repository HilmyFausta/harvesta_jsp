FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn -B clean package

FROM tomcat:10.1-jre21-temurin-noble

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /workspace/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
