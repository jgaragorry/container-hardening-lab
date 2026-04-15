#!/bin/bash
# ============================================
# PASO 2.1: CREAR ESTRUCTURA DE DIRECTORIOS
# ============================================

echo "=== PASO 2.1: Crear Estructura de Directorios ==="

# Crear directorio base
BASE_DIR="$HOME/distroless-lab"
echo "1. Creando directorio base: $BASE_DIR"
mkdir -p $BASE_DIR

# Crear subdirectorios
echo "2. Creando subdirectorios..."
mkdir -p $BASE_DIR/{app,security,scripts,tests,docs}

# Cambiar a directorio
cd $BASE_DIR
echo "3. Directorio actual: $(pwd)"

# Mostrar estructura
echo ""
echo "4. Estructura creada:"
tree -L 2 -a 2>/dev/null || find . -maxdepth 2 -type d | sort

echo ""
echo "✅ PASO 2.1 COMPLETADO"
