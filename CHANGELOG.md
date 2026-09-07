# Changelog

## 1.1.4 — Aislamiento de tooling UI

- Stitch queda bajo ownership operativo exclusivo de `ui-web-designer`; frontend y el asistente principal deben derivar allí el trabajo visual.
- Playwright se declara para `planner`, `frontend-web-developer`, `ui-web-designer` y `dev-test`, manteniendo su uso condicionado a evidencia web real.
- Se preserva el MCP Stitch global porque Claude Code no ofrece aislamiento técnico equivalente al gating por agente de OpenCode; el límite del asistente principal queda reforzado por política.

## 1.1.3 — Poda de skill redundante

- Se retira `implementacion-frontend-web`: repetía la responsabilidad ya definida en `frontend-web-developer`; `diseno-ui-web` conserva el criterio visual reusable.
- `sync-claude-stack.sh` incorpora `obsoleteTargets` para respaldar y retirar assets que dejaron de pertenecer al stack.
- La política global niega por nombre las tools de escritura `add*`, `create*`, `edit*`, `transition*` y `update*` del MCP `atlassian-rovo`; las lecturas permanecen disponibles.
- `STACK-MANIFEST.json` se alinea con la versión real del changelog y sube a `1.1.3`.

## 1.1.2 — Fix: CLAUDE.md desactualizado post-Fase 6

- `base/CLAUDE.md` seguía diciendo que el rollout a `higyrus-workspace` "no está migrado todavía" (texto de Fase 1, nunca actualizado tras completar Fase 6) y a los listados de agentes/comandos les faltaban `backend-python-developer`, `backend-typescript-developer`, `/code-review`, `/code-review-pr`, `/ticket-code-review`, y cualquier mención del MCP `atlassian-rovo` en la sección de Ticketing. Corregido: nueva sección "higyrus-workspace (rollout por proyecto)", listas completas, mención del MCP con su estado de auth.
- Se re-testeó en vivo el guardrail `.env*`: un comando Bash que referenciaba un `.env` fue bloqueado por `env-guard.sh` vía `PreToolUse`, contradiciendo el hallazgo de 2026-08-21 ("los hooks no se invocan en este hosting"). La causa más probable es que ese hallazgo se tomó antes de corregir el bug de schema de `hooks.UserPromptSubmit` (1.0.1) — no una limitación permanente del entorno. Sección de guardrail de secretos actualizada para reflejar esto sin sobre-confiar (falta re-testear `sensitive-reference-guard.sh` y `engram-memory-hints.sh` puntualmente).

## 1.1.1 — MCP atlassian-rovo movido a addons/ticketing

- `atlassian-rovo.json` vivía en `addons/higyrus-workspace/mcp/` (ubicación arbitraria, quedó ahí solo porque se creó durante el trabajo de fase 6). Se movió a `addons/ticketing/mcp/`, que es su dueño temático real (integración Jira/Confluence). `install.sh` actualizado.
- Del lado OpenCode, el mismo MCP **no estaba versionado en ningún repo** (solo en el deploy de esta máquina) — se agregó a `super-turing-opencode-ticketing/mcp/atlassian-rovo.json`, documentado en su `STACK-MANIFEST.json` (clave nueva `mcpConfig`, ya que se mergea en `opencode.json` en vez de copiarse verbatim), README y CHANGELOG.
- `addons/higyrus-workspace` quedó reducido a lo que realmente le pertenece: solo `scripts/sync-project-overlay.sh`.

## 1.1.0 — Repos canónicos versionados + reconciliación de la de-duplicación

- **Los 9 repos `super-turing-opencode-<project>` ahora tienen `CLAUDE.md` real + `.claude/skills/` (symlinks relativos a `.opencode/skills/`)**, mismo contenido que el deploy, commiteado y pusheado. `sync_manifest.txt` de cada uno actualizado para incluir estas rutas.
- `aune-code-review-eficiente` se fusionó dentro de `code-review-branch-to-branch` (no tenía nada específico de AUNE — era presupuesto operativo de review) y quedó eliminada como skill separada. `code-review-branch-to-branch` ahora es symlink al archivo de OpenCode en ambos stacks, y ese archivo pasó a estar versionado en `opencode-stack` (antes solo existía en el deploy, sin repo).
- `ticket-code-review.md` resultó ser genérico (sin nada de AUNE) y también quedó versionado en `opencode-stack`, junto a los otros `ticket-*.md`.
- **`aune-higyrus-workspace-ecosystem` se revirtió a copia real por proyecto** (decisión explícita del usuario: esta sí es genuinamente específica de AUNE — nombra los 9 productos y su dominio de negocio real — y no tiene un repo "de ecosistema" donde vivir sin crear uno nuevo). Ya no es una skill global; `addons/higyrus-workspace/scripts/sync-project-overlay.sh` ya no la excluye del symlinking por proyecto.
- Reconciliado en los 18 lugares (9 deploys + 9 overlays): removidas las referencias rotas a `aune-code-review-eficiente` en `AGENTS.md`/`CLAUDE.md`/`ticket-code-review.md`.
- Al pushear los 9 overlays se encontraron commits remotos previos no sincronizados localmente (`Harden overlay installation`, `Fix overlay sync manifest`, `Document overlay permission exceptions`) — se resolvieron con `git rebase` en vez de force-push; todos aplicaron limpio salvo `oms-api` (el remoto había reformateado `opencode.json` a una sola línea por objeto; el rebase preservó el contenido semánticamente idéntico pero con el formato multi-línea original — confirmado con un diff JSON estructural, no textual).

## 1.0.1 — Fix: hooks.UserPromptSubmit rompía el arranque de Claude Code

- El usuario reportó "Settings Error" al arrancar Claude Code: `hooks.UserPromptSubmit.0.hooks: Expected array, but received undefined`. El bloque `UserPromptSubmit` (fase 1, `engram-memory-hints`) se había escrito como objeto plano `{"type":"command","command":...}`, pero Claude Code espera el mismo envoltorio que `PreToolUse`: un array de bloques `{"hooks": [{"type":"command", ...}]}` (con `matcher` opcional, no aplica a eventos no ligados a una tool). `PreToolUse` ya tenía el formato correcto por eso nunca dio error.
- Corregido en `addons/knowledge/hooks/hooks.snippet.json` (fuente) y directamente en `~/.claude/settings.json` (ya desplegado, el merge normal no lo hubiera arreglado porque solo agrega, no repara estructuras rotas existentes). Confirmado con `--status` que fuente y deploy quedan idénticos.

## 1.0.0 — Fase 6: rollout a higyrus-workspace + de-duplicación cross-stack

**Groundwork global:**
- Fix de gap de fase 1: comandos `/code-review` y `/code-review-pr` portados a `base/commands/` (nunca se habían migrado).
- Nuevos agentes globales `backend-python-developer` (market-data) y `backend-typescript-developer` (oms-api), mismo patrón que `backend-java-developer`.
- `code-reviewer.md` ahora sugiere la skill `github-cuentas-multiples` (fix de raíz del parche ad-hoc que `virtual-broker` tenía localmente para elegir cuenta GitHub en code review).
- Probado en vivo con dos skills de prueba: Claude Code **requiere** `name` en el frontmatter para invocar una skill (`Unknown skill` sin él) pero **tolera campos extra no estándar** (`compatibility: opencode`, `mode: primary`) sin error.

**De-duplicación cross-stack (autorizada explícitamente por el usuario, edición aditiva de OpenCode):**
- `aune-code-review-eficiente` (2 variantes de redacción entre proyectos, se consolidó la condensada) y `aune-higyrus-workspace-ecosystem` (ya idéntica en los 9) promovidas a `~/.config/opencode/skills/` global; las 18 copias por proyecto (9 deploy + 9 overlay canónico) reemplazadas por symlinks.
- `ticket-code-review.md` (byte-idéntico en los 9) promovido a `~/.config/opencode/commands/` global, mismo tratamiento de symlinks.
- MCP `atlassian-rovo` promovido a `~/.config/opencode/opencode.json` global; removido de los 9 `opencode.json` de proyecto (deploy + overlay). Verificado con `opencode debug config` en `keycloak` y `aggregator` que el merge global+proyecto sigue resolviendo el MCP correctamente tras el cambio.
- Retro-fix de fases 1-5: 8 skills globales portadas con pequeñas diferencias de redacción (menciones a `master-dev`, frontmatter faltante) se reconciliaron directamente en el archivo de OpenCode y ahora `super-turing-claude-code` las referencia por symlink en vez de copia: `revision-por-etapas`, `sdd-tdd-bdd-pragmatico`, `memoria-durable-opencode`, `workflow-ticket-handoff` (+ sección nueva de acceso a Jira agregada al original), `memoria-engram-opencode`, `knowledge-governance-opencode`, `debugging-sistematico`, `verificacion-antes-de-cerrar`. Las 3 que ya eran verbatim (`diagramacion-tecnica`, `publicacion-documental`, `github-cuentas-multiples`) también se convirtieron a symlink.
- `diseno-agentes-opencode`/`diseno-agentes-claude-code` queda **excluida** del symlinking: el contenido diverge genuinamente (habla de subagentes Claude Code, no agentes OpenCode).
- `sync-claude-stack.sh` generalizado: si el archivo fuente es un symlink, el script replica un symlink real en destino (no copia contenido) — fix necesario porque `find -type f` no detectaba los symlinks nuevos (se agregó `-o -type l`).

**Rollout por proyecto (higyrus, market-data, virtual-broker, keycloak, higyrus-gateway, aggregator, perfil-inversor, documento-api, oms-api):**
- Frontmatter YAML agregado a las ~14 skills de dominio de `higyrus` que no lo tenían (único proyecto en formato viejo), en el deploy y en `super-turing-opencode-higyrus`.
- Nuevo script `addons/higyrus-workspace/scripts/sync-project-overlay.sh <project>`: symlinkea `<project>/.claude/skills/<nombre>` a `<project>/.opencode/skills/<nombre>/SKILL.md` para toda skill de dominio con frontmatter válido, saltando las ya-globales.
- Un `CLAUDE.md` real por proyecto (autoría directa): reemplaza el symlink `CLAUDE.md -> AGENTS.md` en `higyrus`/`aggregator` y el `CLAUDE.md` genérico de `/init` en `virtual-broker` (su contenido útil de comandos `make`/`npm` se fusionó, no se descartó). Sin `.claude/agents/`, `.claude/commands/` ni `.mcp.json` por proyecto — todo eso ya es global.
- `higyrus-AN` (clon git duplicado y desactualizado ~7 semanas de `higyrus`, confirmado con `git merge-base --is-ancestor`) documentado como fuera de alcance en el `CLAUDE.md` de `higyrus`, sin tocar.

**Verificación:** `git status` en los 18 repos tocados (9 deploy + 9 overlay) muestra exactamente los cambios esperados y nada más; `opencode` sigue arrancando y resolviendo `atlassian-rovo` vía global; symlinks de skills confirmados resueltos en `higyrus`, `market-data`, `oms-api`.

## 0.6.0 — Fase 5: github-accounts-local

- Nuevo addon `addons/github-accounts-local`: skill `github-cuentas-multiples`, portada verbatim (ya se autodeclaraba "overlay global machine-local" en su propio frontmatter/body, sin mecánica OpenCode que adaptar).
- `CLAUDE.md` documenta cuándo cargarla (antes de cualquier operación `gh`/`git` contra un remoto) y deja explícito que describe identidades específicas de esta máquina — no promoverla a otra máquina sin reparametrizar.
- `STACK-MANIFEST.json` agrega la sección `machineLocalOnly` para marcar este tipo de asset de forma explícita (distinto de `outOfScopeThisPhase`, que es sobre fases no hechas todavía).

## 0.5.0 — Fase 4: Documents (Quarto/D2)

- Nuevo addon `addons/documents`: comandos `/crear-diagrama` y `/publicar-documento`, skills `diagramacion-tecnica` y `publicacion-documental` — portados **verbatim**, sin ningún ajuste: el contenido original ya era agnóstico de agente OpenCode (sin `agent:` en frontmatter, sin menciones a `task()`/`master-dev`/`plan`/`build`).
- Sin MCP ni scripts nuevos: se reusan por ruta absoluta los runtimes pineados (`.../super-turing-opencode-documents/runtime/{current,d2-current}/bin/`), los wrappers (`publish_document.py`, `render_diagram.py`, `render_infographic.py`) y las plantillas/filters/reference bajo `~/.config/opencode/documents/`.
- `CLAUDE.md` documenta el flujo (wrappers como único punto de entrada, plantillas a copiar completas, QA visual obligatorio antes de declarar un documento terminado).

## 0.4.0 — Fase 3: Ticketing (Jira)

- Nuevo addon `addons/ticketing`: comandos `/ticket-plan`, `/ticket-refresh`, `/ticket-verdict` (delegan en `planner`, antes montados sobre el primitivo `plan` de OpenCode), `/ticket-implement` (corre directo por el asistente principal, antes sobre `build`), `/ticket-validate` (delega en `dev-test`, sin cambios de fondo).
- Skill `workflow-ticket-handoff` portada casi 1:1 (contenido ya era agnóstico de agente), con una sección nueva documentando el acceso a `jira_helper.sh`.
- Se confirmó leyendo `jira_api_read.py` que el wrapper es **100% de solo lectura contra Jira** (`issue`/`search`/`context`/`attachments`/`dump`); las operaciones de escritura (`note`/`write`/`verdict`/`mkdir`/`delete`) son siempre locales y sandboxeadas a `tmp/<ticket>/` — nunca escriben en Jira. No se copió el script, se reusa por ruta absoluta como los de knowledge/codegraph.
- Puerto del plugin `ticketing-coupling.ts` (inyección condicional de reglas de ticketing en `plan`/`planner` y `build`/`master-dev`/`agent-design`): se agregaron secciones equivalentes directamente en `planner.md`, `agent-design.md` y `CLAUDE.md` (ya que Claude Code no tiene un mecanismo de inyección de system prompt por agente vía plugin — la única forma fiel es prosa en el propio archivo).
- Sin MCP nuevo esta fase.

## 0.3.2 — Verificación en vivo: permissions funciona, hooks no (en este hosting)

- Con `permissions.defaultMode: "default"` ya desplegado, se confirmó en vivo (usuario vio el prompt real) que `permissions.ask` de `permission-autopilot` **sí funciona** — un `rm` de prueba pidió confirmación.
- Con un probe de debug agregado temporalmente a `env-guard.sh` (log de cada invocación), se confirmó que los hooks `PreToolUse` **no se invocan** en este entorno (child session vía socket de mensajería) — ni para `Read` ni para `Bash` — a pesar de que el script y el registro en `settings.json` son correctos. El probe se removió; `~/.claude/hooks/env-guard.sh` quedó restaurado a la versión limpia del repo.
- `CLAUDE.md` actualizado para reflejar esto con honestidad: el guardrail de `.env*`/rutas sensibles/memory-hints queda como política de comportamiento (no como garantía técnica) hasta confirmar si los hooks funcionan en una sesión de terminal `claude` plana, fuera de este hosting.
- Pendiente: repetir esta verificación en un entorno sin child-session/socket para saber si los hooks son recuperables ahí, o si es una limitación permanente de este tipo de sesión.

## 0.3.1 — Fix: la sesión corría en `permissionMode: auto`

- Se detectó en vivo que la sesión corría con `permissionMode: "auto"` (confirmado en el jsonl de la sesión), lo que hace que las reglas `permissions.ask` de `permission-autopilot` nunca dispararan un prompt real — todo se auto-aprobaba a nivel de sesión, independientemente de nuestra config.
- Se agregó `"permissions.defaultMode": "default"` a `permission-autopilot.snippet.json` — es la clave real para fijar el modo por defecto de sesiones nuevas (no existe un `permissionMode` de nivel superior en `settings.json`).
- Pendiente de confirmar en una sesión realmente nueva (no `--resume`) si esto alcanza, o si hay un harness externo forzando `--permission-mode auto` en el lanzamiento, lo cual quedaría fuera del control de este repo.

## 0.3.0 — Fase 2: CodeGraph + fix de acceso MCP en subagentes

- Nuevo addon `addons/codegraph`: MCP `codegraph` (comando absoluto al binario de `super-turing-opencode-codegraph`, `env CODEGRAPH_MCP_TOOLS=explore` idéntico a OpenCode — solo se expone `mcp__codegraph__explore`, el resto del CLI queda fuera de MCP por diseño), skill `codegraph-analisis-estructural`, comandos `/codegraph-init`, `/codegraph-status` (delega en `code-inspector`), `/codegraph-sync` (delega en `code-inspector`), `/codegraph-reindex`.
- Se confirmó vía `codegraph install --print-config claude` que el propio CLI de CodeGraph soporta Claude Code nativamente con exactamente la misma forma de config que ya usa OpenCode (sin `--path`, mismo binario) — se registró vía el mecanismo propio del repo (`claude mcp add-json --scope user`) en vez del instalador nativo, para mantener todo el registro MCP en un solo lugar auditable.
- Se otorgó `mcp__codegraph__explore` a `planner`, `reviewer`, `code-inspector`, `code-reviewer` (mismos agentes que en OpenCode, salvo `master-dev` → ahora `CLAUDE.md`).
- **Fix retroactivo de fase 1**: `planner`, `reviewer`, `code-inspector`, `agent-design`, `dev-test`, `knowledge-curator` y `knowledge-reader` instruían en su prompt llamar tools MCP `mem_*` de Engram directamente, pero esas tools no estaban en su `tools:` de frontmatter — en Claude Code eso las hacía inaccesibles para el subagente (el `tools:` explícito actúa como allowlist, no se heredan MCP tools automáticamente). Se agregaron los nombres `mcp__engram__mem_*` correspondientes al rol de cada agente (lectura para `reviewer`/`code-inspector`/`knowledge-reader`, escritura para `planner`/`agent-design`/`dev-test`/`knowledge-curator`).

## 0.2.0 — Fase 1 (continuación): permission-autopilot + engram-memory-hints

- Puerto de `permission-autopilot.ts`: perfil `permissions.allow`/`ask` en `~/.claude/settings.json` con los 85 patrones de bash riesgoso del original (sudo/rm/chmod/kill/systemctl/dd/mkfs/Git destructivo/Docker-K8s-Terraform destructivo/DB clients/migraciones/publicación de paquetes/`bash -c`/`eval`) y el hook `sensitive-reference-guard.sh` para las 8 referencias sensibles (.ssh, .gnupg, credenciales AWS/gh, claves privadas, /etc/shadow-sudoers) que nunca se auto-aprueban.
- Puerto de `engram-memory-hints.ts` como hook `UserPromptSubmit` (`addons/knowledge/hooks/engram-memory-hints.sh`), mismo patrón de palabras clave que el original.
- `scripts/sync-claude-stack.sh` generalizado: mergea todos los `*.snippet.json` de `base/` y `addons/` (no solo hooks — también `permissions`), y el merge de hooks ahora es por-matcher (une la lista de hooks en vez de duplicar el bloque completo).
- Se confirmó que la instalación real de Engram en OpenCode (vía `super-turing-opencode-knowledge`) NO usa el plugin oficial de Engram para ningún agente — es wiring manual propio del addon. Por eso el registro MCP en Claude Code se mantiene manual (fase 1 original), no se cambia al plugin oficial.

## 0.1.0 — Fase 1: core + Knowledge

- Puerto inicial de 12 agentes OpenCode a subagentes Claude Code (10 base + 2 Knowledge), con reasignación de modelo por rol (`opus` para planner/code-reviewer/agent-design, `sonnet` para desarrollo/review general, `haiku` para knowledge-reader).
- Puerto de 7 comandos (2 base + 5 Knowledge), con conversión de frontmatter OpenCode → Claude Code (`agent:` pasa a instrucción de delegación en el body; `$1`/`$ARGUMENTS` → `$ARGUMENTS`/`argument-hint`).
- Puerto de 18 skills al spec estándar Agent Skills (frontmatter reducido a `name`/`description`/`license`/`allowed-tools`), incluyendo renombre `diseno-agentes-opencode` → `diseno-agentes-claude-code` con contenido adaptado a subagentes Claude Code.
- Nuevo `~/.claude/CLAUDE.md` global, condensando el rol de `master-dev` como comportamiento por defecto (no hay agente primario intercambiable en Claude Code).
- Nuevo hook `PreToolUse` `env-guard.sh`, puerto de `~/.config/opencode/plugins/env-guard.ts`.
- Registro manual de MCP servers `context7`, `playwright`, `stitch`, `engram` (reusando binario/DB existentes de Engram sin cambios).
- Explícitamente fuera de esta fase: `master-dev` y `explorer` no se portan como subagentes (ver README); `permission-autopilot`, `agent-identity`, `opencode-notify`, `opencode-scheduler`, `opencode-worktree`, `background-agents` no se portan (sin equivalente necesario o cubiertos nativamente por Claude Code); CodeGraph/Ticketing/Documents/github-accounts-local/higyrus-workspace quedan en roadmap.
