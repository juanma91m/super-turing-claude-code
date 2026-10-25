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

En un proyecto que admite handoff, este comando con ticket concreto es pedido explícito. Si el proyecto no lo habilita (por ejemplo review-only), entregar el veredicto en la respuesta sin crear `tmp/`; un ID aislado no lo activa. Rovo es complemento solo si falta contexto material y el caller tiene acceso aprobado; pasá su evidencia destilada al planner sin exigirle una tool que no tenga.

Secciones del veredicto (archivo solo con handoff activo):
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
