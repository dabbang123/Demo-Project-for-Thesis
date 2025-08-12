# Use OpenJDK base image
#FROM openjdk:17-jdk-slim

# Set working directory
#WORKDIR /app

# Copy the JAR file
#COPY target/*.jar app.jar

# Expose port (if needed)
#EXPOSE 8080

# Run the JAR
#ENTRYPOINT ["java", "-jar", "app.jar"]


# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml .
RUN mvn -B -q -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -B -q -DskipTests package

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# copy the Spring Boot jar built in the previous stage
COPY --from=build /workspace/target/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]



