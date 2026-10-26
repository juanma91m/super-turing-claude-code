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

Seguí `code-review-branch-to-branch` y el contrato del agente efectivo, incluidos los requisitos locales de ticket, cuenta/helper y storage. Este comando no los reemplaza ni amplía permisos.

Si falta el PR, pedí aclaración antes de revisar.
