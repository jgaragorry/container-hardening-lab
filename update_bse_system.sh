#!/bin/bash
# ============================================
# PASO 0.2: ACTUALIZAR SISTEMA BASE
# ============================================

echo "=== PASO 0.2: Actualizar Sistema Base ==="

# 1. Actualizar lista de repositorios
echo "1. Actualizando repositorios..."
sudo apt update

# Salida esperada:
# Hit:1 http://security.ubuntu.com/ubuntu jammy-security InRelease
# Get:2 http://archive.ubuntu.com/ubuntu jammy InRelease
# Reading package lists... Done

# 2. Actualizar paquetes existentes
echo "2. Actualizando paquetes existentes..."
sudo apt upgrade -y

# Salida esperada: "0 upgraded, 0 newly installed..."

# 3. Instalar actualizaciones de seguridad automáticas
echo "3. Configurando actualizaciones automáticas..."
sudo apt install -y unattended-upgrades

# 4. Limpiar paquetes obsoletos
echo "4. Limpiando paquetes obsoletos..."
sudo apt autoremove -y
sudo apt autoclean -y

# 5. Verificar si hay actualizaciones pendientes
echo ""
echo "5. Verificando estado final..."
UPDATES=$(apt list --upgradable 2>/dev/null | wc -l)
if [ $UPDATES -le 1 ]; then
    echo "✅ Sistema completamente actualizado"
else
    echo "⚠️ Aún hay $((UPDATES-1)) paquetes por actualizar"
fi

echo ""
echo "✅ PASO 0.2 COMPLETADO"
