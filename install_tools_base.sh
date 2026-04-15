#!/bin/bash
# ============================================
# PASO 0.3: INSTALAR HERRAMIENTAS BASE (Mejorado)
# ============================================

set -e # Salir si hay errores críticos

echo -e "\e[32m=== PASO 0.3: Instalar Herramientas Base ===\e[0m"

# Lista de paquetes a instalar
PACKAGES=(curl wget git jq tree net-tools htop ca-certificates gnupg lsb-release)

echo "Actualizando índices de paquetes..."
sudo apt update -qq

echo "Instalando paquetes: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

echo -e "\n=== VERIFICACIÓN DE HERRAMIENTAS ==="

# Función para verificar con lógica personalizada
verify_tool() {
    local tool=$1
    local check_cmd=$2
    
    if command -v "$check_cmd" &> /dev/null; then
        echo -e "✅ $tool: Instalado correctamente"
    else
        # Si no es un comando, verificamos si el paquete está en la base de datos de dpkg
        if dpkg -l | grep -qw "$tool"; then
            echo -e "✅ $tool: Paquete presente (Librería/Fondo)"
        else
            echo -e "❌ $tool: ERROR DE INSTALACIÓN"
        fi
    fi
}

# Verificaciones específicas
# tool_name binario_a_probar
verify_tool "curl" "curl"
verify_tool "wget" "wget"
verify_tool "git" "git"
verify_tool "jq" "jq"
verify_tool "tree" "tree"
verify_tool "net-tools" "ifconfig"  # net-tools provee ifconfig
verify_tool "htop" "htop"
verify_tool "ca-certificates" "update-ca-certificates" # comando de gestión
verify_tool "gnupg" "gpg"            # el binario es gpg
verify_tool "lsb-release" "lsb_release" # el binario tiene guion bajo

echo -e "\n\e[32m✅ PASO 0.3 COMPLETADO\e[0m"
