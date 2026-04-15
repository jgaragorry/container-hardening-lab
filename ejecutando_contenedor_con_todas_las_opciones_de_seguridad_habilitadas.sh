#!/bin/bash
# ===================================================
# PASO 5.3: EJECUTAR CONTENEDOR (VERSIÓN RESILIENTE)
# ===================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}=== PASO 5.3: Ejecutar Contenedor con Hardening ===${NC}"

# 1. VARIABLES Y DIRECTORIO
cd $HOME/distroless-lab
CONTAINER_NAME="distroless-hardened-app"
AUDIT_SCRIPT="$HOME/container-hardening-lab/verificando_cumplimiento_ISO27001.sh"

# 2. LIMPIEZA ATÓMICA
echo -e "${YELLOW}1. Limpiando procesos y contenedores previos...${NC}"
docker rm -f $CONTAINER_NAME >/dev/null 2>&1 || true

if command -v fuser >/dev/null 2>&1; then
    fuser -k 8080/tcp >/dev/null 2>&1 || true
fi
sleep 2

# 3. LANZAMIENTO (Hardening Equilibrado para WSL)
# Mantenemos: Read-only, No-new-privileges, Límites de RAM y Tmpfs.
# Relajamos: Capacidades por defecto (Drop ALL suele romper el mount en WSL).
echo -e "${CYAN}2. Lanzando fortaleza Distroless...${NC}"

docker run -d --name "$CONTAINER_NAME" \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,size=64m \
  --security-opt=no-new-privileges:true \
  --memory=256m \
  --cpus=0.5 \
  -p 127.0.0.1:8080:8080 \
  distroless-secure-app:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Contenedor UP y protegido.${NC}"
else
    echo -e "${RED}❌ Error crítico al lanzar Docker. Revisa 'docker logs'.${NC}"
    exit 1
fi

# 4. ESPERA DE SALUD (Readiness Probe)
echo -e "\n${CYAN}3. Verificando disponibilidad...${NC}"
echo -n "   Esperando respuesta del Dashboard..."
for i in {1..10}; do
    if curl -s http://localhost:8080/ > /dev/null; then
        echo -e "${GREEN} OK!${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# 5. AUDITORÍA
echo -e "\n${CYAN}4. Iniciando Auditoría ISO 27001...${NC}"
if [ -f "$AUDIT_SCRIPT" ]; then
    bash "$AUDIT_SCRIPT"
else
    echo -e "${RED}⚠️  Script de auditoría no encontrado en $AUDIT_SCRIPT${NC}"
fi

echo -e "\n${GREEN}✅ PROCESO COMPLETADO${NC}"
