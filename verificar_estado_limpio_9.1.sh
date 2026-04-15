#!/bin/bash
# ============================================================
# 🔍 PASO 9.1: VERIFICACIÓN DE ESTADO LIMPIO Y REPETIBILIDAD
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}🔍 AUDITORÍA DE ESTADO POST-LABORATORIO${NC}"
echo -e "${GREEN}============================================================${NC}"

# 1. Verificación de Artefactos de Runtime (Docker)
echo -e "${CYAN}1. Verificando Recursos de Docker:${NC}"
CONTAINERS=$(docker ps -a --filter "name=distroless" -q | wc -l)
if [ "$CONTAINERS" -eq 0 ]; then
    echo -e "   ${GREEN}✅ No hay contenedores activos o huérfanos.${NC}"
else
    echo -e "   ${RED}⚠️  Atención: Quedan $CONTAINERS contenedores con el nombre 'distroless'.${NC}"
fi

IMAGES=$(docker images --filter "reference=distroless*" -q | wc -l)
if [ "$IMAGES" -eq 0 ]; then
    echo -e "   ${GREEN}✅ No hay imágenes locales del laboratorio.${NC}"
else
    echo -e "   ${YELLOW}⚠️  Quedan $IMAGES imágenes de distroless en el registro local.${NC}"
fi

# 2. Verificación de Integridad de Configuración (Blueprint)
echo -e "\n${CYAN}2. Verificando Archivos de Configuración (Blueprints):${NC}"
FILES=(
    "Dockerfile"
    "app/main.go"
    "ejecutando_contenedor_con_todas_las_opciones_de_seguridad_habilitadas.sh"
    "monitoreo_tiempo_real_7.1.sh"
    "verificando_cumplimiento_ISO27001.sh"
    "generar_evidencia_compliance_6.3.sh"
)

for file in "${FILES[@]}"; do
    if [ -f "$HOME/container-hardening-lab/$file" ]; then
        echo -e "   ${GREEN}✅ $file [PRESENTE]${NC}"
    else
        echo -e "   ${RED}❌ $file [FALTANTE]${NC}"
    fi
done

# 3. Estado Final
echo -e "\n${GREEN}============================================================${NC}"
if [ "$CONTAINERS" -eq 0 ] && [ "$IMAGES" -eq 0 ]; then
    echo -e "${GREEN}🎉 SISTEMA LISTO PARA REPETICIÓN LIMPIA (IDEMPOTENCIA)${NC}"
    echo -e "   Para iniciar de nuevo, ejecuta el script de construcción y luego"
    echo -e "   el de ejecución con hardening."
else
    echo -e "${YELLOW}⚠️  EL SISTEMA NO ESTÁ TOTALMENTE LIMPIO${NC}"
    echo -e "   Se recomienda ejecutar ./cleanup_laboratorio_final_8.1.sh antes."
fi
echo -e "${GREEN}============================================================${NC}"
