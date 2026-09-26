FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY .m2 /root/.m2

COPY pom.xml .
RUN mvn dependency:go-offline -B -q

COPY src ./src
RUN mvn clean package -B

FROM eclipse-temurin:17-jre
WORKDIR /app

RUN groupadd -r app && useradd -r -g app app
COPY --from=build /app/target/web-app-*.jar app.jar
RUN chown app:app app.jar

USER app
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
