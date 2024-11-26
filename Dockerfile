FROM openjdk:17-jdk-slim AS build

WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

COPY src ./src

RUN ./mvnw clean package -DskipTests

# Create a new stage to copy the built application into the final image
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /app/target/spring-petclinic-2.7.3.jar spring-petclinic.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]
