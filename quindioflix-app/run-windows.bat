@echo off
echo ===================================================
echo      INICIANDO QUINDIOFLIX (FRONT + BACKEND)       
echo ===================================================
echo Compilando y levantando Spring Boot...
echo La aplicacion estara disponible en http://localhost:8081
echo.
start http://localhost:8081
call mvnw clean spring-boot:run -Dspring-boot.run.profiles=demo
pause
