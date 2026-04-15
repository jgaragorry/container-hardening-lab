#!/bin/bash
# ============================================================
# 📄 PASO 6.3: GENERAR ARTEFACTO DE EVIDENCIA ISO 27001
# ============================================================

echo "=== PASO 6.3: Generando Reporte de Compliance (Evidencia) ==="

# Definimos la ruta del reporte en tu carpeta de labs
REPORT_DIR="$HOME/container-hardening-lab/reports"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/compliance-evidence-$(date +%Y%m%d-%H%M%S).txt"

# Generación del contenido del reporte
cat > "$REPORT_FILE" << EOF
============================================================
       EVIDENCIA DE CUMPLIMIENTO - SEGURIDAD SRE
       NORMA: ISO 27001:2022 (CONTENEDORES)
============================================================
Fecha de Generación : $(date)
Arquitecto Responsable: Juan Garagorry (SRE Senior)
Hostname            : $(hostname)
------------------------------------------------------------

[1] IDENTIFICACIÓN DEL ACTIVO
------------------------------------------------------------
Nombre Contenedor : $(docker inspect distroless-hardened-app --format='{{.Name}}' | sed 's/^\///')
ID Corto          : $(docker inspect distroless-hardened-app --format='{{.Id}}' | cut -c1-12)
Imagen Base       : $(docker inspect distroless-hardened-app --format='{{.Config.Image}}')
Estado Runtime    : $(docker inspect distroless-hardened-app --format='{{.State.Status}}')

[2] CONTROLES TÉCNICOS IMPLEMENTADOS
------------------------------------------------------------
A.8.8 (Vulnerabilidades Técnicas): 
    - EVIDENCIA: Imagen Distroless (Sin Gestor de Paquetes/Shell)
    - TAMAÑO IMAGEN: $(docker images distroless-secure-app:latest --format "{{.Size}}")

A.8.26 (Privilegios Mínimos):
    - EVIDENCIA: Capabilities Dropped: $(docker inspect distroless-hardened-app --format='{{.HostConfig.CapDrop}}')
    - USUARIO CONFIGURADO: $(docker inspect distroless-hardened-app --format='{{.Config.User}}')

A.8.27 (Arquitectura Segura):
    - EVIDENCIA: Read-only Filesystem: $(docker inspect distroless-hardened-app --format='{{.HostConfig.ReadonlyRootfs}}')
    - EVIDENCIA: No-New-Privileges: $(docker inspect distroless-hardened-app --format='{{.HostConfig.SecurityOpt}}')

[3] LÍMITES DE RECURSOS (ANTI-DOS)
------------------------------------------------------------
Memoria Límite : $(docker inspect distroless-hardened-app --format='{{.HostConfig.Memory}}' | awk '{print $1/1024/1024 " MB"}')
CPU Límite     : $(docker inspect distroless-hardened-app --format='{{.HostConfig.NanoCpus}}' | awk '{print $1/1000000000 " cores"}')

[4] VERIFICACIÓN DE DISPONIBILIDAD (HEALTH)
------------------------------------------------------------
Endpoint /       : $(curl -s -o /dev/null -w "HTTP %{http_code}" http://localhost:8080/)
Endpoint /health : $(curl -s -o /dev/null -w "HTTP %{http_code}" http://localhost:8080/health)

============================================================
             FIN DEL REPORTE DE CERTIFICACIÓN
============================================================
EOF

echo -e "\n✅ Artefacto de evidencia creado en: \n   $REPORT_FILE"
echo -e "\n--- VISTA PREVIA DEL REPORTE ---\n"
cat "$REPORT_FILE"
