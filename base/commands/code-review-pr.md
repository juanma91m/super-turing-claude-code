---
description: Revisa un Pull Request de GitHub por URL, número o rama con ticket/contexto opcional.
argument-hint: "[url|numero|rama] [ticket-o-contexto]"
arguments:
  - name: pr
  - name: contexto
---
Delegá esta tarea al subagente `code-reviewer` (Agent tool, subagent_type: code-reviewer) con estas instrucciones:

Revisá el Pull Request de GitHub `$pr`.

Contexto o ticket opcional: `$contexto`.

Usá solo operaciones read-only aprobadas. Antes del diff, verificá que el repositorio del PR coincida con el `origin` actual (usando la skill `github-cuentas-multiples` si hay más de una cuenta involucrada), reconciliá el ticket explícito con título/head branch y registrá los commits exactos revisados. Aplicá `code-review-branch-to-branch` y guardá el informe incremental en el storage definido por el agente efectivo.
