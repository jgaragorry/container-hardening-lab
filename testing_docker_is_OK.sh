#!/bin/bash
# ============================================
# PASO 1.4: PROBAR INSTALACIÓN (AUTO-REPARABLE)
# ============================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- AUTO-ELEVACIÓN DE GRUPO ---
# Si el usuario es parte del grupo docker pero no tiene permisos activos, 
# relanzamos el script usando 'sg' para este proceso.
if ! docker ps > /dev/null 2>&1; then
    if groups $USER | grep &>/dev/null "\bdocker\b"; then
        echo -e "${YELLOW}🔄 Refrescando permisos de grupo para el usuario '$USER'...${NC}"
        exec sg docker "$0"
    fi
fi

echo -e "${GREEN}=== PASO 1.4: Probar Instalación de Docker ===${NC}"

# 1. Verificar si el servicio está corriendo
if ! systemctl is-active --quiet docker; then
    echo -e "${YELLOW}⚠️ El servicio Docker no está corriendo. Intentando iniciar...${NC}"
    sudo systemctl start docker
    sleep 2
fi

# 2. Test hello-world
echo "1. Ejecutando hello-world..."
if docker run --rm hello-world > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Test hello-world exitoso${NC}"
else
    echo -e "${RED}❌ Error crítico: No se puede comunicar con Docker.${NC}"
    echo "Revisa si el socket /var/run/docker.sock tiene permisos de lectura/escritura."
    exit 1
fi

# 3. Información del sistema (Corregido el formato de llaves)
echo -e "\n${GREEN}2. Información del sistema Docker...${NC}"
docker info --format '
CPU Count: {{.NCPU}}
Memory: {{.MemTotal}}
Storage Driver: {{.Driver}}
Kernel Version: {{.KernelVersion}}
Operating System: {{.OperatingSystem}}'

# 4. Opciones de seguridad (Esencial para el Hardening Lab)
echo -e "\n${GREEN}3. Verificando opciones de seguridad...${NC}"
docker info 2>/dev/null | grep -A 4 "Security Options" || echo "No disponible"

# 5. Listar imágenes
echo -e "\n${GREEN}4. Imágenes disponibles:${NC}"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo -e "\n${GREEN}✅ PASO 1.4 COMPLETADO${NC}"
