#!/bin/bash
# ============================================
# PASO 1.3: CONFIGURAR USUARIO Y PERMISOS
# ============================================

echo "=== PASO 1.3: Configurar Usuario y Permisos ==="

# 1. Crear grupo docker si no existe
echo "1. Creando grupo docker..."
sudo groupadd docker 2>/dev/null || true

# 2. Agregar usuario actual al grupo
echo "2. Agregando usuario al grupo docker..."
sudo usermod -aG docker $USER

# 3. Verificar
echo "3. Verificando membresía..."
if groups $USER | grep -q docker; then
    echo "✅ Usuario agregado al grupo docker"
else
    echo "⚠️ Usuario NO agregado aún (requiere logout/login)"
fi

# 4. Habilitar Docker al inicio
echo "4. Habilitando Docker al inicio del sistema..."
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker

# 5. Verificar estado
echo "5. Verificando estado del servicio..."
if sudo systemctl is-active --quiet docker; then
    echo "✅ Docker servicio activo"
else
    echo "❌ Docker servicio NO activo"
    exit 1
fi

echo ""
echo "⚠️  IMPORTANTE: Debes CERRAR SESIÓN y VOLVER A ENTRAR"
echo "    para que los cambios de permisos tengan efecto."
echo ""
echo "Alternativa temporal: ejecuta: newgrp docker"
echo ""
echo "✅ PASO 1.3 COMPLETADO"
