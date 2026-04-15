#!/bin/bash
# =================================================================
# 🛡️ ISO 27001:2022 Compliance Auditor for Containers (Hardened)
# =================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CONTAINER_NAME="distroless-hardened-app"

echo -e "${CYAN}======================================================${NC}"
echo -e "${CYAN}📋 REPORTE DE CUMPLIMIENTO ISO 27001 - DISTROLESS LAB${NC}"
echo -e "${CYAN}======================================================${NC}"

PASSED=0
FAILED=0

# Función para imprimir cabeceras de Dominio
print_domain() {
    echo -e "\n${BLUE}🔹 Dominio: $1${NC}"
    echo -e "${BLUE}------------------------------------------------------${NC}"
}

# Función de control mejorada
check_control() {
    local id=$1
    local name=$2
    local cmd=$3
    local desc=$4
    
    printf "%-10s | %-30s | " "$id" "$name"
    
    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}COMPLIANT${NC}"
        ((PASSED++))
    else
        echo -e "${RED}NON-COMPLIANT${NC}"
        echo -e "           └─ ${YELLOW}Tip: $desc${NC}"
        ((FAILED++))
    fi
}

# --- Ejecución de Auditoría ---

print_domain "A.8.8 Management of technical vulnerabilities"
check_control "A.8.8.1" "Minimal Base Image" \
    "docker inspect $CONTAINER_NAME | grep -qi distroless" \
    "Usar imágenes sin OS (distroless) para reducir CVEs."

check_control "A.8.8.2" "Attack Surface Reduction" \
    "[ \$(docker exec $CONTAINER_NAME ls /bin/sh 2>&1 | grep -c 'not found') -ge 1 ]" \
    "Eliminar shells e intérpretes innecesarios."

print_domain "A.8.25 Secure development life cycle"
check_control "A.8.25.1" "Immutable Build Stage" \
    "grep -q 'AS builder' Dockerfile" \
    "Implementar multi-stage builds para separar build de runtime."

print_domain "A.8.26 Application security requirements"
check_control "A.8.26.1" "Principle of Least Privilege" \
    "docker inspect $CONTAINER_NAME | grep -q '\"ALL\"'" \
    "Asegurar que CapDrop ALL esté en el docker-compose."

check_control "A.8.26.2" "Non-Root Execution" \
    "docker inspect $CONTAINER_NAME --format='{{.Config.User}}' | grep -Eq 'nonroot|65532'" \
    "El proceso debe correr con un UID > 0."

print_domain "A.8.27 Secure system architecture"
check_control "A.8.27.1" "Filesystem Immutability" \
    "[ \$(docker inspect $CONTAINER_NAME --format='{{.HostConfig.ReadonlyRootfs}}') = 'true' ]" \
    "Habilitar Read-only Root Filesystem."

check_control "A.8.27.2" "Memory Execution Protection" \
    "docker inspect $CONTAINER_NAME | grep -q 'noexec'" \
    "Configurar tmpfs con flag noexec."

print_domain "A.12.4 Logging and monitoring"
check_control "A.12.4.1" "Event Logging" \
    "docker inspect $CONTAINER_NAME | grep -q 'json-file'" \
    "Configurar drivers de log centralizables."

# --- Resumen Final ---
echo -e "\n${CYAN}======================================================${NC}"
echo -e "📊 RESUMEN EJECUTIVO:"
echo -e "   Controles Cumplidos:   ${GREEN}$PASSED${NC}"
echo -e "   Controles Fallidos:    ${RED}$FAILED${NC}"
echo -e "${CYAN}======================================================${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}Certificación Interna: APROBADA ✅${NC}"
else
    echo -e "${RED}Certificación Interna: RECHAZADA ❌${NC}"
    exit 1
fi
