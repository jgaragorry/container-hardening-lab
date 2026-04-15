#!/bin/bash
# ============================================
# PASO 1.2: INSTALAR DOCKER
# ============================================

echo "=== PASO 1.2: Instalar Docker desde Repositorio Oficial ==="

# 1. Crear directorio para claves
echo "1. Configurando clave GPG..."
sudo mkdir -p /etc/apt/keyrings

# 2. Descargar y agregar clave GPG oficial de Docker
echo "2. Descargando clave GPG de Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Verificar que la clave se agregó
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    echo "✅ Clave GPG instalada"
else
    echo "❌ Error: No se pudo descargar clave GPG"
    exit 1
fi

# 3. Configurar el repositorio
echo "3. Configurando repositorio Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Actualizar índice de paquetes
echo "4. Actualizando índice de paquetes..."
sudo apt update

# 5. Instalar Docker Engine, CLI y complementos
echo "5. Instalando Docker Engine y complementos..."
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo ""
echo "6. Verificando versiones instaladas..."
docker --version
docker compose version

echo ""
echo "✅ PASO 1.2 COMPLETADO"
