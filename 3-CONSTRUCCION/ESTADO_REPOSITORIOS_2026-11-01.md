# Estado de repositorios y entrega

Actualizado: 2026-11-02 UTC. Reemplaza el estado previo a publicación del 1 de noviembre.
Las ramas locales se publicaron mediante push. Publicación no acredita merge, despliegue
ni validación contra redes reales. Los historiales conservan sus salidas originales.

## Ramas publicadas

| Repositorio | Rama | Commit de referencia | Alcance |
| --- | --- | --- | --- |
| documentation | main | d4abb52, antes de esta actualización | Planes, resultados, credenciales y SIN |
| tilcai-core | main | 9f980e9 | Documentación e historial |
| tilcai-infrastructure | fix/saulchoque-vault-soroban-2026-11-01 | f2cf032 | Implementación 73805cc de #28/#35/#42 y resultados |
| tilcai-infrastructure | feat/third-party-credentials | b47165e | Credenciales 60e3199 e integración de fixes |
| tilcai-infrastructure | feat/qr-providers-fallback | e064378 | Gateway, payload QR y configuración |
| tilcai-sdk | feat/third-party-credentials | f27f333 | Introspección y proveedor dinámico de API key |
| tilcai-mcp | feat/third-party-credentials | 2417706 | Introspección y recarga de archivo de credencial |
| tilcai-web | feat/qr-gateway-events | 6b3179f | QR/eventos |
| tilcai-web | main | 5c5701e | Main local actualizado mediante fast-forward |
| tilcai-cctp-engine | main | 4b87515 | Historial y documentación |
| .github | main | b57044f | Historial |

Los SHA son referencias de esta entrega; el remoto puede avanzar. También se publicaron
las otras ramas locales existentes. Infrastructure usa worktrees separados: correcciones,
credenciales y QR. Credenciales incorpora los fixes Vault/Soroban; no incorpora automáticamente QR.

## Correspondencia con solicitudes e issues

Consulta GitHub del 2026-11-02 UTC: las cuatro issues de saulchoque siguen abiertas.

| Solicitud | Resultado | Pendiente |
| --- | --- | --- |
| Actualizar repositorios, analizar y planear | Ocho repositorios sincronizados/publicados; plan por issue | Revisar e integrar ramas |
| #28: evidencia de payout | Conserva estado incierto y reserva sin evidencia concordante | Revisión de aceptación antes de cierre |
| #35: capacidad concurrente | Admisión dentro de transacción SQLite; prueba con dos conexiones | Revisar política de snapshot y UTC |
| #42: despliegue Soroban | Parser seguro/exacto, validaciones y manifiesto durable | Revisión de recuperación y aceptación |
| #32: replay tras TTL | Experimentos SDK y protocolo documentados | Archivo/restauración real y decisión D-05 |
| Autenticación para terceros | API keys por tenant/entorno/scopes, caducidad, rotación y revocación; SDK/MCP | Rollout y onboarding real; OAuth remoto es fase separada |
| Facturación SIN | Diseño de empresa única y terceros | Normativa/anexos vigentes, titular fiscal, habilitación e implementación |
| QR desde payload en desarrollo/producción | dfb7006: misma función generadora para ambos entornos | No acredita cobro bancario real |
| Publicar todos los cambios | Push completado, incluidos configuración e historiales | No equivale a merge o despliegue |

Issues: [#28](https://github.com/TilcAI/tilcai-infrastructure/issues/28),
[#35](https://github.com/TilcAI/tilcai-infrastructure/issues/35),
[#42](https://github.com/TilcAI/tilcai-infrastructure/issues/42) y
[#32](https://github.com/TilcAI/tilcai-infrastructure/issues/32).

## Validación y límites

Evidencia previa: backend de credenciales 206 tests, SDK 85, MCP 7, despliegue Python 5 y
Vault Rust 12. Typecheck backend/SDK/MCP, builds SDK/MCP y smoke ESM/CJS del SDK pasaron.
La corrección QR posterior pasó las 15 pruebas de QR Simple. No se volvieron a ejecutar
estas suites al publicar configuración/historiales ni al editar esta documentación.

Migración 6 corresponde a QR y 7 a autenticación. Comprobar orden al integrar ramas, sin
cambiar migraciones aplicadas. Desplegar backend compatible antes de SDK/MCP con introspección.
No se emitieron claves reales de socios ni se ejecutaron pagos o despliegues en esta entrega.
La facturación sigue siendo propuesta; la investigación TTL sigue parcial.

Ver [resultados Vault/Soroban](RESULTADOS_VAULT_SOROBAN_2026-11-01.md),
[credenciales](CREDENCIALES_TERCEROS_IMPLEMENTACION_2026-11-01.md) y
[QR y configuración](QR_PAYLOAD_Y_CONFIGURACION_2026-11-02.md).
