#!/bin/bash
# ============================================
# PASO 3.1: CREAR DOCKERFILE HARDENED
# ============================================

echo "=== PASO 3.1: Crear Dockerfile Hardened ==="

cd $HOME/distroless-lab

cat > Dockerfile << 'EOF'
# ============================================
# STAGE 1: Builder - Compilación segura
# ============================================
FROM golang:1.22-alpine3.19 AS builder

# Metadata para trazabilidad
LABEL stage=builder

# Security: Crear usuario no-root para compilación
RUN addgroup -g 10001 -S appgroup && \
    adduser -u 10001 -S appuser -G appgroup

# Security: Configurar Go para build estático y reproducible
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GO111MODULE=on \
    GOPROXY=https://proxy.golang.org,direct

WORKDIR /build

# Copy go.mod y go.sum primero (layer caching)
COPY app/go.mod app/go.sum* ./
RUN go mod download

# Copy código fuente
COPY app/*.go ./

# Build con flags de seguridad
# -ldflags="-s -w": Elimina tabla de símbolos y debug info (reduce tamaño)
# -ldflags="-extldflags '-static'": Link estático sin dependencias dinámicas
# -trimpath: Remueve rutas absolutas del binario (reproducible)
RUN go build \
    -ldflags="-s -w -extldflags '-static'" \
    -trimpath \
    -o distroless-app .

# Verificar que el binario fue creado
RUN test -f distroless-app || exit 1

# ============================================
# STAGE 2: Runtime - Distroless Hardened
# ============================================
FROM gcr.io/distroless/static-debian12:nonroot

# Metadata
LABEL maintainer="security-lab@example.com" \
      version="1.0.0" \
      description="Hardened Distroless Container" \
      security.capabilities="dropped:ALL,added:NET_BIND_SERVICE" \
      security.readonly="true" \
      security.user="nonroot:nonroot (UID 65532:65532)"

WORKDIR /app

# Copy binario desde builder con ownership correcto
COPY --from=builder --chown=nonroot:nonroot /build/distroless-app .

# Expose puerto no-privilegiado (>1024, no requiere root)
EXPOSE 8080

# Health check - verifica que la aplicación está respondiendo
# --interval: Verifica cada 30 segundos
# --timeout: Timeout de respuesta 3 segundos
# --start-period: Espera 5 segundos después de start
# --retries: 3 fallos consecutivos = unhealthy
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/app/distroless-app", "health"] || exit 1

# User distroless con UID:GID 65532:65532 (ya viene configurado)
# USER nonroot:nonroot  # Opcional, ya viene por defecto en :nonroot

# Entrypoint - ejecuta aplicación
ENTRYPOINT ["/app/distroless-app"]
EOF

# Verificar que el archivo fue creado
if [ -f Dockerfile ]; then
    echo "✅ Dockerfile creado"
    wc -l Dockerfile
else
    echo "❌ Error: Dockerfile no fue creado"
    exit 1
fi

echo ""
echo "✅ PASO 3.1 COMPLETADO"
