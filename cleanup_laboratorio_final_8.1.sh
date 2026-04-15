#!/bin/bash
# ============================================================
# 🧹 PASO 8.1: CLEANUP CONTROLADO - SEGURIDAD SRE
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}🧹 FINAL CLEANUP: DOCKER DISTROLESS HARDENING LAB${NC}"
echo -e "${GREEN}============================================================${NC}"

# 1. Detener el contenedor
echo -e "\n${YELLOW}[1/5] Deteniendo contenedor...${NC}"
docker stop distroless-hardened-app 2>/dev/null && echo "   ✅ Detenido" || echo "   ⚠️  No estaba en ejecución"

# 2. Remover el contenedor
echo -e "\n${YELLOW}[2/5] Eliminando contenedor...${NC}"
docker rm distroless-hardened-app 2>/dev/null && echo "   ✅ Eliminado" || echo "   ⚠️  No se encontró el contenedor"

# 3. Remover la imagen construida
echo -e "\n${YELLOW}[3/5] Eliminando imagen del laboratorio...${NC}"
docker rmi distroless-secure-app:latest 2>/dev/null && echo "   ✅ Imagen eliminada" || echo "   ⚠️  La imagen ya no existía"

# 4. Limpieza de Redes y Volúmenes Huérfanos
echo -e "\n${YELLOW}[4/5] Limpiando redes y volúmenes huerfanos...${NC}"
docker network prune -f >/dev/null
docker volume prune -f >/dev/null
echo "   ✅ Limpieza de Docker completada"

# 5. Liberación de Puertos (Específico para WSL)
echo -e "\n${YELLOW}[5/5] Liberando puertos del sistema...${NC}"
if command -v fuser >/dev/null 2>&1; then
    fuser -k 8080/tcp >/dev/null 2>&1 && echo "   ✅ Puerto 8080 liberado" || echo "   ✅ Puerto 8080 ya estaba libre"
fi

echo -e "\n${GREEN}============================================================${NC}"
echo -e "${GREEN}✅ CLEANUP COMPLETADO CON ÉXITO${NC}"
echo -e "${YELLOW}📁 Nota: Tus scripts y reportes en ~/container-hardening-lab${NC}"
echo -e "${YELLOW}   permanecen intactos para tu portafolio.${NC}"
echo -e "${GREEN}============================================================${NC}"
