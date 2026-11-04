# Integración, ramas e issues · 2026-11-04

## Versiones integradas

| Repositorio | Integración | Resultado |
| --- | --- | --- |
| Core | PR8, 1e31247 | @tilcai/core@0.1.0 privado en GitHub Packages; contratos estables y subpaths experimentales |
| Infrastructure | PR52, e2685cb | Core privado por alias npm y secreto BuildKit |
| Infrastructure | PR48, 1de7888 | Evidencia payout, reservas atómicas y preflight Soroban; investigación TTL local |
| Infrastructure | PR53, c2f57a9 | Caducidad, entorno, rotación y contexto de credenciales; migración 8 |
| SDK | PR1, b866d30 | QR, proveedor dinámico de credenciales, introspección y Core externo |
| MCP | PR1, 66a5077 | Contexto de autorización, recarga de secretos y contratos Core |
| documentation | PR4, 5e96109 | Centralización y análisis de dependencias |
| Web | Pendiente por decisión del usuario | No integrar Core privado antes de separar el monitor |

SDK/MCP no se publicaron nuevamente en npm. Core es privado: la instalación de consumidores necesita acceso autenticado. La facturación SIN continúa como diseño sin habilitación ni módulo fiscal desplegado.

## Migraciones y operación

Las migraciones desplegadas 1–7 se conservan: 6 corresponde a QR, 7 a cuotas patrocinadas y 8 a credenciales. La rama original de credenciales usaba 7 y se resolvió la colisión antes de integrar. Los tests cubren actualización desde esquemas 5 y 7. Claves emitidas históricas quedan en testnet sin vencimiento hasta rotarlas; inventariar y reemitir explícitamente antes de cualquier mainnet.

Las correcciones Vault recientes de main se conservaron al resolver conflictos. Ninguna de estas integraciones despliega o actualiza contratos Soroban, hace pagos ni emite claves de socios durante pruebas. El despliegue automático corresponde a la aplicación en el servidor, con healthcheck y rollback existentes.

## Limpieza remota

Ocho ramas demostradas ancestros de main y eliminadas: feat/mainnet-support, feat/n-14-sponsored-quota, feat/qr-providers-fallback, feat/sca-m1-datos, fix/n-01-atomic-settlement, fix/n-10-terminal-reschedule, fix/relayer-monad-server y merge/shared-core-to-main.

La rama fix/saulchoque-vault-soroban-2026-11-01 se eliminó después de PR48 por squash. feat/continuous-deploy-baneco se retiró porque su única diferencia restante elimina Core vendorizado, eliminación ya aplicada en main y sustituida por GitHub Packages. No se reincorporó su workflow obsoleto.

La rama remota feat/third-party-credentials fue retirada tras integrar PR53 por squash. Se retiraron trece ramas locales integradas/sustituidas sin eliminar directorios de worktree. La copia local de fix/relayer-monad-server conserva cambios sin commit y se respeta. Se conservan las ramas de OmarQV con PR43–47 y qa/fase1-reproduccion de JHAMILCALI con commits pendientes. La selección de integraciones se limitó al trabajo de SaulChoque.

## Issues y criterios de cierre

| Issue | Entrega | Condición pendiente |
| --- | --- | --- |
| #28 | Guardas de evidencia y regresión con reinicio en PR48 | Revisión independiente del DoD |
| #35 | Reserva SQLite, coherencia de snapshot y replay concurrente en PR48 | Revisión independiente del DoD |
| #42 | Parser exacto, validación previa y manifiesto de recuperación en PR48 | Revisión independiente del DoD |
| #32 | Matriz TTL, archivo/restauración, renovación y reinicio con ledger sintético local | Revisión y aceptación D-05 del horizonte operativo |

Se dejaron actualizaciones de evidencia en las cuatro issues. No se cierran requisitos de aceptación humana por inferencia a partir del merge. Las PRs implementadas quedan cerradas mediante su integración; las PRs ajenas con trabajo pendiente permanecen abiertas.

## Verificación

PR48: 247 tests TypeScript, 5 Python, 5 evidencia offline, 12 Rust; lint/typecheck correctos. PR53: 253 tests TypeScript, 5 Python y 5 evidencia offline; lint/typecheck correctos. CI valida además el contenedor. No se repitió el experimento TTL completo ni se ejecutó test:integration financiero.

## Actualización local

Fetch/prune por repositorio. Core, SDK, MCP y documentación se actualizaron a main; los dos directorios principales de infraestructura incluyen los merges y npm ci. Web, CCTP y .github ya estaban al día. Las ediciones locales de AGENT_HISTORY se preservaron. La migración experimental de web queda separada.
