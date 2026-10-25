# super-turing-claude-code

Source of truth versionado para la migración del ecosistema `super-turing-opencode` hacia Claude Code. Este repo es análogo, en espíritu y disciplina, a `opencode-stack`: define qué se despliega en `~/.claude/`, cómo se sincroniza, y qué queda deliberadamente fuera (secretos, estado machine-local, addons todavía no migrados).

**No reemplaza a OpenCode.** El deploy en `~/.config/opencode/` sigue intacto y funcionando; este repo solo agrega la capa equivalente del lado Claude Code, de forma aditiva.

## Guía residente y operación actual

`base/CLAUDE.md` se despliega en `~/.claude/CLAUDE.md`. Contiene el rol base,
criterios comunes, seguridad y reglas breves de uso; las instrucciones locales lo
complementan. No es un catálogo manual ni un historial de instalación. Se alinea
en principios con el AGENTS.md OpenCode, pero no copia sus roles ni herramientas.

Este README es documentación de consulta, no una importación desde la guía:
no leerlo al inicio de cada tarea ni referenciarlo mediante `@` desde CLAUDE.md.

### Inventario y descubrimiento

- Agentes: archivos de `base/agents/`, `addons/knowledge/agents/` y sus destinos
  `~/.claude/agents/`; `name`, `description`, `model` y `tools` son su contrato
  real. La descripción orienta la elección sin repetir el catálogo en CLAUDE.md.
- Skills: metadata de `~/.claude/skills/`; cuerpo y referencias se consultan cuando
  corresponden. Comandos: archivos de `~/.claude/commands/`, con descripción y
  argumentos propios. No copiar sus listas ni modelos a la guía global.
- Los roles de revisión siguen separados: `code-reviewer` revisa trabajo de
  terceros; `reviewer`, el desarrollo propio. Sus prompts preservan límites e
  informes. La sesión principal conserva liderazgo/implementación; no depende
  de un agente primario `master-dev` portado de OpenCode.
- El storage local de review tiene precedencia sobre el default global. Los
  contratos requeridos pueden leerse con `Read` desde `~/.claude/skills/` cuando
  `Skill` no está en las tools del rol; no ampliar allowlists para resolver una
  referencia legible ni asumir MCPs heredados.
- En la CLI inspeccionada, `claude agents` administra sesiones background: no
  confundirlo con el inventario de definiciones ni asumir que prueba su carga.
- No afirmar descubrimiento de un asset solo porque existe un archivo. Se
  verificaron metadata de agentes y de las skills documentales/GitHub usadas por
  la guía. `workflow-ticket-handoff` aún carece de frontmatter: los comandos de
  tickets mantienen el handoff explícito; su metadata se revisará en el punto 2
  del plan de simplificación, no se corrige como efecto lateral de esta poda.

### Controles y contratos que no desaparecen al acortar la guía

El planner usa `planner_shell.py` de Core como ejecutor Bash y PreToolUse de su
frontmatter. El hook es scoped al subagente, no global; no cambia settings ni
tools del resto. Solo pasan Git de lectura y helpers declarados por addons.
Formateo, builds, intérpretes generales, redirección/expansión y comandos compuestos
se bloquean; las lecturas normales siguen en Read/Grep/Glob. Instalar Core y las
declaraciones de los addons antes de usar esos helpers. No eludir la guarda si
falta un recurso: falla cerrado y se deriva la operación al implementador.

`diseno-ui-web` también tiene una sola fuente compartida por symlink a OpenCode;
el design system del proyecto prevalece sobre cualquier referencia genérica.

| Capacidad | Fuente del detalle / límite |
|---|---|
| Secretos | `base/hooks/env-guard.sh` bloquea `.env*` salvo `.env.example`; el deber de no exponerlos sigue explícito aunque un hook no se ejecute |
| Acceso sensible | `base/hooks/sensitive-reference-guard.sh` pide confirmación para rutas sensibles; no es una autorización automática ni un bloqueo total |
| Operaciones riesgosas | Patrones `permissions.ask` en `base/permissions/permission-autopilot.snippet.json`; preservar `ask`/`deny`, no duplicar sus listas en el prompt |
| Engram/Qdrant | `addons/knowledge/agents/` y skills de conocimiento; memoria durable vía herramientas disponibles, corpus solo mediante wrappers aprobados |
| CodeGraph | `addons/codegraph/skills/codegraph-analisis-estructural/SKILL.md` y comandos de lifecycle; índices por root/worktree, init/reindex explícitos |
| Jira/Confluence | Integraciones aprobadas de lectura; denegaciones de escritura del snippet, helpers y OAuth no cambian por editar CLAUDE.md |
| Tickets | `addons/ticketing/commands/`; `verdict.md` antes de implementar y `result-dev.md` según workflow local; escrituras del helper sandboxeadas a `tmp/<ticket>/`, nunca Jira |
| Documentos | `addons/documents/commands/` y skills `publicacion-documental`/`diagramacion-tecnica`; fuente y plantillas completas, wrappers, QA del PDF y editables |
| UI | Rol `ui-web-designer`, skills UI y MCPs; Stitch es exclusividad operativa por instrucciones, no aislamiento técnico equivalente al gating OpenCode |
| GitHub | Skill machine-local `github-cuentas-multiples`; no copiar cuentas, owners ni aliases a la guía portable |
| Dominio/stack de producto | `CLAUDE.md` y skills locales del proyecto; el resumen histórico del rollout no sustituye esas instrucciones |

Los wrappers documentales siguen en `~/.config/opencode/scripts/`:
`publish_document.py`, `render_diagram.py` y `render_infographic.py` se ejecutan
con Python, no con Bash. Las skills vigentes contienen argumentos, plantillas y
runtimes; no invocar Quarto/D2/Pandoc directamente para saltarse esos contratos.
Conservar fuentes QMD/D2 o las que establezca el flujo aprobado, no editar la
salida como fuente maestra ni usar capturas como sustituto.

Jira puede usar el helper read-only o Rovo según contexto y disponibilidad. No
leer credenciales crudas para prepararlos. Si Rovo requiere OAuth, pedir al
usuario autenticar; no asumir acceso ni buscar una vía que evada la restricción.
La configuración efectiva y permisos de cada subagente determinan sus tools:
no inferir que dispone de todos los MCPs del asistente principal.

Los incidentes de hooks de agosto de 2026 permanecen en `CHANGELOG.md` 1.0.1 y
1.1.2. Son historia, no una garantía actual ni instrucciones contradictorias de
arranque. Los tests con payloads sintéticos no prueban la invocación de hooks en
una sesión Claude completa. La documentación oficial de descubrimiento se puede
consultar en https://code.claude.com/docs/en/sub-agents y
https://code.claude.com/docs/en/skills; no reemplaza verificar los archivos locales.

## Historia de la migración (Fases 1-6)

Las cantidades y decisiones siguientes son la fotografía histórica del rollout;
el inventario vigente son los assets reales y sus metadatos, no estas listas.

Incluye:
- 10 subagentes "base" (`planner`, `code-reviewer`, `reviewer`, `agent-design`, `code-inspector`, `backend-java-developer`, `frontend-web-developer`, `ui-web-designer`, `dev-test`, `merge-conflict-resolver`) + 2 subagentes de Knowledge (`knowledge-curator`, `knowledge-reader`).
- 7 slash commands (2 base + 5 de Knowledge).
- 18 skills (15 base + 3 de Knowledge).
- `~/.claude/CLAUDE.md` global (rol por defecto — reemplaza conceptualmente a `master-dev`, que en Claude Code no existe como agente primario intercambiable).
- Hook `PreToolUse` `env-guard` (bloqueo de `.env*`) + `sensitive-reference-guard` (ask forzado en `.ssh`, `.gnupg`, credenciales AWS/gh, claves privadas, `/etc/shadow`/`sudoers`).
- Perfil de permisos `permission-autopilot` en `~/.claude/settings.json` (`permissions.allow`/`ask`), puerto 1:1 de la lista de patrones bash riesgosos del plugin original.
- Hook `UserPromptSubmit` `engram-memory-hints` (nudge a guardar en Engram cuando el usuario dice "remember"/"don't forget"/etc.).
- Registro MCP manual de `context7`, `playwright`, `stitch` y `engram` (mismo binario/DB/tools que ya usa `super-turing-opencode-knowledge`, sin plugin oficial — por elección explícita, para que funcione tal cual funciona en OpenCode).

**Fase 2 (CodeGraph)** agrega: MCP `codegraph` (tool `mcp__codegraph__explore`, mismo aislamiento de superficie que en OpenCode), skill `codegraph-analisis-estructural`, comandos `/codegraph-init`, `/codegraph-status`, `/codegraph-sync`, `/codegraph-reindex`, y acceso a `codegraph_explore` para `planner`/`reviewer`/`code-inspector`/`code-reviewer`. Reusa los índices `.codegraph/` ya generados por proyecto (no depende del agente que los consulta).

De paso, fase 2 corrigió un bug de fase 1: varios subagentes (`planner`, `reviewer`, `code-inspector`, `agent-design`, `dev-test`, `knowledge-curator`, `knowledge-reader`) mencionaban en su prompt llamar tools `mem_*` de Engram directamente, pero no las tenían en su `tools:` — en Claude Code eso las dejaba inaccesibles. Ya está corregido (ver `CHANGELOG.md`).

**Fase 3 (Ticketing)** agrega: comandos `/ticket-plan`, `/ticket-refresh`, `/ticket-verdict` (delegan en `planner`), `/ticket-implement` (corre directo), `/ticket-validate` (delega en `dev-test`); skill `workflow-ticket-handoff`; y notas de "ticketing opcional" en `planner`, `agent-design` y `CLAUDE.md`. Sin MCP nuevo — reusa `~/.config/opencode/scripts/jira_helper.sh` (100% lectura contra Jira; la escritura es local, sandboxeada a `tmp/<ticket>/`).

**Fase 4 (Documents)** agrega: comandos `/crear-diagrama` y `/publicar-documento`, skills `diagramacion-tecnica` y `publicacion-documental` (portadas verbatim — ya eran agnósticas de agente OpenCode). Sin MCP nuevo — reusa los runtimes pineados de Quarto/D2 y los wrappers `publish_document.py`/`render_diagram.py`/`render_infographic.py` existentes, más las plantillas en `~/.config/opencode/documents/`.

**Fase 5 (github-accounts-local)** agrega: skill `github-cuentas-multiples` (mapeo owner→cuenta `gh`→alias SSH para las identidades GitHub que conviven en esta máquina). Portada verbatim. **Es machine-local por diseño** (ver `STACK-MANIFEST.json` → `machineLocalOnly`) — si este repo se clona a otra máquina, esta skill hay que reparametrizarla, no reusarla tal cual.

**Fase 6 (rollout a higyrus-workspace + de-duplicación cross-stack)** agrega, para los 9 proyectos de `/home/jmagnaterra/TRABAJO/AUNE/higyrus-workspace/` (higyrus, market-data, virtual-broker, keycloak, higyrus-gateway, aggregator, perfil-inversor, documento-api, oms-api):
- Un `CLAUDE.md` real por proyecto (autoría directa, agnóstico de herramienta — reemplaza el bridge `CLAUDE.md -> AGENTS.md` que existía en `higyrus`/`aggregator`).
- `<project>/.claude/skills/<nombre>` symlinkeadas a `<project>/.opencode/skills/<nombre>/SKILL.md` (script `addons/higyrus-workspace/scripts/sync-project-overlay.sh`) — cero copias, un solo lugar de verdad por skill.
- 2 nuevos agentes globales: `backend-python-developer` (market-data) y `backend-typescript-developer` (oms-api).
- Fix de gap de fase 1: comandos globales `/code-review` y `/code-review-pr` (nunca se habían portado).
- **De-duplicación cross-stack** (autorizada explícitamente): `aune-code-review-eficiente`, `aune-higyrus-workspace-ecosystem` y `ticket-code-review.md` — antes duplicados idénticos en los 9 proyectos — se promovieron a globales en `~/.config/opencode/` y se reemplazaron por symlinks en los 9 lados; el MCP `atlassian-rovo` se promovió igual a `~/.config/opencode/opencode.json` global (verificado con `opencode debug config` que el merge global+proyecto sigue resolviéndolo tras sacarlo de los 9 `opencode.json` de proyecto). Ver `STACK-MANIFEST.json` → `crossStackSymlinks` y `opencodeSideChangesThisPhase` para el detalle completo.
- Retro-fix de fases 1-5: 8 skills globales que ya se habían portado con pequeñas diferencias de texto se reconciliaron y ahora son symlinks al archivo de OpenCode (ya actualizado) en vez de copias independientes — editar en OpenCode alcanza para ambos stacks. Frontmatter YAML agregado a las ~14 skills de dominio de `higyrus` (el único proyecto que no lo tenía) para poder symlinkearlas también.
- `higyrus-AN` (clon git duplicado y desactualizado de `higyrus`) quedó documentado como fuera de alcance, sin tocar.

El plan completo de cada fase, con todas las decisiones de arquitectura, con todas las decisiones de arquitectura y el mapeo agente-por-agente, quedó documentado en `/home/jmagnaterra/.claude/plans/glimmering-twirling-stroustrup.md` (sesión original de migración).

## Uso

```bash
./install.sh                 # primer deploy + registro de MCP servers
./scripts/sync-claude-stack.sh --status   # ver qué cambió sin tocar nada
./scripts/sync-claude-stack.sh            # aplicar cambios (con backup de lo reemplazado)
```

Backups de sync quedan en `~/.claude/backups/claude-stack-sync/<timestamp>/`, con retención de 5 snapshots.

## Principio de no-destrucción

- Fases 1-5: nunca se editó `~/.config/opencode/**` ni ningún repo bajo `~/.local/src/super-turing-opencode-*`.
- Fase 6 (autorizada explícitamente por el usuario): sí se edita el lado OpenCode, pero **siempre de forma aditiva** — agregar frontmatter YAML donde falta, o consolidar duplicados exactos a una sola fuente con symlinks. Nunca se borra contenido real. Ver `STACK-MANIFEST.json` → `opencodeSideChangesThisPhase` para el listado completo.
- Los scripts de Qdrant/Engram/Jira (`~/.config/opencode/scripts/*.sh`, binario `engram`) se reusan por ruta absoluta, nunca se copian.
- `~/.claude/settings.json` solo recibe un merge de las claves `hooks`/`permissions`; el resto de las claves (ej. `theme`) queda intacto.
- Los MCP servers se registran con `claude mcp add-json --scope user`, nunca editando `~/.claude.json` a mano.
- Cuando el archivo fuente de un skill es en sí un symlink hacia OpenCode, `sync-claude-stack.sh` replica un symlink real en destino (no una copia) — ver `STACK-MANIFEST.json` → `crossStackSymlinks`.
