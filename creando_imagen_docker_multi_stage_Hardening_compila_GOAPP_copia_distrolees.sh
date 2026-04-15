#!/bin/bash
# ============================================
# PASO 5.2: BUILD IMAGEN HARDENED (CORREGIDO)
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== PASO 5.2: Build Imagen Hardened ===${NC}"

cd $HOME/distroless-lab

echo "1. Construyendo imagen..."
echo "   ℹ️  Usando contexto: $(pwd)"
echo ""

# El punto (.) al final es CRÍTICO: indica el build context
docker build \
    -t distroless-secure-app:latest \
    -f Dockerfile \
    --no-cache \
    --progress=plain \
    . 2>&1 | tee build.log

# PIPESTATUS[0] captura el exit code de docker, no el de tee
BUILD_STATUS=${PIPESTATUS[0]}

if [ $BUILD_STATUS -eq 0 ]; then
    echo -e "\n${GREEN}✅ Build exitoso${NC}"
else
    echo -e "\n${RED}❌ Build falló${NC}"
    echo "Revisa el archivo build.log para más detalles."
    exit 1
fi

# Verificar imagen
echo -e "\n2. Verificando imagen creada..."
docker images distroless-secure-app:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Inspeccionar capas (Aquí veremos el beneficio de Distroless)
echo -e "\n3. Analizando capas (Diferencial de seguridad)..."
docker history distroless-secure-app:latest

echo -e "\n${GREEN}✅ PASO 5.2 COMPLETADO${NC}"
