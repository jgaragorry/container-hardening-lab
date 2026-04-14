#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🔄 Reiniciando Laboratorio Distroless${NC}"
echo -e "${BLUE}========================================${NC}"

# Paso 1: Cleanup de recursos Docker
echo -e "\n${YELLOW}[1/2] Limpiando recursos Docker existentes...${NC}"
./docker-cleanup.sh

# Paso 2: Reconstruir y desplegar
echo -e "\n${YELLOW}[2/2] Reconstruyendo y desplegando laboratorio...${NC}"
./deploy-lab.sh

echo -e "\n${GREEN}✅ Laboratorio reiniciado completamente!${NC}"
echo -e "${BLUE}🌐 Accede en: http://localhost:8080${NC}"
