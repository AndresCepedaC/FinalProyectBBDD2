#!/bin/bash

# =====================================================
# QuindioFlix - Script de Arranque Automático (Modo Demo)
# =====================================================
# Este script levanta el backend con un perfil H2 en memoria,
# espera a que esté listo y abre la interfaz web automáticamente.

echo -e "\n🎬 Iniciando QuindioFlix (Modo Demo H2)...\n"

# 1. Definir variables
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$PROJECT_DIR/quindioflix-app"
# Vamos a usar el puerto 8080, pero primero lo limpiamos.
PORT=8080
echo "🔍 Verificando estado del puerto $PORT..."

# Matar cualquier proceso usando el puerto
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "🧹 El puerto $PORT está ocupado. Forzando su liberación (matando proceso)..."
    lsof -Pi :$PORT -sTCP:LISTEN -t | xargs kill -9
    sleep 2 # Dar tiempo para liberar el socket
fi

# Si de todas formas sigue ocupado (ej. no tenemos permisos), buscamos el siguiente libre
while lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; do
    echo "⚠️ No se pudo liberar el puerto $PORT. Probando puerto $((PORT+1))..."
    PORT=$((PORT+1))
done

echo "✅ Usando el puerto libre: $PORT"

URL="http://localhost:$PORT"
PID_FILE="$APP_DIR/backend.pid"

# Limpiar procesos anteriores si los hay
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "🧹 Deteniendo instancia anterior del script (PID: $OLD_PID)..."
        kill -9 $OLD_PID 2>/dev/null
    fi
    rm -f "$PID_FILE"
fi

cd "$APP_DIR" || exit 1

# 2. Verificar Maven Wrapper
if [ ! -f "./mvnw" ]; then
    echo "📦 Generando Maven Wrapper..."
    # Intenta usar docker si mvn no esta instalado
    if ! command -v mvn &> /dev/null && command -v docker &> /dev/null; then
        docker run --rm -v "$PWD":/app -w /app maven:3.9-eclipse-temurin-17 mvn wrapper:wrapper >/dev/null 2>&1
    else
        mvn wrapper:wrapper >/dev/null 2>&1
    fi
    chmod +x mvnw
fi

# 3. Compilar el proyecto (silencioso)
echo "🔨 Compilando el proyecto..."
./mvnw clean package -DskipTests > build.log 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Error de compilación. Revisa build.log"
    exit 1
fi
echo "✅ Compilación exitosa."

# 4. Iniciar Spring Boot en segundo plano (con perfil demo)
echo "🚀 Iniciando servidor backend..."
./mvnw spring-boot:run -Dspring-boot.run.profiles=demo -Dspring-boot.run.jvmArguments="-Dserver.port=$PORT" > backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > "$PID_FILE"

# 5. Polling (Espera activa) hasta que el servidor responda
echo "⏳ Esperando a que el servidor esté listo en el puerto $PORT..."
MAX_INTENTOS=60
INTENTO=0
SERVER_READY=false

while [ $INTENTO -lt $MAX_INTENTOS ]; do
    if curl -s -o /dev/null -w "%{http_code}" "$URL/actuator/health" | grep -q "200"; then
        SERVER_READY=true
        break
    fi
    # También verificar si la raiz HTML responde
    if curl -s -o /dev/null -w "%{http_code}" "$URL/" | grep -q "200"; then
        SERVER_READY=true
        break
    fi
    
    printf "."
    sleep 1
    INTENTO=$((INTENTO+1))
done

echo "" # Nueva linea

if [ "$SERVER_READY" = true ]; then
    echo -e "✅ Servidor Listo!\n"
    echo "🌟 Abriendo QuindioFlix en el navegador..."
    
    # Redirección a la interfaz (Comando adaptado para macOS)
    open "$URL/"
    
    echo "--------------------------------------------------------"
    echo "Servidor corriendo en segundo plano (PID: $BACKEND_PID)."
    echo "Para detenerlo, presiona Ctrl+C o ejecuta: kill $BACKEND_PID"
    echo "--------------------------------------------------------"
    
    # Mantener el script corriendo para capturar Ctrl+C
    trap "echo -e '\n🛑 Deteniendo servidor...'; kill $BACKEND_PID; rm -f $PID_FILE; exit 0" SIGINT SIGTERM
    wait $BACKEND_PID
else
    echo "❌ El servidor no inició a tiempo o falló."
    echo "Revisa el archivo quindioflix-app/backend.log para más detalles."
    kill $BACKEND_PID 2>/dev/null
    rm -f "$PID_FILE"
    exit 1
fi
