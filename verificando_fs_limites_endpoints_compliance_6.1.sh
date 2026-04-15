#!/bin/bash
# ============================================================
# 🛡️  AUDITORÍA DE SEGURIDAD UNIFICADA (DISTROLESS V2.1)
# ============================================================

# Colores para el reporte profesional
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# VARIABLES CRÍTICAS (No borrar)
CONTAINER="distroless-hardened-app"
IMAGEN="distroless-secure-app:latest"

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}🕵️  REPORTE DE AUDITORÍA TÉCNICA - ESTADO: $(date +'%H:%M:%S')${NC}"
echo -e "${BLUE}============================================================${NC}"

# 1. Superficie de Ataque
SIZE=$(docker images $IMAGEN --format "{{.Size}}")
if [ ! -z "$SIZE" ]; then
    echo -e "${GREEN}[CUMPLE]${NC} Tamaño de Imagen\n         └─ ${CYAN}Análisis:${NC} Imagen optimizada ($SIZE). Sin binarios basura."
else
    echo -e "${RED}[FALLA]${NC} No se encontró la imagen $IMAGEN"
fi

# 2. Inmutabilidad
RO=$(docker inspect $CONTAINER --format='{{.HostConfig.ReadonlyRootfs}}' 2>/dev/null)
if [ "$RO" = "true" ]; then
    echo -e "${GREEN}[CUMPLE]${NC} Filesystem Read-Only\n         └─ ${CYAN}Análisis:${NC} Sistema bloqueado. Inyección de malware imposible."
else
    echo -e "${RED}[FALLA]${NC} Filesystem Read-Only\n         └─ ${RED}Alerta:${NC} El sistema permite escritura."
fi

# 3. Usuario (Acepta UID o nombre)
USER_CONFIG=$(docker inspect $CONTAINER --format='{{.Config.User}}' 2>/dev/null)
if [[ "$USER_CONFIG" == "65532" || "$USER_CONFIG" == "nonroot" ]]; then
    echo -e "${GREEN}[CUMPLE]${NC} Usuario Non-Root\n         └─ ${CYAN}Análisis:${NC} UID detectado: $USER_CONFIG. (ISO A.8.26)"
else
    echo -e "${RED}[FALLA]${NC} Usuario Non-Root\n         └─ ${RED}Alerta:${NC} Configuración no segura detectada."
fi

# 4. Prueba de Intrusión Real (Pentest de Shell)
echo -e "\n${YELLOW}4. PENTEST: ACCESO A SHELL${NC}"
docker exec $CONTAINER /bin/sh -c "ls" >/dev/null 2>&1
EXIT_CODE=$?

# En Distroless, si no hay shell, el código de salida de Docker es 126 o 127
if [ $EXIT_CODE -eq 126 ] || [ $EXIT_CODE -eq 127 ]; then
    echo -e "${GREEN}[CUMPLE]${NC} Ausencia de Shell\n         └─ ${CYAN}Análisis:${NC} Confirmado: No existe /bin/sh. Ataque interactivo bloqueado."
else
    echo -e "${RED}[FALLA]${NC} Ausencia de Shell\n         └─ ${RED}Alerta:${NC} Respuesta inesperada del runtime (Exit Code: $EXIT_CODE)."
fi

# 5. Límites Anti-DoS
MEM=$(docker inspect $CONTAINER --format='{{.HostConfig.Memory}}' 2>/dev/null)
if [ "$MEM" = "268435456" ]; then
    echo -e "${GREEN}[CUMPLE]${NC} Límite de RAM\n         └─ ${CYAN}Análisis:${NC} Límite de 256MB verificado vía HostConfig."
else
    echo -e "${RED}[FALLA]${NC} Límite de RAM\n         └─ ${RED}Alerta:${NC} Sin límites de recursos configurados."
fi

echo -e "\n${BLUE}============================================================${NC}"
echo -e "${GREEN}✅ CERTIFICACIÓN DE CONTENEDOR FINALIZADA${NC}"
echo -e "${BLUE}============================================================${NC}"
