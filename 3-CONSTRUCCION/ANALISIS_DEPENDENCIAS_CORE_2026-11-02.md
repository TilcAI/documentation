# Consumo y evolución de tilcai-core

Análisis estático de checkouts locales, 2026-11-02. Se revisaron los ocho repositorios.
Infrastructure main: 57391c1; SDK y MCP: ramas feat/third-party-credentials; otros: main.
No se ejecutaron tests ni se modificaron dependencias o despliegues.

## Dependencias actuales

| Repositorio | Relación comprobada | Recomendación |
| --- | --- | --- |
| tilcai-infrastructure | Dependencia file:../tilcai-core; imports de tipos y funciones en runtime | Consumir contratos estables mediante paquete versionado |
| tilcai-sdk | Sin dependencia declarada; copias en src/core y reexports desde raíz y subpath /core | Sustituir espejos por consumo explícito y versionado tras revisar distribución |
| tilcai-mcp | Sin dependencia de Core ni del SDK; cliente HTTP propio | Compartir contratos de API; mantener transporte en MCP |
| tilcai-web | Sin dependencia; contratos propios de monitorización y fixtures de demo | Consumir contratos de monitor si se estabilizan; mantener UI y fixtures locales |
| tilcai-cctp-engine | Sin dependencia; laboratorio con codificación y configuración propias | Compartir utilidades puras solo cuando coincidan semánticas |
| documentation | Documenta Core; no ejecuta una aplicación dependiente | Referenciar versiones y decisiones |
| .github | Perfil y coordinación; sin consumo de Core | Referenciar documentación |
| tilcai-core | Define contratos, autoridad, política prototipo y catálogo MCP de dominio | Separar superficie estable y experimental |

## Qué utiliza infraestructura

- src/shared/ids.ts ejecuta ID_PREFIXES y parseId para generar/validar IDs compartidos. UUID y entidades locales siguen en infraestructura.
- src/shared/errors.ts ejecuta createContractError y consume ErrorCode/ContractError. La traducción a estados HTTP es local.
- src/modules/crosschain/domain.ts ejecuta canTransition para validar cambios de estado del pago.
- Puertos de agents/principals/businesses/commerce/payments/receipts/budgets/identity consumen IDs, estados y referencias como tipos.
- Puertos de policies y authorization consumen Intent, Mandate, ApprovalBinding y tipos de decisiones. Son interfaces; no prueban que el motor de políticas comercial esté integrado.
- test/unit/crosschain-service.test.ts importa canTransition para las comprobaciones del servicio.

Estos usos de runtime impiden eliminar simplemente la dependencia sin sustitución y regresiones.
No se encontró import del evaluador evaluateIntent de Core en el backend revisado.

## Qué copia y expone el SDK

src/core/contracts.ts, authority.ts y policy.ts declaran que son espejos de Core.
La raíz exporta el namespace core y package.json expone tilcai-sdk/core. Son parte de la
superficie distribuible del SDK, no evidencia de que payments.pay ejecute esa política.

Comparación estática: policy coincide sin su cabecera; authority coincide al normalizar la
extensión del import; contracts tiene una diferencia de acceso opcional al grafo en canTransition.
La duplicación permite divergencias. Antes de publicar un paquete SDK, revisar la inclusión de
esos módulos y la visibilidad/condiciones de distribución del Core original.

MCP no importa este SDK en su implementación actual. Comparte el contrato HTTP de forma
conceptual, pero define su propio cliente, respuestas y errores. Decir que todos los repos
consumen Core indirectamente a través del SDK no describe el código actual.

## Candidatos de extracción

| Prioridad | Candidato y evidencia | Límite |
| --- | --- | --- |
| 1 | Contratos API: PaymentState, respuestas de pagos, credenciales y errores repetidos en backend/SDK/MCP | Tipos de transporte no tienen por qué mezclarse con política de dominio; usar submódulo contracts o paquete separado |
| 1 | MonitorEvent, MonitorDelivery, MONITOR_SCHEMA y enumeraciones en backend, web y SDK | Versionar esquema, compatibilidad y parsers; mantener repositorio, SSE y UI locales |
| 2 | decimalToAtomic, atomicToDecimal y rescale del backend y utilidades de importes del SDK | Definir ceros, signos, límites y decimales antes de unificar; preservar errores públicos mediante adaptadores |
| 2 | Identidad de redes y entorno compartida por backend/SDK/MCP | Separar IDs/validación de RPCs, claves, direcciones de contratos y configuración de instancia |
| 3 | Reglas puras de autorización: alcance, vencimiento, límites y compromiso de intención | Solo con semántica acordada y pruebas; disponibilidad de presupuesto viene de almacenamiento actualizado |
| 3 | Codificación CCTP y verificación pura de campos compartidas con laboratorio/SDK | Preferible paquete de protocolo separado si introduce dependencias criptográficas o de cadenas |
| Opcional | Formato/firma HMAC de entregas repetido en backend y web | Módulo servidor separado; no arrastrar node:crypto a consumidores de navegador |

## Diferencias detectadas antes de extraer

1. authority usa stellar:mainnet; el registro operativo del SDK usa stellar:pubnet.
   Decidir identificador canónico y compatibilidad: no cambiar referencias históricas sin migración.
2. El parser de importes de infraestructura admite cero, rechaza espacios y ceros iniciales,
   y elimina ceros fraccionarios finales antes de validar precisión. El SDK recorta espacios,
   admite ceros iniciales, exige importe positivo y cuenta todos los decimales escritos.
   También difieren en representación negativa y decimales cero. No son intercambiables.
3. policy.ts conserva amountMicros y presupuestos como number y comprueba Number.isSafeInteger; cualquier evolución financiera
   requiere límites de entero seguro o migración explícita a bigint/cadenas atómicas.
4. Backend incluye eventos qr.collection_* y qr.provider_failed que no aparecen en el catálogo
   de monitor del main local de web. Verificar compatibilidad con el parser y la rama QR web;
   este hallazgo estático no acredita por sí solo una pérdida de eventos en producción.
5. El catálogo MCP de dominio de Core describe intención/mandato; no se debe imponer sin
   revisión al catálogo de herramientas HTTP financieras que ya expone tilcai-mcp.

## Qué debe seguir en infraestructura

Clientes de bancos y relayer, cifrado específico del proveedor, secretos, autenticación HTTP,
SQLite/migraciones, reservas concurrentes, reconciliación basada en RPC, envío de transacciones,
reintentos persistentes y coordinación de workers. Core puede expresar una regla pura;
infraestructura debe obtener evidencia y ejecutarla de manera consistente con su almacenamiento.
UI, fixtures, acceso a wallets, transporte MCP y scripts de laboratorio conservan su repositorio.

## Secuencia propuesta

1. Inventariar exports consumidos y etiquetar contratos estables/experimentales.
2. Resolver las diferencias de redes e importes con casos de compatibilidad.
3. Publicar un paquete compilado y versionado con subpaths; acordar acceso de CI y visibilidad
   compatible con consumidores del SDK. No asumir que la privacidad del repo permite
   redistribuir todo su contenido en otro paquete.
4. Sustituir espejos del SDK y dependencia file del backend mediante cambios revisados,
   con pruebas de compatibilidad, de transiciones y de integración entre consumidores.
5. Extraer monitor y contratos API de forma incremental; no agregar Core a todos los repos
   solo por pertenecer a TilcAI. Evaluar un paquete contracts separado si Core crece demasiado.

La propuesta requiere una implementación posterior. No implica autorización para publicar
paquetes, modificar accesos, migrar datos o mover políticas activas en esta revisión.

Implementación posterior: ver [centralización Core 0.1.0](CENTRALIZACION_CORE_2026-11-02.md). El análisis anterior conserva el estado previo a esa rama.
