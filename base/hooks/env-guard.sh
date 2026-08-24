#!/usr/bin/env python3
"""
env-guard — hook PreToolUse de Claude Code.

Puerto directo de la lógica de `~/.config/opencode/plugins/env-guard.ts`
(super-turing-opencode). Bloquea Read/Edit/Write sobre archivos `.env*`
(excepto `.env.example`) y comandos Bash que los referencien.

No modifica ni depende del plugin original de OpenCode; es una
reimplementación equivalente para el contrato de hooks de Claude Code
(stdin JSON, exit code 2 = bloquear, mensaje en stderr).
"""
import json
import re
import sys

ENV_FILE_PATTERN = re.compile(r"""(^|[\s'"/\\])\.env($|[.\s'"/\\])""", re.IGNORECASE)
ENV_EXAMPLE_PATTERN = re.compile(r"""(^|/|\\)\.env\.example$""", re.IGNORECASE)
ENV_EXAMPLE_INLINE = re.compile(r"\.env\.example", re.IGNORECASE)


def normalize(path: str) -> str:
    return path.replace("\\", "/")


def is_protected_env_path(path: str) -> bool:
    normalized = normalize(path)
    if ENV_EXAMPLE_PATTERN.search(normalized):
        return False
    return bool(ENV_FILE_PATTERN.search(normalized))


def contains_protected_env_reference(command: str) -> bool:
    normalized = normalize(command)
    without_examples = ENV_EXAMPLE_INLINE.sub("", normalized)
    return bool(ENV_FILE_PATTERN.search(without_examples))


def block(message: str) -> None:
    sys.stderr.write(message + "\n")
    sys.exit(2)


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        # Si no podemos parsear el input, no bloqueamos por las dudas
        # (fail-open en errores de parsing, fail-closed en matches reales).
        sys.exit(0)

    tool_name = payload.get("tool_name", "")
    tool_input = payload.get("tool_input") or {}

    if tool_name == "Bash":
        command = tool_input.get("command")
        if isinstance(command, str) and contains_protected_env_reference(command):
            block(
                "Bloqueado por env-guard: el comando Bash referencia un archivo "
                ".env* protegido. Usá workflows seguros para secretos en vez de "
                "exponer/leer el archivo crudo por Bash. Solo .env.example está "
                "permitido para operaciones normales."
            )
        sys.exit(0)

    if tool_name in ("Read", "Edit", "Write"):
        file_path = tool_input.get("file_path")
        if isinstance(file_path, str) and is_protected_env_path(file_path):
            action = "Leer" if tool_name == "Read" else "Editar"
            block(
                f"Bloqueado por env-guard: {action} archivos .env* sensibles está "
                f"prohibido ({file_path}). Usá workflows seguros para secretos en "
                "vez de exponer o parchear el archivo crudo. Solo .env.example "
                "está permitido para lecturas/ediciones normales."
            )
        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    main()
