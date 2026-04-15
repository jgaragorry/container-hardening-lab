#!/bin/bash
# ============================================
# PASO 1.1: REMOVER INSTALACIONES PREVIAS
# ============================================

echo "=== PASO 1.1: Remover Instalaciones Previas ==="

# Desinstalar paquetes antiguos (si existen)
echo "1. Removiendo versiones antigas de Docker..."
sudo apt remove -y \
    docker \
    docker-engine \
    docker.io \
    containerd \
    runc 2>/dev/null || true

# Limpiar configuraciones residuales
echo "2. Limpiando configuraciones residuales..."
sudo rm -rf /var/lib/docker/ 2>/dev/null || true
sudo rm -rf /var/lib/containerd/ 2>/dev/null || true
sudo rm -rf /var/run/docker.sock 2>/dev/null || true

# Remover grupo docker si existe
sudo delgroup docker 2>/dev/null || true

echo "✅ Instalaciones previas removidas"
echo ""
echo "✅ PASO 1.1 COMPLETADO"
