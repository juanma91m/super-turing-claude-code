#!/usr/bin/env bash
#
# install.sh — primer deploy de super-turing-claude-code hacia ~/.claude/ y
# registro de los MCP servers de esta fase (context7, playwright, stitch,
# engram) vía `claude mcp add-json --scope user`.
#
# Idempotente: correrlo de nuevo actualiza archivos gestionados (con backup
# de lo reemplazado) y no duplica MCP servers ya registrados. No toca nada
# fuera de lo gestionado por este repo (ver scripts/sync-claude-stack.sh).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.claude"

log() { printf '[claude-stack-install] %s\n' "$*"; }

log "Preparando estructura en $TARGET_DIR"
mkdir -p "$TARGET_DIR"/{agents,commands,skills,hooks,backups}

log "Sincronizando archivos gestionados (agents/commands/skills/hooks/CLAUDE.md)"
"$SCRIPT_DIR/scripts/sync-claude-stack.sh" --target-dir "$TARGET_DIR"

if ! command -v claude >/dev/null 2>&1; then
  log "ADVERTENCIA: no se encontró el CLI 'claude' en PATH — se omite el registro de MCP servers."
  log "Corré 'claude mcp add-json ...' manualmente después, o volvé a correr install.sh cuando 'claude' esté en PATH."
  exit 0
fi

mcp_already_registered() {
  local name="$1"
  claude mcp list 2>/dev/null | grep -q "^${name}:"
}

register_mcp() {
  local name="$1" template="$2"
  if mcp_already_registered "$name"; then
    log "MCP '$name' ya registrado, no se toca."
    return 0
  fi
  local json
  json="$(cat "$template")"
  json="${json//__HOME__/$HOME}"
  if [[ "$name" == "stitch" ]]; then
    local key_file="$HOME/.config/opencode/stitch-api-key"
    if [[ ! -f "$key_file" ]]; then
      log "ADVERTENCIA: no existe $key_file — se omite el registro de 'stitch'."
      return 0
    fi
    local key
    key="$(cat "$key_file")"
    json="${json//__STITCH_API_KEY__/$key}"
  fi
  log "Registrando MCP '$name' (scope user)"
  claude mcp add-json "$name" "$json" --scope user
}

register_mcp "context7" "$SCRIPT_DIR/base/mcp/context7.json"
register_mcp "playwright" "$SCRIPT_DIR/base/mcp/playwright.json"
register_mcp "stitch" "$SCRIPT_DIR/base/mcp/stitch.json"
register_mcp "engram" "$SCRIPT_DIR/addons/knowledge/mcp/engram.json"
register_mcp "codegraph" "$SCRIPT_DIR/addons/codegraph/mcp/codegraph.json"
register_mcp "atlassian-rovo" "$SCRIPT_DIR/addons/ticketing/mcp/atlassian-rovo.json"

log "Listo. Los subagentes/comandos/skills quedaron en $TARGET_DIR."
log "Puede ser necesario reiniciar la sesión de Claude Code activa para que tome los MCP servers nuevos."
