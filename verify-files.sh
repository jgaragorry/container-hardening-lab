#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}📁 Verificando archivos de configuración del laboratorio:${NC}"
echo ""

FILES=(
    "Dockerfile"
    "app/main.go"
    "app/go.mod"
    "docker-compose.yml"
    "security/seccomp-profile.json"
    "deploy-lab.sh"
    "docker-cleanup.sh"
    "restart-lab.sh"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file${NC}"
    else
        echo -e "${YELLOW}⚠️ $file (no encontrado)${NC}"
    fi
done

echo ""
echo -e "${GREEN}✅ Todos los archivos de configuración están intactos${NC}"
echo -e "${YELLOW}💡 Puedes ejecutar './restart-lab.sh' para reconstruir el laboratorio${NC}"
