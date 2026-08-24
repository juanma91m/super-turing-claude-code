---
description: Consolida el veredicto final de planning en tmp/<ticket>/verdict.md cuando el proyecto usa workflow de tickets.
argument-hint: "[ticket]"
---
Delegá esta tarea al subagente `planner` (Agent tool, subagent_type: planner) con estas instrucciones:

Consolidá el `verdict.md` del ticket `$ARGUMENTS`.

Objetivo:
- revisar `tmp/$ARGUMENTS/` si existe,
- sintetizar el estado final del plan,
- dejar `tmp/$ARGUMENTS/verdict.md` actualizado cuando el proyecto usa el patrón de handoff (podés escribirlo con `bash ~/.config/opencode/scripts/jira_helper.sh verdict $ARGUMENTS --content "..."`, que sandboxea la escritura a `tmp/$ARGUMENTS/`).

Secciones obligatorias:
- Problema / Objetivo
- Alcance
- Estado actual
- Causa / Hipótesis vigente
- Solución propuesta
- Validación esperada

Secciones opcionales a criterio:
- Riesgos
- Evidencias
- Dudas abiertas
