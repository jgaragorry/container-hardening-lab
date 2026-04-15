# =============================================================
# STAGE 1: Build (Compilación estática)
# =============================================================
FROM golang:1.22-alpine3.19 AS builder

# Directorio de trabajo para compilación
WORKDIR /src

# Sincronizamos dependencias
COPY app/go.mod app/go.sum* ./
RUN go mod download

# Copiamos el código fuente
COPY app/*.go ./

# Hardening en compilación:
# -ldflags="-s -w": Elimina tablas de símbolos y debug (reduce tamaño)
# -extldflags "-static": Asegura que no dependa de librerías externas (CGO)
RUN go build -ldflags="-s -w -extldflags '-static'" \
    -trimpath \
    -o /distroless-app .

# =============================================================
# STAGE 2: Runtime (Imagen final ultra-segura)
# =============================================================
FROM gcr.io/distroless/static-debian12:nonroot

# Metadata del contenedor
LABEL maintainer="security-lab@example.com" \
      version="1.1.0" \
      description="SRE Hardened App - ISO 27001 Certified"

# Definimos el directorio de la aplicación
WORKDIR /app

# Copiamos el binario desde la raíz del builder al directorio /app/
COPY --from=builder --chown=nonroot:nonroot /distroless-app /app/distroless-app

# Puerto de escucha
EXPOSE 8080

# =============================================================
# 🩺 HEALTHCHECK CONFIGURATION
# =============================================================
# Usamos la ruta absoluta /app/distroless-app para evitar errores de PATH.
# Aumentamos el start-period a 10s para dar margen a WSL.
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 \
    CMD ["/app/distroless-app", "health"] || exit 1

# Usuario nonroot (UID 65532)
USER nonroot:nonroot

# Entrypoint usando ruta absoluta
ENTRYPOINT ["/app/distroless-app"]
