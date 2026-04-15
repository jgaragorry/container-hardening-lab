#!/bin/bash
# ============================================
# PASO 3.3: DOCUMENTAR DIRECTIVAS (FIXED)
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== PASO 3.3: Crear Documentación de Seguridad ===${NC}"

# Definir y asegurar rutas
BASE_DIR="$HOME/distroless-lab"
SEC_DIR="$BASE_DIR/security"

# Idempotencia: Asegurar que el directorio existe
mkdir -p "$SEC_DIR"

cat > "$SEC_DIR/dockerfile-explanation.md" << 'EOF'
# 🔒 Explicación de Directivas de Seguridad en Dockerfile

## STAGE 1: Builder (golang:1.22-alpine3.19)

### CGO_ENABLED=0
**¿Qué hace?** Deshabilita CGO (C bindings en Go)
**¿Por qué?** - Elimina dependencias en libc. Build completamente estático.
- Sin vulnerabilidades de librerías C dinámicas.

### -ldflags="-s -w"
**¿Qué hace?** Elimina símbolos y debug info.
**¿Por qué?** Reduce tamaño y dificulta la ingeniería inversa.

### -trimpath
**¿Qué hace?** Remueve rutas absolutas del binario de la máquina donde se compiló.

---

## STAGE 2: Runtime (distroless/static-debian12:nonroot)

### Base Image: distroless/static
**¿Qué hace?** Imagen sin shell ni utilidades (ls, cd, apt, etc).
**¿Por qué?** Reduce la superficie de ataque drásticamente. Si un atacante entra, no tiene herramientas.

### Tag: :nonroot
**¿Qué hace?** Corre como UID 65532.
**¿Por qué?** Principio de menor privilegio. No puede escalar a root en el host.

### HEALTHCHECK
**¿Qué hace?** Define cómo Docker sabe si la app vive.
**¿Por qué?** Permite auto-recuperación sin intervención manual.

EOF

# Verificación real
if [ -f "$SEC_DIR/dockerfile-explanation.md" ]; then
    echo -e "${GREEN}✅ Documentación creada en: $SEC_DIR/dockerfile-explanation.md${NC}"
    echo -e "\n--- VISTA PREVIA ---"
    head -n 5 "$SEC_DIR/dockerfile-explanation.md"
else
    echo -e "${RED}❌ Error al crear el archivo de documentación.${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ PASO 3.3 COMPLETADO${NC}"
