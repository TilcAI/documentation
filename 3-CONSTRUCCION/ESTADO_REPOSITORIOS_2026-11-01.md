# Estado de repositorios y entrega

2026-11-01. Se hizo fetch/prune de los cinco checkouts iniciales e integración de main sin
sobrescribir trabajo local. La búsqueda de repositorios de TilcAI encontró ocho: se clonaron
además tilcai-mcp, tilcai-cctp-engine y .github desde su main remoto.

| Repositorio | Rama consultada | HEAD de referencia antes de commits de esta entrega |
| --- | --- | --- |
| documentation | `main` | `220d7ea` |
| tilcai-core | `main` | `f642c25` |
| tilcai-infrastructure | `feat/qr-providers-fallback` | `39cc88e` |
| tilcai-sdk | `feat/third-party-credentials` | `c7fce62` |
| tilcai-web | `feat/qr-gateway-events` | `d0a06bd` |
| tilcai-mcp | `feat/third-party-credentials` | `8d5e500` |
| tilcai-cctp-engine | `main` | `4ebfa04` |
| .github | `main` | `068b647` |

Web integró origin/main con merge local d0a06bd; las otras ramas iniciales ya contenían main.
El main local de Web puede seguir detrás: se actualizó la rama de trabajo, sin cambiar ramas
que el usuario no tenía activas. Las ramas remotas y main no reciben push de esta tarea.

Infrastructure conserva en su checkout original los cambios QR/config/deploy y dos commits
locales no publicados. Se creó worktree tilcai-infrastructure-issues desde origin/main:

- fix/saulchoque-vault-soroban-2026-11-01: commit de implementación 73805cc.
- feat/third-party-credentials: parte de 73805cc e incorpora las credenciales; es la rama activa
  del worktree aislado. El checkout original sigue en feat/qr-providers-fallback.
- SDK y MCP: ramas locales feat/third-party-credentials en sus respectivos repositorios.

Los IDs de migración se coordinan: 6 pertenece al QR de la rama original; autenticación usa 7.
Comprobar orden e IDs al integrar ambas ramas, sin cambiar migraciones ya aplicadas.

Validación: backend de credenciales 206 tests unitarios, SDK 85, MCP 7, despliegue Python 5 y
Vault Rust 12. Typecheck backend/SDK/MCP, build SDK/MCP y smoke ESM/CJS del SDK pasaron.
#32 queda pendiente de archivo/restauración real y decisión D-05. Las pruebas SDK de Soroban
no acreditan esa integración completa. La facturación es documentación/propuesta; faltan
normativa/anexo 2026 verificables y definición del titular fiscal antes de integración SIN.

No se crearon claves reales de socios, no se desplegó ni ejecutaron pagos. Los tests usaron
DBs, claves y proveedores sintéticos. La evidencia disponible está en los documentos del índice.
