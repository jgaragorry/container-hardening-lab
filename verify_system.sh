#!/bin/bash

# ============================================
# PASO 0.1: VERIFICACIÓN DE WSL Y SISTEMA (v2.0)
# ============================================

# Colores para mejor legibilidad
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== PASO 0.1: Verificación de WSL y Sistema ===${NC}"

# 1. Verificar si estamos en WSL (Detección interna y externa)
echo -n "1. Verificando entorno WSL 2... "
IS_WSL=false
if grep -qi "microsoft" /proc/version; then
    IS_WSL=true
    KERNEL_VER=$(uname -r)
    echo -e "${GREEN}✅ Detectado (Kernel: $KERNEL_VER)${NC}"
elif command -v wsl.exe > /dev/null 2>&1; then
    IS_WSL=true
    echo -e "${GREEN}✅ WSL detectado vía interoperabilidad${NC}"
else
    echo -e "${RED}❌ No se detecta entorno WSL${NC}"
    echo "⚠️  Este script debe ejecutarse dentro de Ubuntu en WSL."
    echo "Sugerencia: Ejecuta 'wsl' en tu PowerShell antes de lanzar el script."
    exit 1
fi

# 2. Verificar distribución de Linux
echo -n "2. Verificando distribución... "
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
        echo -e "${GREEN}✅ $PRETTY_NAME${NC}"
    else
        echo -e "${YELLOW}⚠️ $PRETTY_NAME (Se recomienda Ubuntu para este lab)${NC}"
    fi
else
    echo -e "${RED}❌ No se pudo identificar la distribución${NC}"
fi

# 3. Verificar recursos del sistema
echo -e "\n${GREEN}=== RECURSOS DEL SISTEMA ===${NC}"

# CPU
CORES=$(nproc)
echo -n "CPU Cores: $CORES "
if [ "$CORES" -ge 2 ]; then
    echo -e "${GREEN}✅ (Mín: 2, OK)${NC}"
else
    echo -e "${YELLOW}⚠️ (Mín: 2, Rendimiento bajo)${NC}"
fi

# RAM
RAM_TOTAL_GB=$(free -g | awk '/^Mem:/ {print $2}')
# Si free -g da 0 (menos de 1GB), usamos MB
if [ "$RAM_TOTAL_GB" -eq 0 ]; then
    RAM_TOTAL_GB=$(free -m | awk '/^Mem:/ {print int($2/1024)}')
fi

echo -n "RAM Total: ${RAM_TOTAL_GB}GB "
if [ "$RAM_TOTAL_GB" -ge 4 ]; then
    echo -e "${GREEN}✅ (Mín: 4GB, OK)${NC}"
else
    echo -e "${YELLOW}⚠️ (Mín: 4GB, El lab será lento)${NC}"
fi

# DISCO (Idempotencia: verificamos espacio disponible sin escribir nada)
DISK_FREE_GB=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
echo -n "Espacio en Disco: ${DISK_FREE_GB}GB disponibles "
if [ "$DISK_FREE_GB" -ge 20 ]; then
    echo -e "${GREEN}✅ (Mín: 20GB, OK)${NC}"
else
    echo -e "${RED}❌ (Insuficiente)${NC}"
    exit 1
fi

# 4. Verificar conectividad (Idempotente por naturaleza)
echo -n -e "\n5. Verificando Internet... "
if curl -s --connect-timeout 3 google.com > /dev/null; then
    echo -e "${GREEN}✅ Conectividad OK${NC}"
else
    echo -e "${RED}❌ Sin conexión (Requerida para instalar herramientas)${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ PASO 0.1 COMPLETADO CORRECTAMENTE${NC}"
