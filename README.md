# Documentación de TilcAI

**Actualizada:** 9 de octubre de 2026. **Próxima presentación:** sábado 10 de octubre. Este índice es la entrada para el equipo.

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
