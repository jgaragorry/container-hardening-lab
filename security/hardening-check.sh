#!/bin/bash
# Script de verificación de hardening

echo "🔒 Verificando medidas de seguridad..."

# 1. Verificar usuario no root
if docker exec distroless-hardened-app whoami 2>/dev/null | grep -q "nonroot"; then
    echo "✅ Container ejecutándose como usuario no-root"
else
    echo "❌ Container ejecutándose como root"
fi

# 2. Verificar filesystem read-only
if docker inspect distroless-hardened-app | grep -q '"ReadonlyRootfs": true'; then
    echo "✅ Filesystem read-only configurado"
else
    echo "❌ Filesystem no es read-only"
fi

# 3. Verificar capacidades
CAPS=$(docker exec distroless-hardened-app cat /proc/1/status | grep CapEff)
if [ "$CAPS" = "CapEff:\t0000000000000000" ]; then
    echo "✅ Sin capacidades privilegiadas"
else
    echo "⚠️  Capacidades presentes: $CAPS"
fi

# 4. Verificar seccomp
SECCOMP=$(docker inspect distroless-hardened-app | grep -A5 "SecurityOpt")
if echo "$SECCOMP" | grep -q "seccomp"; then
    echo "✅ Perfil seccomp aplicado"
else
    echo "❌ Seccomp no configurado"
fi

# 5. Verificar límites de recursos
MEM_LIMIT=$(docker inspect distroless-hardened-app | grep -A2 "Memory" | grep -Eo '[0-9]+')
if [ "$MEM_LIMIT" -le 268435456 ]; then
    echo "✅ Límite de memoria configurado (max 256MB)"
else
    echo "⚠️  Límite de memoria no configurado"
fi

echo "✅ Verificación completada"
