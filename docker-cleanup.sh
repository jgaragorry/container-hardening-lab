#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🐳 Docker Distroless Lab - Resource Cleanup${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}📁 Manteniendo archivos de configuración en: ~/distroless-lab${NC}"
echo -e ""

# Function to print status
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# 1. Detener y eliminar contenedores
echo -e "${YELLOW}[1/5] Deteniendo y eliminando contenedores...${NC}"

# Detener contenedor específico si existe
if docker ps -a | grep -q distroless-hardened-app; then
    docker stop distroless-hardened-app 2>/dev/null && echo -e "   ${GREEN}✓ Contenedor detenido${NC}"
    docker rm distroless-hardened-app 2>/dev/null && echo -e "   ${GREEN}✓ Contenedor eliminado${NC}"
else
    echo -e "   ${YELLOW}⚠ Contenedor no existía${NC}"
fi

# Eliminar cualquier contenedor relacionado con distroless/secure-app
CONTAINERS=$(docker ps -a | grep -E "distroless|secure-app" | awk '{print $1}')
if [ -n "$CONTAINERS" ]; then
    echo "$CONTAINERS" | xargs docker rm -f 2>/dev/null
    echo -e "   ${GREEN}✓ Contenedores adicionales eliminados${NC}"
else
    echo -e "   ${YELLOW}⚠ No hay contenedores adicionales${NC}"
fi

print_status "Contenedores limpiados" "Problema al limpiar contenedores"

# 2. Eliminar imágenes
echo -e "\n${YELLOW}[2/5] Eliminando imágenes Docker...${NC}"

# Eliminar imagen específica
if docker images | grep -q distroless-secure-app; then
    docker rmi distroless-secure-app:latest -f 2>/dev/null
    echo -e "   ${GREEN}✓ Imagen distroless-secure-app eliminada${NC}"
else
    echo -e "   ${YELLOW}⚠ Imagen no existía${NC}"
fi

# Eliminar imágenes dangling (huérfanas)
DANGLING=$(docker images -f "dangling=true" -q)
if [ -n "$DANGLING" ]; then
    echo "$DANGLING" | xargs docker rmi -f 2>/dev/null
    echo -e "   ${GREEN}✓ Imágenes dangling eliminadas${NC}"
fi

print_status "Imágenes limpiadas" "No se pudieron limpiar todas las imágenes"

# 3. Limpiar volúmenes
echo -e "\n${YELLOW}[3/5] Eliminando volúmenes Docker...${NC}"

# Eliminar volúmenes no utilizados
docker volume prune -f 2>/dev/null

# Eliminar volúmenes específicos del lab si existen
VOLUMES=$(docker volume ls -q | grep -E "distroless")
if [ -n "$VOLUMES" ]; then
    echo "$VOLUMES" | xargs docker volume rm 2>/dev/null
    echo -e "   ${GREEN}✓ Volúmenes del lab eliminados${NC}"
else
    echo -e "   ${YELLOW}⚠ No hay volúmenes del lab${NC}"
fi

print_status "Volúmenes limpiados" "Problema al limpiar volúmenes"

# 4. Limpiar redes
echo -e "\n${YELLOW}[4/5] Eliminando redes Docker...${NC}"

# Eliminar redes no utilizadas
docker network prune -f 2>/dev/null

# Eliminar redes específicas del lab
NETWORKS=$(docker network ls -q | grep -E "distroless|secured-network")
if [ -n "$NETWORKS" ]; then
    echo "$NETWORKS" | xargs docker network rm 2>/dev/null
    echo -e "   ${GREEN}✓ Redes del lab eliminadas${NC}"
else
    echo -e "   ${YELLOW}⚠ No hay redes del lab${NC}"
fi

print_status "Redes limpiadas" "Problema al limpiar redes"

# 5. Limpiar build cache
echo -e "\n${YELLOW}[5/5] Limpiando cache de build...${NC}"
docker builder prune -f 2>/dev/null
docker buildx prune -f 2>/dev/null
print_status "Build cache limpiado" "Problema al limpiar cache"

# Resumen final
echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✨ Cleanup completado exitosamente!${NC}"
echo -e "${BLUE}========================================${NC}"

# Mostrar estado actual de recursos Docker
echo -e "\n${YELLOW}📊 Estado actual de recursos Docker:${NC}"
echo -e "   Contenedores activos: $(docker ps -q | wc -l)"
echo -e "   Contenedores totales: $(docker ps -a -q | wc -l)"
echo -e "   Imágenes en sistema: $(docker images -q | wc -l)"
echo -e "   Volúmenes en sistema: $(docker volume ls -q | wc -l)"
echo -e "   Redes en sistema: $(docker network ls -q | wc -l)"

echo -e "\n${GREEN}✅ Todos los recursos Docker del laboratorio han sido eliminados${NC}"
echo -e "${GREEN}📁 Tus archivos de configuración están intactos en: ~/distroless-lab${NC}"
echo -e ""
echo -e "${YELLOW}🚀 Para reconstruir el laboratorio:${NC}"
echo -e "   ./deploy-lab.sh"
echo -e "   O ejecuta los comandos manualmente:"
echo -e "   docker build -t distroless-secure-app:latest ."
echo -e "   docker run -d --name distroless-hardened-app ..."

# Contar cuántos recursos del lab quedan (debería ser 0)
REMAINING=$(docker ps -a | grep -E "distroless|secure-app" | wc -l)
if [ $REMAINING -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Verificación: No quedan recursos Docker del laboratorio${NC}"
else
    echo -e "\n${RED}⚠️ Advertencia: Aún quedan $REMAINING recursos del laboratorio${NC}"
    docker ps -a | grep -E "distroless|secure-app"
fi

