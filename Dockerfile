# Stage 1: Construção do JAR usando Maven
# Use a versão mais recente do Maven com JDK 17
FROM maven:3.8.8-eclipse-temurin-17 AS builder

# Define o diretório de trabalho dentro do contêiner para a construção
WORKDIR /app

# Copia o arquivo pom.xml e as dependências
COPY pom.xml .

# Baixa as dependências para o cache
RUN mvn dependency:go-offline -B

# Copia o código-fonte da aplicação para o contêiner
COPY src ./src

# Compila e empacota a aplicação em um arquivo JAR
RUN mvn clean package -DskipTests

# Stage 2: Executar a aplicação em uma imagem menor baseada no JDK
FROM openjdk:17-jdk-slim

# Define o diretório de trabalho para a execução
WORKDIR /app

# Copia o JAR gerado no primeiro estágio para a imagem final
COPY --from=builder /app/target/spring-api-0.0.1-SNAPSHOT.jar app.jar

# Expõe a porta em que a aplicação será executada
EXPOSE 8080

# Comando para executar a aplicação
ENTRYPOINT ["java", "-jar", "app.jar"]
