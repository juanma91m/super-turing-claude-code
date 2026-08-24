#!/usr/bin/env bash
#
# sync-project-overlay.sh <project-path>
#
# Crea/actualiza symlinks en <project>/.claude/skills/ apuntando a cada
# <project>/.opencode/skills/<nombre>/SKILL.md — un solo lugar de verdad
# (el archivo de OpenCode), sin copiar contenido.
#
# Salta las skills que ya son globales en ambos stacks (aune-*,
# workflow-ticket-handoff) para no duplicar el symlink a nivel de proyecto
# cuando ya está resuelto a nivel global.

set -euo pipefail

PROJECT="${1:-}"
if [[ -z "$PROJECT" ]]; then
  echo "Usage: sync-project-overlay.sh <project-path>" >&2
  exit 1
fi
PROJECT="$(CDPATH= cd -- "$PROJECT" && pwd)"

GLOBAL_SKILLS=(
  "workflow-ticket-handoff"
)

is_global() {
  local name="$1"
  for g in "${GLOBAL_SKILLS[@]}"; do
    [[ "$name" == "$g" ]] && return 0
  done
  return 1
}

SRC_ROOT="$PROJECT/.opencode/skills"
DST_ROOT="$PROJECT/.claude/skills"

if [[ ! -d "$SRC_ROOT" ]]; then
  echo "[sync-project-overlay] no existe $SRC_ROOT, nada que hacer" >&2
  exit 0
fi

mkdir -p "$DST_ROOT"

for skill_dir in "$SRC_ROOT"/*/; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  is_global "$name" && { echo "[sync-project-overlay] $name ya es global, omito"; continue; }

  src_file="$skill_dir/SKILL.md"
  if [[ ! -f "$src_file" ]]; then
    echo "[sync-project-overlay] $name sin SKILL.md, omito" >&2
    continue
  fi
  if ! head -1 "$src_file" | grep -q '^---$'; then
    echo "[sync-project-overlay] $name sin frontmatter YAML — Claude Code no la va a poder invocar, omito" >&2
    continue
  fi

  target="$(readlink -f "$src_file")"
  dst_dir="$DST_ROOT/$name"
  dst_file="$dst_dir/SKILL.md"
  mkdir -p "$dst_dir"

  if [[ -L "$dst_file" && "$(readlink -f "$dst_file")" == "$target" ]]; then
    echo "[sync-project-overlay] $name ya sincronizada"
    continue
  fi
  rm -f "$dst_file"
  ln -s "$target" "$dst_file"
  echo "[sync-project-overlay] symlink: $dst_file -> $target"
done
