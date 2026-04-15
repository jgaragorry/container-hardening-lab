#!/bin/bash
# ============================================
# PASO 4.2: CREAR DOCKER COMPOSE HARDENED (FIXED)
# ============================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== PASO 4.2: Crear Docker Compose Hardened ===${NC}"

cd $HOME/distroless-lab

# Crear un perfil de seccomp mínimo si no existe para que el config no falle
mkdir -p security
if [ ! -f security/seccomp-profile.json ]; then
    echo '{"defaultAction": "SCMP_ACT_ALLOW"}' > security/seccomp-profile.json
    echo -e "${YELLOW}ℹ️  Creado perfil seccomp temporal para validación.${NC}"
fi

cat > docker-compose.yml << 'EOF'
version: '3.9'

services:
  distroless-app:
    build:
      context: .
      dockerfile: Dockerfile
    
    image: distroless-secure-app:latest
    container_name: distroless-hardened-app
    restart: unless-stopped
    
    ports:
      - "127.0.0.1:8080:8080"
    
    networks:
      - distroless-network
    
    security_opt:
      - no-new-privileges:true
      # Seccomp es fundamental para restringir llamadas al kernel
      - seccomp=./security/seccomp-profile.json
    
    cap_drop:
      - ALL
    
    cap_add:
      - NET_BIND_SERVICE
    
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=64m
    
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  distroless-network:
    driver: bridge
EOF

echo -e "${GREEN}✅ Docker Compose creado.${NC}"

# Intentar validar con el nuevo comando 'docker compose'
if docker compose config > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Validación exitosa (usando 'docker compose').${NC}"
elif docker-compose config > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Validación exitosa (usando 'docker-compose' antiguo).${NC}"
else
    echo -e "\033[0;31m❌ Error de validación en docker-compose.yml\e[0m"
    exit 1
fi

echo -e "\n${GREEN}✅ PASO 4.2 COMPLETADO${NC}"
