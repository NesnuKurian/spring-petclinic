FROM openjdk:17-jdk-slim AS build
WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw dependency:go-offline
COPY src ./src

RUN ./mvnw clean package -DskipTests

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /app/target/spring-petclinic-3.4.0-SNAPSHOT.jar spring-petclinic.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]
