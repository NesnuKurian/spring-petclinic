# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-slim AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven wrapper files and the pom.xml to the container
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download the dependencies (this will cache the dependencies if they are unchanged)
RUN ./mvnw dependency:go-offline

# Copy the rest of the application code into the container
COPY src ./src

# Package the application using Maven (this will create a .jar file)
RUN ./mvnw clean package -DskipTests

# Create a new stage to copy the built application into the final image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the .jar file from the build stage into the container
COPY --from=build /app/target/spring-petclinic-3.4.0-SNAPSHOT.jar spring-petclinic.jar

# Expose the port the app runs on
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "spring-petclinic.jar"]
