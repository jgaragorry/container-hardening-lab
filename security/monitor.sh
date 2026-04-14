#!/bin/bash
# Monitoreo continuo de seguridad

echo "📊 Monitoreo de seguridad - Presiona Ctrl+C para salir"
echo "==================================================="

while true; do
    clear
    echo "🕐 $(date)"
    echo ""
    
    # Verificar procesos sospechosos
    echo "🔍 Procesos en ejecución:"
    docker exec distroless-hardened-app ps aux 2>/dev/null || echo "  Solo el proceso principal"
    
    echo ""
    echo "🌐 Conexiones de red:"
    docker exec distroless-hardened-app netstat -tuln 2>/dev/null || echo "  Netstat no disponible (distroless)"
    
    echo ""
    echo "📈 Uso de recursos:"
    docker stats distroless-hardened-app --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    
    echo ""
    echo "📝 Logs recientes (últimas 5 líneas):"
    docker logs --tail 5 distroless-hardened-app 2>&1
    
    sleep 10
done
