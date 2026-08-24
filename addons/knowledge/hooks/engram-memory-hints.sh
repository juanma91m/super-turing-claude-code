#!/usr/bin/env python3
"""
engram-memory-hints — hook UserPromptSubmit de Claude Code.

Puerto directo de `~/.config/opencode/plugins/engram-memory-hints.ts`
(super-turing-opencode-knowledge). El original escuchaba `chat.message` y
empujaba un texto sintético cuando el mensaje contenía una palabra clave de
"recordar algo". El equivalente natural en Claude Code es `UserPromptSubmit`:
se dispara sobre el prompt del usuario antes de que el modelo responda, y lo
que este script imprime en stdout se agrega como contexto adicional (sin
bloquear el prompt).

Mismo patrón de palabras clave que el original (en inglés, por fidelidad:
"remember", "memorize", "save this", "don't forget", "note this",
"keep in mind").
"""
import json
import re
import sys

MEMORY_KEYWORD_PATTERN = re.compile(
    r"\b(remember|memorize|save\s+this|don'?t\s+forget|note\s+this|keep\s+in\s+mind)\b",
    re.IGNORECASE,
)

MEMORY_HINT = """[MEMORY HINT]
El usuario pidió explícitamente recordar algo.

Si la información es durable y útil entre sesiones, llamá ahora a la tool MCP de Engram que corresponda (mem_save).
- Memoria de proyecto para convenciones, arquitectura, comandos o gotchas específicos de este repo.
- Memoria de usuario/global para preferencias estables que aplican más allá de este repo.
- No persistas secretos crudos ni nada envuelto en <private>...</private>.
- Guardá conocimiento reusable y conciso, no texto crudo de la conversación."""


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    user_input = payload.get("user_input") or ""
    if isinstance(user_input, str) and MEMORY_KEYWORD_PATTERN.search(user_input):
        print(MEMORY_HINT)

    sys.exit(0)


if __name__ == "__main__":
    main()
