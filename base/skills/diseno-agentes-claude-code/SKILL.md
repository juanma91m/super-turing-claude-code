---
name: diseno-agentes-claude-code
description: Define criterios para crear o ajustar subagentes, skills, commands, prompts y permisos de Claude Code con cambios chicos y consistentes.
---
## Que hago
- Ayudo a decidir si algo debe resolverse con un subagente, una skill, un command o solo documentacion (CLAUDE.md).
- Reviso `tools`, `model`, prompts y responsabilidades para que cada subagente tenga un rol claro.
- Refuerzo consistencia entre configuracion (`~/.claude/settings.json`, `.mcp.json`), subagentes, skills, commands y documentacion.

## Cuando usarme
- Antes de crear o cambiar subagentes de Claude Code (`.claude/agents/*.md`).
- Cuando hay drift entre configuracion y documentacion.
- Cuando aparece una nueva necesidad y no esta claro si merece un subagente nuevo o una solucion mas chica (skill, command, o simplemente instrucciones en CLAUDE.md).

## Formato de referencia (frontmatter de un subagente Claude Code)
- `name`: identificador en minusculas con guiones.
- `description`: cuando Claude debe delegar a este subagente.
- `tools` / `disallowedTools`: allowlist o denylist de herramientas (no hay permisos de grano fino por patron de comando dentro del subagente; eso vive en `~/.claude/settings.json`).
- `model`: `sonnet`, `opus`, `haiku`, `fable` o `inherit`.

## Criterios base
- Preferir cambios pequeños, trazables y reversibles.
- No expandir `tools` sin una razon clara.
- Mantener responsabilidades bien delimitadas.
- No mezclar dominio o reglas especificas de un proyecto dentro de subagentes, skills o prompts genericos globales (eso va en el `.claude/` o `CLAUDE.md` del proyecto, no en `~/.claude/`).
- Validar la configuracion resultante (ej. listar subagentes disponibles) y actualizar la documentacion afectada cuando corresponda.
