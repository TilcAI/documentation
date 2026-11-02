# Documentación de TilcAI

**Actualizada:** 2 de noviembre de 2026 (UTC). Este índice es la entrada para el equipo.

## Leer en este orden

1. **[Contexto oficial](0-OFICIAL/CONTEXTO_OFICIAL_TILCAI.md):** producto, límites, estado verificable y criterio de la demo. Si un plan antiguo afirma otro estado, comprobar el repositorio y esta matriz.
2. **[Infraestructura integrada](2-ARQUITECTURA/TILCAI_FLUJO_INTEGRADO_Y_DEMO_2026-10-08.md):** diagramas, secuencia, wallets, rieles, cobertura de redes y pruebas.
3. **[Incorporación de compradores](2-ARQUITECTURA/TILCAI_ADOPCION_USUARIOS_2026-10-08.md)** y **[negocios](2-ARQUITECTURA/TILCAI_ADOPCION_EMPRESAS_PYMES_2026-10-08.md):** propuestas de adopción, no funciones terminadas.
4. **[Monitorización: del backend al tablero](2-ARQUITECTURA/TILCAI_MONITORIZACION_EVENTOS_BACKEND_FRONTEND_2026-10-09.md):** qué eventos registra el backend, cómo llegan firmados a `tilcai-web`, cómo se guardan e interpretan, y qué falta para el tablero.
5. **[Issues asignadas](3-CONSTRUCCION/ISSUES_PROPUESTAS_2026-10-08.md):** backlog con dependencias, aceptación y enlaces a diez issues nuevas ya creadas y asignadas en GitHub; distingue el trabajo que el equipo tenía abierto.

## Mapa

| Ubicación | Uso |
| --- | --- |
| `0-OFICIAL/` | Definición vigente, evidencia, reglas para el pitch. |
| `1-PRESENTACION/` | Memoria del primer pitch del 2 de octubre. |
| `2-ARQUITECTURA/` | [Mapa de lectura](2-ARQUITECTURA/README.md), diagramas y diseño de integración. |
| `3-CONSTRUCCION/` | Backlog asignado y criterios de aceptación. |

Se conservan en la raíz, para no romper enlaces, cuatro **fuentes fechadas**: [visión de comercio agéntico, 29/09](TILCAI_NUEVO_RUMBO_COMERCIO_AGENTICO_2026-09-29.md), [plan backend, 02/10](TILCAI_PLAN_ARQUITECTURA_BACKEND_INFRA_2026-10-02.md), [fase SCA, 06/10](TILCAI_FASE_SCA_EMISION_DE_CUENTAS_2026-10-06.md) y [plan web original, 29/09](TILCAI_WEB_FASE_1_DISENO_MARCA_IMPLEMENTACION_2026-09-29.md). Aportan detalle, pero su fecha no acredita que todo esté implementado.

**Regla de actualización:** el código y sus pruebas determinan lo implementado; una prueba testnet acredita la ruta reproducida, no todas las rutas previstas. `0-OFICIAL` resume el estado y las decisiones de producto; `2-ARQUITECTURA` desarrolla el diseño; `3-CONSTRUCCION` enumera lo pendiente. Al integrar algo, añadir commit/PR, fecha y evidencia E2E a la matriz oficial. Separar **implementado**, **verificado**, **reportado por el equipo**, **propuesto** y **pendiente**. Una simulación web o matriz de redes no es una compra comercial operativa.

## Implementación y pendientes · noviembre de 2026

- [Facturación SIN: empresa única y terceros](2-ARQUITECTURA/TILCAI_FACTURACION_SIN_2026-11-01.md). Propuesta con requisitos fiscales, arquitectura, fases y validaciones pendientes de normativa 2026.
- [Plan de issues de SaulChoque](3-CONSTRUCCION/PLAN_ISSUES_SAULCHOQUE_2026-11-01.md). Análisis del backend y criterios de implementación.

- [Decisión API keys/OAuth](3-CONSTRUCCION/DECISION_AUTENTICACION_TERCEROS_2026-11-01.md). API keys para integraciones de backend; OAuth para futura delegación de usuario/MCP remoto.
- [Implementación de credenciales](3-CONSTRUCCION/CREDENCIALES_TERCEROS_IMPLEMENTACION_2026-11-01.md): CLI, caducidad, rotación, SDK 0.3.0 y MCP.
- [Resultados de Vault/Soroban](3-CONSTRUCCION/RESULTADOS_VAULT_SOROBAN_2026-11-01.md) e [investigación TTL](3-CONSTRUCCION/INVESTIGACION_TTL_SOROBAN_2026-11-01.md).
- [Estado de repositorios y entrega](3-CONSTRUCCION/ESTADO_REPOSITORIOS_2026-11-01.md).

- [QR desde payload y configuración bancaria](3-CONSTRUCCION/QR_PAYLOAD_Y_CONFIGURACION_2026-11-02.md): comportamiento, pruebas y valores publicados.

Las ramas de esta entrega están publicadas. El estado de repositorios distingue publicación, integración y despliegue; SIN y TTL conservan pendientes.
