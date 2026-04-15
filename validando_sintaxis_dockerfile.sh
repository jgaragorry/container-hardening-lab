#!/bin/bash
# ============================================
# PASO 3.2: VALIDAR DOCKERFILE (FIXED GREP)
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== PASO 3.2: Validar Dockerfile ===${NC}"

cd $HOME/distroless-lab

echo "1. Validando sintaxis..."
# Validamos existencia primero
if [ ! -f Dockerfile ]; then
    echo -e "${RED}❌ Error: No existe el archivo Dockerfile en $(pwd)${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dockerfile encontrado${NC}"

echo -e "\n2. Analizando cumplimiento de Hardening (Linter Manual)..."

# Usamos una estructura más limpia para evitar errores de escape en grep
declare -A CHECKS
CHECKS["FROM.*AS builder"]="Etapa de compilación (Multi-stage)"
CHECKS["FROM.*distroless"]="Imagen base segura (Distroless)"
CHECKS["CGO_ENABLED=0"]="Binario estático (No libc dependencies)"
CHECKS["GOOS=linux"]="Target OS (Linux)"
CHECKS["-ldflags"]="Stripping de símbolos (Security & Size)"
CHECKS["nonroot"]="Usuario no privilegiado (UID 65532)"
CHECKS["HEALTHCHECK"]="Monitoreo de salud (Docker Native)"

for pattern in "${!CHECKS[@]}"; do
    description=${CHECKS[$pattern]}
    # Usamos -e para el patrón y -- para separar el archivo, evitando errores con guiones
    if grep -Ei -e "$pattern" -- Dockerfile > /dev/null; then
        echo -e "${GREEN}✅ Found: $description${NC}"
    else
        echo -e "${YELLOW}⚠️  Missing: $description${NC}"
    fi
done

echo -e "\n3. Verificando integridad de contexto..."
if [ -d "app" ] && [ -f "app/main.go" ]; then
    echo -e "${GREEN}✅ Contexto 'app/main.go' listo${NC}"
else
    echo -e "${RED}❌ Error: Falta el código fuente en app/main.go${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ PASO 3.2 COMPLETADO CORRECTAMENTE${NC}"
