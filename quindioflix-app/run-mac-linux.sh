#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "==================================================="
echo "     INICIANDO QUINDIOFLIX (FRONT + BACKEND)       "
echo "==================================================="
echo "Levantando la aplicacion en http://localhost:8081"

# Liberar el puerto 8081 si quedo una instancia anterior
if command -v lsof >/dev/null 2>&1; then
  OLD_PID=$(lsof -ti :8081 2>/dev/null || true)
  if [ -n "$OLD_PID" ]; then
    echo "Deteniendo proceso anterior en el puerto 8081 (PID $OLD_PID)..."
    kill "$OLD_PID" 2>/dev/null || true
    sleep 2
  fi
fi

# Intentar abrir el navegador segun el OS
if which xdg-open > /dev/null 2>&1
then xdg-open http://localhost:8081
elif which open > /dev/null 2>&1
then open http://localhost:8081
fi

./mvnw clean spring-boot:run -Dspring-boot.run.profiles=demo
