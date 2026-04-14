#!/bin/bash
set -e

echo "🚀 Desplegando laboratorio distroless hardened..."

# Crear directorios necesarios
mkdir -p security

# Limpiar contenedores previos
docker compose down 2>/dev/null || true

# Construir imagen
echo "📦 Construyendo imagen distroless..."
docker compose build --no-cache

# Escanear vulnerabilidades
echo "🔍 Escaneando vulnerabilidades con Trivy (si está instalado)..."
if command -v trivy &> /dev/null; then
    trivy image --severity HIGH,CRITICAL --no-progress distroless-secure-app:latest
else
    echo "⚠️  Trivy no instalado. Instalar con: sudo apt install trivy"
fi

# Ejecutar contenedor
echo "🐳 Iniciando contenedor hardened..."
docker compose up -d

# Esperar a que esté listo
sleep 5

# Verificar hardening
echo ""
echo "🔒 Verificando hardening..."
./security/hardening-check.sh

# Probar aplicación
echo ""
echo "🧪 Probando aplicación:"
curl -s http://localhost:8080/
echo ""
curl -s http://localhost:8080/health
echo ""

# Mostrar logs
echo ""
echo "📋 Logs del contenedor:"
docker logs distroless-hardened-app

echo ""
echo "✅ Laboratorio listo!"
echo "📝 Comandos útiles:"
echo "  - Ver logs: docker logs -f distroless-hardened-app"
echo "  - Monitoreo: ./security/monitor.sh"
echo "  - Detener: docker compose down"
echo "  - Hardening check: ./security/hardening-check.sh"
