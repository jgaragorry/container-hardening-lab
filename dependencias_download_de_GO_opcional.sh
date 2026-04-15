#!/bin/bash
# ============================================
# PASO 2.3: DESCARGAR DEPENDENCIAS GO (DOCKERIZED)
# ============================================

# Colores para feedback
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== PASO 2.3: Descargar/Validar Dependencias Go ===${NC}"

# Definir rutas
BASE_DIR="$HOME/distroless-lab"
APP_DIR="$BASE_DIR/app"

# Verificar que el directorio existe
if [ ! -d "$APP_DIR" ]; then
    echo -e "${YELLOW}⚠️ El directorio $APP_DIR no existe. Ejecuta primero el Paso 2.1 y 2.2.${NC}"
    exit 1
fi

echo "1. Validando módulo y dependencias vía Docker (golang:1.22)..."

# Ejecutamos Go dentro de un contenedor para mantener el host limpio
# -v: Monta tu código actual en /app dentro del contenedor
# -w: Establece el directorio de trabajo
docker run --rm \
    -v "$APP_DIR":/app \
    -w /app \
    golang:1.22-alpine \
    sh -c "go mod tidy && go list -m all"

# 2. Verificar resultados
echo -e "\n2. Verificando archivos de dependencias:"
if [ -f "$APP_DIR/go.sum" ]; then
    echo -e "${GREEN}✅ go.sum generado correctamente.${NC}"
    ls -l "$APP_DIR/go.sum"
else
    echo -e "${YELLOW}ℹ️  El proyecto no tiene dependencias externas adicionales (Standard Library únicamente).${NC}"
fi

# 3. Listar archivos finales en la carpeta app
echo -e "\n3. Estado actual de la carpeta app:"
ls -lh "$APP_DIR"

echo -e "\n${GREEN}✅ PASO 2.3 COMPLETADO${NC}"
