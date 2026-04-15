#!/bin/bash
# ============================================
# PASO 5.1: LIMPIAR RECURSOS PREVIOS
# ============================================

echo "=== PASO 5.1: Limpiar Recursos Previos ==="

# Stop and remove container
echo "1. Deteniendo contenedor previo..."
docker stop distroless-hardened-app 2>/dev/null || true
sleep 2

echo "2. Removiendo contenedor..."
docker rm distroless-hardened-app 2>/dev/null || true

echo "3. Removiendo imagen antiga..."
docker rmi distroless-secure-app:latest 2>/dev/null || true

echo "4. Limpiando dangling images..."
docker image prune -f 2>/dev/null || true

echo ""
echo "✅ PASO 5.1 COMPLETADO"
