#!/usr/bin/env python3
"""
sensitive-reference-guard — hook PreToolUse de Claude Code.

Puerto directo de la mitad "referencias sensibles" de
`~/.config/opencode/plugins/permission-autopilot.ts` (SENSITIVE_REFERENCES +
containsSensitiveReference). La otra mitad de ese plugin (perfil de
allow/ask por patrón de bash riesgoso) se porta como reglas estáticas en
`~/.claude/settings.json` (permissions.allow/ask) vía
`base/permissions/permission-autopilot.snippet.json` — no hace falta un hook
para eso porque Claude Code ya evalúa allow/ask/deny nativamente.

Este script NO bloquea (a diferencia de env-guard): igual que el original,
si hay una referencia sensible simplemente "cae" a confirmación normal
(permissionDecision: ask) en vez de auto-aprobarse por la regla `allow`
amplia de permission-autopilot. `.env*` ya queda cubierto (con bloqueo
total, más estricto) por env-guard.sh; se mantiene igual en esta lista por
fidelidad con el plugin original, que también lo incluía.
"""
import json
import re
import sys

SENSITIVE_REFERENCES = [
    re.compile(r"""(^|[\s'"/\\])\.env(?:$|[.\s'"/\\])""", re.IGNORECASE),
    re.compile(r"""(^|[\s'"/\\])\.ssh(?:$|[/\\])""", re.IGNORECASE),
    re.compile(r"""(^|[\s'"/\\])\.gnupg(?:$|[/\\])""", re.IGNORECASE),
    re.compile(r"""(^|[\s'"/\\])\.aws[/\\](?:credentials|config)(?:$|\s|['"])""", re.IGNORECASE),
    re.compile(r"""(^|[\s'"/\\])\.config[/\\]gh[/\\]hosts\.yml(?:$|\s|['"])""", re.IGNORECASE),
    re.compile(r"""stitch-api-key""", re.IGNORECASE),
    re.compile(r"""(^|[\s'"/\\])(?:id_rsa|id_ed25519)(?:$|[.\s'"/\\])""", re.IGNORECASE),
    re.compile(r"""(^|[\s'"/\\])etc[/\\](?:shadow|sudoers)(?:$|\s|['"])""", re.IGNORECASE),
]

ENV_EXAMPLE_INLINE = re.compile(r"\.env\.example", re.IGNORECASE)


def contains_sensitive_reference(value: str) -> bool:
    without_examples = ENV_EXAMPLE_INLINE.sub("", value)
    return any(pattern.search(without_examples) for pattern in SENSITIVE_REFERENCES)


def ask(reason: str) -> None:
    print(
        json.dumps(
            {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "ask",
                    "permissionDecisionReason": reason,
                }
            }
        )
    )
    sys.exit(0)


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    tool_name = payload.get("tool_name", "")
    tool_input = payload.get("tool_input") or {}

    if tool_name == "Bash":
        command = tool_input.get("command")
        if isinstance(command, str) and contains_sensitive_reference(command):
            ask(
                "sensitive-reference-guard: el comando referencia una ruta sensible "
                "(.ssh, .gnupg, credenciales AWS/gh, claves privadas, /etc/shadow o "
                "sudoers, etc.) — requiere confirmación explícita, no se auto-aprueba."
            )
        sys.exit(0)

    if tool_name in ("Read", "Edit", "Write"):
        file_path = tool_input.get("file_path")
        if isinstance(file_path, str) and contains_sensitive_reference(file_path):
            ask(
                f"sensitive-reference-guard: {file_path} coincide con una ruta "
                "sensible — requiere confirmación explícita, no se auto-aprueba."
            )
        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    main()
