#!/usr/bin/env bash
#
# sync-claude-stack.sh — copia los archivos gestionados de este repo hacia
# ~/.claude/, con backup de lo que reemplaza. Mirror simplificado de
# sync-opencode-stack.sh (ver ~/.local/src/opencode-stack/scripts/), sin la
# mecánica de merge aditivo (no aplica en fase 1: no hay archivos compartidos
# entre "base" y "knowledge" acá).
#
# Nunca toca nada fuera de la lista de archivos gestionados: no borra ni
# modifica ~/.claude/projects, ~/.claude/sessions, ~/.claude/credentials,
# ~/.claude/settings.json (salvo la clave "hooks", que se mergea sin tocar
# el resto de las claves existentes).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="${HOME}/.claude"
DRY_RUN=0
STATUS_ONLY=0
BACKUP_ROOT="${TARGET_DIR}/backups/claude-stack-sync"
RETENTION=5

TO_CREATE=()
TO_UPDATE=()
TO_REMOVE=()
UNCHANGED=()
OBSOLETE_TARGETS=()

usage() {
  cat <<'EOF'
Usage: sync-claude-stack.sh [options]

Options:
  --target-dir <path>   Directorio destino (default: ~/.claude)
  --dry-run             Muestra qué se sincronizaría sin escribir nada
  --status               Solo reporta diferencias, no sincroniza
  -h, --help             Ayuda
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-dir) TARGET_DIR="$2"; BACKUP_ROOT="${TARGET_DIR}/backups/claude-stack-sync"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --status) STATUS_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opción desconocida: $1" >&2; usage; exit 1 ;;
  esac
done

log() { printf '[claude-stack-sync] %s\n' "$*"; }

# --- lista de archivos gestionados: (origen relativo al repo -> destino relativo a TARGET_DIR)
MANAGED_PAIRS=()
collect_pairs() {
  local src_root="$1" src_glob="$2" dst_prefix="$3"
  local f rel
  while IFS= read -r -d '' f; do
    rel="${f#"$SOURCE_DIR/$src_root/"}"
    MANAGED_PAIRS+=("$src_root/$rel|$dst_prefix/$rel")
  done < <(find "$SOURCE_DIR/$src_root" \( -type f -o -type l \) -name "$src_glob" -print0 2>/dev/null)
}

collect_pairs "base/agents" "*.md" "agents"
collect_pairs "base/commands" "*.md" "commands"
collect_pairs "base/skills" "SKILL.md" "skills"
collect_pairs "base/hooks" "*.sh" "hooks"
collect_pairs "addons/knowledge/agents" "*.md" "agents"
collect_pairs "addons/knowledge/commands" "*.md" "commands"
collect_pairs "addons/knowledge/skills" "SKILL.md" "skills"
collect_pairs "addons/knowledge/hooks" "*.sh" "hooks"
collect_pairs "addons/codegraph/commands" "*.md" "commands"
collect_pairs "addons/codegraph/skills" "SKILL.md" "skills"
collect_pairs "addons/ticketing/commands" "*.md" "commands"
collect_pairs "addons/ticketing/skills" "SKILL.md" "skills"
collect_pairs "addons/documents/commands" "*.md" "commands"
collect_pairs "addons/documents/skills" "SKILL.md" "skills"
collect_pairs "addons/github-accounts-local/skills" "SKILL.md" "skills"
collect_pairs "addons/higyrus-workspace/skills" "SKILL.md" "skills"
MANAGED_PAIRS+=("base/CLAUDE.md|CLAUDE.md")

mapfile -t OBSOLETE_TARGETS < <(
  python3 - "$SOURCE_DIR/STACK-MANIFEST.json" <<'PY'
import json
import pathlib
import sys

data = json.loads(pathlib.Path(sys.argv[1]).read_text())
for item in data.get("obsoleteTargets", []):
    print(item)
PY
)

# --- snippets a mergear en settings.json (claves "hooks" y "permissions",
# preservando cualquier otra clave existente, ej. "theme").
SETTINGS_SNIPPETS=()
while IFS= read -r -d '' f; do
  SETTINGS_SNIPPETS+=("$f")
done < <(find "$SOURCE_DIR/base" "$SOURCE_DIR/addons" -type f -name "*.snippet.json" -print0 2>/dev/null | sort -z)

backup_file() {
  local target="$1" rel="$2"
  local ts
  ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local dest="$BACKUP_ROOT/$ts/$rel"
  mkdir -p "$(dirname "$dest")"
  cp -p "$target" "$dest"
}

prune_backups() {
  [[ -d "$BACKUP_ROOT" ]] || return 0
  local snapshots
  mapfile -t snapshots < <(find "$BACKUP_ROOT" -maxdepth 1 -mindepth 1 -type d | sort)
  local count=${#snapshots[@]}
  if (( count > RETENTION )); then
    local excess=$(( count - RETENTION ))
    for ((i=0; i<excess; i++)); do
      rm -rf "${snapshots[$i]}"
    done
  fi
}

sync_file() {
  local src="$SOURCE_DIR/${1%%|*}"
  local dst="$TARGET_DIR/${1##*|}"
  local rel="${1##*|}"

  # Si el archivo fuente es en sí un symlink (ej. hacia ~/.config/opencode/skills/...),
  # replicamos un symlink real en destino apuntando al mismo target absoluto, en vez de
  # copiar contenido — así el destino queda "vivo" y no una foto del momento del sync.
  if [[ -L "$src" ]]; then
    local target
    target="$(readlink -f "$src")"
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$target" ]]; then
      UNCHANGED+=("$rel")
      return 0
    fi
    if [[ ! -e "$dst" ]]; then
      TO_CREATE+=("$rel")
      (( STATUS_ONLY )) && return 0
      (( DRY_RUN )) && { log "[dry-run] symlink $rel -> $target"; return 0; }
      mkdir -p "$(dirname "$dst")"
      ln -s "$target" "$dst"
      return 0
    fi
    TO_UPDATE+=("$rel")
    (( STATUS_ONLY )) && return 0
    (( DRY_RUN )) && { log "[dry-run] re-symlink $rel -> $target"; return 0; }
    backup_file "$dst" "$rel"
    rm -f "$dst"
    ln -s "$target" "$dst"
    return 0
  fi

  if [[ ! -f "$dst" ]]; then
    TO_CREATE+=("$rel")
    (( STATUS_ONLY )) && return 0
    (( DRY_RUN )) && { log "[dry-run] crear $rel"; return 0; }
    mkdir -p "$(dirname "$dst")"
    cp -p "$src" "$dst"
    return 0
  fi

  if cmp -s "$src" "$dst"; then
    UNCHANGED+=("$rel")
    return 0
  fi

  TO_UPDATE+=("$rel")
  (( STATUS_ONLY )) && return 0
  (( DRY_RUN )) && { log "[dry-run] actualizar $rel"; return 0; }
  backup_file "$dst" "$rel"
  cp -p "$src" "$dst"
}

merge_settings_snippets() {
  local settings="$TARGET_DIR/settings.json"
  (( STATUS_ONLY )) && return 0
  (( ${#SETTINGS_SNIPPETS[@]} == 0 )) && return 0

  if [[ -f "$settings" ]]; then
    (( DRY_RUN )) || backup_file "$settings" "settings.json"
  fi
  (( DRY_RUN )) && { log "[dry-run] merge hooks/permissions -> settings.json"; return 0; }

  python3 - "$settings" "$TARGET_DIR" "${SETTINGS_SNIPPETS[@]}" <<'PYEOF'
import json, sys

settings_path, claude_home, *snippet_paths = sys.argv[1:]

try:
    with open(settings_path) as f:
        settings = json.load(f)
except FileNotFoundError:
    settings = {}

def merge_hooks(snippet_hooks):
    settings.setdefault("hooks", {})
    for event, entries in snippet_hooks.items():
        existing = settings["hooks"].setdefault(event, [])
        for entry in entries:
            matcher = entry.get("matcher") if isinstance(entry, dict) else None
            if matcher is not None:
                # Eventos tool-scoped (PreToolUse/PostToolUse): mergear por
                # matcher, uniendo la lista de hooks en vez de duplicar el bloque.
                target = next((e for e in existing if e.get("matcher") == matcher), None)
                if target is None:
                    existing.append(entry)
                    continue
                target.setdefault("hooks", [])
                for h in entry.get("hooks", []):
                    if h not in target["hooks"]:
                        target["hooks"].append(h)
            elif entry not in existing:
                existing.append(entry)

def merge_permissions(snippet_permissions):
    settings.setdefault("permissions", {})
    if "defaultMode" in snippet_permissions:
        settings["permissions"]["defaultMode"] = snippet_permissions["defaultMode"]
    for key in ("allow", "ask", "deny"):
        if key not in snippet_permissions:
            continue
        existing = settings["permissions"].setdefault(key, [])
        for item in snippet_permissions[key]:
            if item not in existing:
                existing.append(item)

for snippet_path in snippet_paths:
    with open(snippet_path) as f:
        raw = f.read().replace("__CLAUDE_HOME__", claude_home)
        snippet = json.loads(raw)
    if "hooks" in snippet:
        merge_hooks(snippet["hooks"])
    if "permissions" in snippet:
        merge_permissions(snippet["permissions"])

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
  log "hooks/permissions mergeados en $settings (resto de las claves preservado)"
}

remove_obsolete_targets() {
  local rel target ts dest
  for rel in "${OBSOLETE_TARGETS[@]}"; do
    target="$TARGET_DIR/$rel"
    if [[ ! -e "$target" && ! -L "$target" ]]; then
      continue
    fi
    TO_REMOVE+=("$rel")
    (( STATUS_ONLY )) && continue
    (( DRY_RUN )) && { log "[dry-run] retirar obsolete $rel"; continue; }
    ts="$(date -u +%Y%m%dT%H%M%SZ)"
    dest="$BACKUP_ROOT/$ts/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -pR "$target" "$dest"
    rm -rf "$target"
  done
}

for pair in "${MANAGED_PAIRS[@]}"; do
  sync_file "$pair"
done

remove_obsolete_targets
merge_settings_snippets

if (( ! DRY_RUN && ! STATUS_ONLY )); then
  chmod +x "$TARGET_DIR"/hooks/*.sh 2>/dev/null || true
  prune_backups
fi

log "crear: ${#TO_CREATE[@]}  actualizar: ${#TO_UPDATE[@]}  retirar: ${#TO_REMOVE[@]}  sin cambios: ${#UNCHANGED[@]}"
if (( ${#TO_CREATE[@]} > 0 )); then log "  + ${TO_CREATE[*]}"; fi
if (( ${#TO_UPDATE[@]} > 0 )); then log "  ~ ${TO_UPDATE[*]}"; fi
if (( ${#TO_REMOVE[@]} > 0 )); then log "  - ${TO_REMOVE[*]}"; fi
