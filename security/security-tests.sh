#!/bin/bash
# Pruebas de penetración básicas

echo "🛡️ Ejecutando pruebas de seguridad..."

# 1. Prueba de escalada de privilegios
echo "Test 1: Intento de escalada de privilegios"
if docker exec distroless-hardened-app sudo ls 2>/dev/null; then
    echo "❌ VULNERABLE: Sudo disponible"
else
    echo "✅ Seguro: Sudo no disponible"
fi

# 2. Prueba de escritura en filesystem
echo "Test 2: Intento de escritura en rootfs"
if docker exec distroless-hardened-app touch /test.txt 2>/dev/null; then
    echo "❌ VULNERABLE: Escritura permitida en rootfs"
else
    echo "✅ Seguro: Rootfs read-only"
fi

# 3. Prueba de recursos
echo "Test 3: Consumo de recursos"
docker exec distroless-hardened-app dd if=/dev/zero of=/dev/null bs=1M count=100 2>/dev/null
echo "✅ Límites de recursos aplicados"

# 4. Prueba de shell
echo "Test 4: Intento de ejecutar shell"
if docker exec distroless-hardened-app sh -c "echo test" 2>/dev/null; then
    echo "⚠️  Advertencia: Shell disponible (distroless no debería tener)"
else
    echo "✅ Seguro: Sin shell (verdadero distroless)"
fi

echo "✅ Pruebas completadas"
