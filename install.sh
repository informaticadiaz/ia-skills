#!/bin/bash

# ia-skills installer
# Instala skills de IA para Claude Code

set -e

REPO_URL="https://github.com/informaticadiaz/ia-skills.git"
INSTALL_DIR="$HOME/.claude/ia-skills"
COMMANDS_DIR="$HOME/.claude/commands"

echo "🎨 Instalando ia-skills..."

# Crear directorio de comandos si no existe
mkdir -p "$COMMANDS_DIR"

# Clonar o actualizar repo
if [ -d "$INSTALL_DIR" ]; then
    echo "📦 Actualizando ia-skills..."
    cd "$INSTALL_DIR"
    git pull --quiet
else
    echo "📦 Clonando ia-skills..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi

# Crear symlinks para cada skill
echo "🔗 Creando symlinks..."

# Skill: design
if [ -L "$COMMANDS_DIR/design.md" ]; then
    rm "$COMMANDS_DIR/design.md"
fi
ln -s "$INSTALL_DIR/skills/design/design.md" "$COMMANDS_DIR/design.md"
echo "   ✓ /design"

echo ""
echo "✅ Instalación completada!"
echo ""
echo "Skills disponibles:"
echo "   /design - Patrones UI de apps populares"
echo ""
echo "Uso: escribe /design en Claude Code"
