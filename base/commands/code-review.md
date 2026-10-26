---
description: Revisa una rama origen contra una rama destino y guarda un informe incremental según el contrato del repo.
argument-hint: "[rama-origen] [rama-destino]"
arguments:
  - name: origen
  - name: destino
---
Delegá esta tarea al subagente `code-reviewer` (Agent tool, subagent_type: code-reviewer) con estas instrucciones:

Revisá el desarrollo de la rama origen `$origen` contra la rama destino `$destino`.

Seguí `code-review-branch-to-branch` y el contrato del agente efectivo. Conservá los requisitos de ticket, helper y storage del repo; este comando no los reemplaza ni amplía permisos.

Si falta cualquiera de las dos ramas o la orientación es ambigua, pedí aclaración antes de revisar.
