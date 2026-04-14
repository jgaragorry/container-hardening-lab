#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔍 Verificando estado del contenedor...${NC}"

# Verificar contenedor
if docker ps | grep -q distroless-hardened-app; then
    echo -e "${GREEN}✅ Contenedor activo${NC}"
else
    echo -e "${RED}❌ Contenedor no está corriendo${NC}"
    exit 1
fi

# Verificar dashboard
if curl -s http://localhost:8080/ | grep -q "Distroless"; then
    echo -e "${GREEN}✅ Dashboard accesible (http://localhost:8080/)${NC}"
else
    echo -e "${RED}❌ Dashboard no responde${NC}"
fi

# Verificar health endpoint
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Health endpoint OK (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ Health endpoint falló (HTTP $HTTP_CODE)${NC}"
fi

# Verificar API metrics
if curl -s http://localhost:8080/api/metrics | grep -q "container_id"; then
    echo -e "${GREEN}✅ API metrics endpoint OK${NC}"
else
    echo -e "${RED}❌ API metrics endpoint falló${NC}"
fi

echo -e "\n${YELLOW}📊 Resumen:${NC}"
echo -e "   Dashboard:  ${GREEN}http://localhost:8080/${NC}"
echo -e "   Health:     ${GREEN}http://localhost:8080/health${NC}"
echo -e "   Metrics:    ${GREEN}http://localhost:8080/api/metrics${NC}"
