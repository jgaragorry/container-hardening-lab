#!/bin/bash
# ============================================================
# ✅ PASO 10: CHECKLIST FINAL DE VALIDACIÓN (SRE ADAPTED)
# ============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}✅ FINAL DEPLOYMENT CHECKLIST - MSI EDITION${NC}"
echo -e "${GREEN}==========================================${NC}"

CONTAINER="distroless-hardened-app"

CHECKS=(
    "Container running|docker ps | grep -q $CONTAINER"
    "Port accessible|curl -s -m 2 http://localhost:8080 > /dev/null"
    "Health endpoint|curl -s -m 2 http://localhost:8080/health | grep -q 'OK'"
    "Read-only FS|docker inspect $CONTAINER | grep -q '\"ReadonlyRootfs\": true'"
    "No shell (Security)|! docker exec $CONTAINER sh -c 'exit' > /dev/null 2>&1"
    "Memory limit|docker inspect $CONTAINER | grep -q '\"Memory\": 268435456'"
    "No new privileges|docker inspect $CONTAINER | grep -q 'no-new-privileges'"
    "Non-root user|docker inspect $CONTAINER | grep -q '\"User\": \"nonroot\"'"
    "Tmpfs /tmp mounted|docker inspect $CONTAINER | grep -q '\"/tmp\"'"
    "Minimal Distroless|docker inspect $CONTAINER | grep -q 'distroless-secure-app'"
)

PASSED=0
for check in "${CHECKS[@]}"; do
    NAME="${check%|*}"
    CMD="${check#*|}"
    
    echo -n "✓ $NAME... "
    # Usamos bash -c para evaluar comandos complejos como las negaciones (!)
    if bash -c "$CMD" > /dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌${NC}"
    fi
done

echo -e "\n========================================"
echo -e "Total Passed: $PASSED/10"
echo -e "========================================"

if [ $PASSED -eq 10 ]; then
    echo -e "${GREEN}🎉 LABORATORIO COMPLETADO EXITOSAMENTE${NC}"
    echo -e "✅ Estándares de seguridad SRE alcanzados."
else
    echo -e "${YELLOW}⚠️  Algunos checks fallaron.${NC}"
    echo -e "Tip: En WSL, 'Capabilities' y 'Seccomp' pueden variar."
fi
