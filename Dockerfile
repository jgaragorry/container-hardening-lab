# Stage 1: Build - Imagen segura para compilar
FROM golang:1.22-alpine3.19 AS builder

# Hardening: Usuario no root para build
RUN addgroup -g 10001 -S appgroup && \
    adduser -u 10001 -S appuser -G appgroup

# Seguridad: Evitar cache y metadata
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOPROXY=https://proxy.golang.org,direct

WORKDIR /app

# Copiar solo lo necesario
COPY app/go.mod app/go.sum* ./
RUN go mod download

COPY app/*.go ./

# Compilar con flags de seguridad
RUN go build -ldflags="-s -w -extldflags '-static'" \
    -trimpath \
    -o /app/secure-app .

# Stage 2: Runtime - Distroless estático
FROM gcr.io/distroless/static-debian12:nonroot

# Metadata del contenedor
LABEL maintainer="security-lab@example.com" \
      version="1.0.0" \
      description="Secure distroless demo app" \
      security.privileged="false"

# Configuración de seguridad
WORKDIR /app

# Copiar binario desde builder
COPY --from=builder --chown=nonroot:nonroot /app/secure-app .

# Puerto de exposición (no root, >1024)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/app/secure-app", "health"] || exit 1

# Ejecutar como usuario nonroot (UID 65532)
USER nonroot:nonroot

# Entry point seguro
ENTRYPOINT ["/app/secure-app"]
