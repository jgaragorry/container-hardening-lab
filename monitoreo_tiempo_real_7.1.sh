#!/bin/bash
# ============================================================
# 📊 PASO 7.1: MONITOR SRE PRO (EDICIÓN RESILIENTE)
# ============================================================

CONTAINER="distroless-hardened-app"
URL="http://localhost:8080"

# Verificar si el contenedor existe
if ! docker ps -a | grep -q "$CONTAINER"; then
    echo -e "\033[0;31m❌ Error: El contenedor $CONTAINER no existe.\033[0m"
    exit 1
fi

while true; do
    clear
    echo -e "\033[0;34m============================================================\033[0m"
    echo -e "\033[1;36m🛡️  SRE OPERATIONAL DASHBOARD | $CONTAINER\033[0m"
    echo -e "\033[0;34m============================================================\033[0m"
    echo -e "🕒 Hora: $(date '+%H:%M:%S') | Host: $(hostname) | Senior: Juan Garagorry"
    
    # 1. LÓGICA DE SALUD SRE (Validación Real vs Docker Report)
    echo -e "\n\033[1;33m🩺 ESTADO DE SALUD OPERATIVA:\033[0m"
    
    # Obtenemos el HTTP Code del health check
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL/health" --max-time 2)
    # Obtenemos el reporte del motor Docker
    DOCKER_REPORT=$(docker inspect $CONTAINER --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")

    if [ "$HTTP_CODE" == "200" ]; then
        echo -e "   Servicio HTTP  : \033[0;32m● ONLINE (200 OK)\033[0m"
        echo -e "   Estado Global  : \033[1;32m✔ HEALTHY\033[0m"
    else
        echo -e "   Servicio HTTP  : \033[0;31m● OFFLINE (Code: $HTTP_CODE)\033[0m"
        echo -e "   Estado Global  : \033[1;31m✖ CRITICAL\033[0m"
    fi
    echo -e "   Docker Engine  : \033[0;37m$DOCKER_REPORT (Internal View)\033[0m"

    # 2. CONSUMO DE RECURSOS (Métricas de Oro)
    echo -e "\n\033[1;33m💾 MÉTRICAS DE RECURSOS (Hardened):\033[0m"
    docker stats $CONTAINER --no-stream --format "   CPU: {{.CPUPerc}} | RAM: {{.MemUsage}} | Net: {{.NetIO}}"

    # 3. VERIFICACIÓN DE ENDPOINTS (Integridad)
    echo -e "\n\033[1;33m🌐 INTEGRIDAD DE ENDPOINTS:\033[0m"
    for path in "/" "/health"; do
        CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL$path" --max-time 2)
        [ "$CODE" == "200" ] && STATUS="\033[0;32mPASS\033[0m" || STATUS="\033[0;31mFAIL\033[0m"
        echo -e "   $path -> [ $STATUS ] HTTP $CODE"
    done

    # 4. LOGS DE SEGURIDAD (Runtime)
    echo -e "\n\033[1;33m📋 AUDITORÍA DE LOGS (Últimos 3):\033[0m"
    docker logs --tail 3 $CONTAINER 2>/dev/null | sed 's/^/   /'

    echo -e "\n\033[0;34m============================================================\033[0m"
    echo -e "Refrescando cada 5s... (Presiona Ctrl+C para salir)"
    sleep 5
done
