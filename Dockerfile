# ---------- build stage ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
RUN mvn -B dependency:go-offline
COPY src ./src
RUN mvn -B package -DskipTests

# ---------- runtime stage ----------
FROM registry.access.redhat.com/ubi8/ubi-minimal
RUN microdnf install java-17-openjdk-headless -y && microdnf clean all

WORKDIR /app
COPY --from=build /build/target/*.jar app.jar

EXPOSE 8080

# OpenShift は root 禁止
USER 1001

CMD ["java","-XX:MaxRAMPercentage=75","-jar","/app/app.jar"]
