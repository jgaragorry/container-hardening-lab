#!/bin/bash

echo "==================================="
echo "🔒 DISTROLESS HARDENING VERIFICATION"
echo "==================================="

# Check container status
if docker ps | grep -q distroless-hardened-app; then
    echo "✅ Container is running"
else
    echo "❌ Container is not running"
    exit 1
fi

# Check read-only filesystem
RO=$(docker inspect distroless-hardened-app --format='{{.HostConfig.ReadonlyRootfs}}')
[ "$RO" = "true" ] && echo "✅ Read-only root filesystem" || echo "❌ Not read-only"

# Check capabilities
CAP_ADD=$(docker inspect distroless-hardened-app --format='{{.HostConfig.CapAdd}}')
CAP_DROP=$(docker inspect distroless-hardened-app --format='{{.HostConfig.CapDrop}}')
[ "$CAP_ADD" = "[CAP_NET_BIND_SERVICE]" ] && echo "✅ Limited capabilities (NET_BIND_SERVICE only)" || echo "⚠️ Capabilities: $CAP_ADD"
[ "$CAP_DROP" = "[ALL]" ] && echo "✅ All capabilities dropped" || echo "❌ Capabilities not fully dropped"

# Check memory limits
MEM=$(docker inspect distroless-hardened-app --format='{{.HostConfig.Memory}}')
[ "$MEM" -le 268435456 ] && echo "✅ Memory limit: 256MB" || echo "⚠️ Memory limit: $MEM"

# Check no shell access
if docker exec distroless-hardened-app ls 2>&1 | grep -q "executable file not found"; then
    echo "✅ No shell (true distroless)"
else
    echo "⚠️ Shell might be accessible"
fi

# Check application is responding - Ahora verificamos el dashboard o el health endpoint
if curl -s http://localhost:8080/ | grep -q "Distroless Secure Container"; then
    echo "✅ Application dashboard responding"
elif curl -s http://localhost:8080/health | grep -q "HEALTHY"; then
    echo "✅ Application health page responding"
else
    echo "⚠️ Application might be starting up, waiting 5 seconds..."
    sleep 5
    if curl -s http://localhost:8080/ | grep -q "Distroless"; then
        echo "✅ Application responding after wait"
    else
        echo "❌ Application not responding - Check logs: docker logs distroless-hardened-app"
    fi
fi

# Check health endpoint specifically
HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health)
if [ "$HEALTH_CHECK" = "200" ]; then
    echo "✅ Health endpoint accessible (HTTP $HEALTH_CHECK)"
else
    echo "⚠️ Health endpoint returned HTTP $HEALTH_CHECK"
fi

echo "==================================="
echo "✅ Hardening verification complete"
