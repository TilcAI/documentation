---
title: TilcAI — incorporación de personas y agentes compradores
date: 2026-10-08
status: propuesta-de-producto
tags:
  - tilcai
  - usuarios
  - whatsapp
  - mcp
  - cuentas
---

# Incorporación de personas y agentes compradores

**Pregunta:** ¿cómo llega una persona a TilcAI si no tiene agente ni wallet, y cómo se conecta quien ya usa un asistente?

**Respuesta de producto:** hay dos puertas de entrada a la misma infraestructura. La persona nueva usa una experiencia guiada, inicialmente WhatsApp y una pantalla segura para identidad y firma. La persona que ya tiene asistente conecta las herramientas MCP de TilcAI; una aplicación propia puede usar la API y, más adelante, un SDK. Ambas puertas terminan en los mismos servicios de identidad, catálogo, cotización, política, autorización, orden, pago y recibos. El canal de chat no es la autoridad financiera.

**Estado al 8 de octubre de 2026:** el riel USDC Avalanche Fuji → Stellar Testnet está implementado y verificado en el laboratorio. Los contratos compartidos de intención, mandato y herramientas MCP están definidos en tilcai-core, pero el servidor MCP operativo y el ciclo completo de compra siguen pendientes. La emisión de cuentas inteligentes y el modelo de tenants están en fase de construcción. El onboarding por WhatsApp, el fondeo en bolivianos y el catálogo comercial conectado son propuestas, no servicios disponibles.

## 1. Qué recibe el usuario

| Necesidad | Capacidad de TilcAI | Lo que aún debe existir |
| --- | --- | --- |
| Descubrir negocios | Directorio de empresas verificadas y capacidades concretas | Onboarding comercial, catálogo y consulta de disponibilidad |
| Pedir algo en lenguaje natural | Un asistente interpreta y llama herramientas limitadas | Adaptador conversacional de WhatsApp o cliente MCP |
| Comparar alternativas | Cotizaciones con precio, vigencia, stock/cupo y condiciones | Adaptadores empresariales y ofertas verificables |
| Controlar el gasto | Aprobación de compra exacta; después, mandatos limitados | Interfaz de aprobación, políticas, presupuesto y cuentas |
| Pagar y saber qué ocurrió | Riel x402/Stellar o CCTP según la fuente de fondos, conciliación y recibo | Orquestador de órdenes y unión del riel existente con el comercio |

La primera experiencia útil no requiere que el usuario entienda agentes, redes ni protocolos. Tampoco exige crear una cuenta on-chain para consultar empresas y precios. La cuenta se ofrece cuando decide habilitar una compra.

## 2. Dos caminos de entrada

### Camino A — persona nueva, guiada desde WhatsApp

1. La persona inicia conversación con el número oficial de TilcAI. Un mensaje de bienvenida explica qué puede consultar y qué requiere una cuenta. Los botones o listas muestran categorías y empresas aprobadas; no se publican negocios ficticios como aliados.
2. Puede preguntar, por ejemplo, «necesito dos entradas el viernes» o «cotiza 20 bolsas de cemento». El asistente de TilcAI interpreta la intención; el catálogo y la disponibilidad provienen de los negocios, no de la respuesta generativa.
3. Antes de comprar, TilcAI solicita identidad y creación o vinculación de una cuenta en un enlace web seguro. El número de WhatsApp identifica una conversación, no demuestra por sí solo propiedad de fondos. La persona registra una credencial de propietario en su dispositivo (por ejemplo, passkey si la red y el diseño de cuenta lo admiten). TilcAI recibe la clave pública; no pide frases semilla ni claves privadas por chat.
4. La emisión de la smart account y el patrocinio de sus comisiones son parte de la fase SCA planificada. Crear la cuenta no la fondea ni crea automáticamente un agente financiero autónomo.
5. Se muestra cómo fondear: USDC Stellar desde una wallet compatible; USDC desde una red CCTP habilitada, después de verificar esa ruta; o bolivianos mediante un proveedor de entrada fiat habilitado. La última opción requiere un socio real, condiciones comerciales, controles y una integración de depósito. Un QR de pago local sería la instrucción del proveedor; escanearlo no convierte dinero por sí mismo.
6. TilcAI consulta opciones y devuelve ofertas con origen, precio, vigencia, disponibilidad, costes y estado. La persona elige una oferta concreta.
7. En la primera fase comercial, la persona aprueba cada compra exacta en una pantalla segura: negocio, producto, cantidad, importe total, red/activo, destinatario y vencimiento. WhatsApp notifica y conduce al paso seguro; un «sí» escrito en el chat no sustituye la autorización financiera.
8. La infraestructura reserva el presupuesto si aplica, crea una orden idempotente y ejecuta el riel adecuado. Separa «solicitud recibida», «aprobada», «pago liquidado» y «entrega/reserva confirmada».
9. El chat muestra el resultado con recibo y enlaces verificables. Si el pago queda incierto, informa «verificando» y concilia; no repite un cargo a ciegas.

**Qué es el agente aquí:** un asistente gestionado por TilcAI para interpretar y guiar. No necesita una suscripción personal a Codex o Claude. El modelo puede cambiar sin cambiar la cuenta, la política ni el historial de órdenes. Las decisiones y operaciones financieras se ejecutan en servicios deterministas fuera del modelo.

### Camino B — persona que ya usa un agente o aplicación

1. En su asistente compatible configura el servidor MCP remoto de TilcAI. MCP significa **Model Context Protocol**, no «MSP». El cliente descubre herramientas como buscar servicio, pedir cotización, crear intención, solicitar aprobación y consultar orden.
2. Se autentica como persona ante TilcAI con permisos limitados. El agente no recibe una clave maestra del negocio ni la clave privada de la wallet. El soporte real de MCP y del flujo de autenticación se valida por cliente; no se promete compatibilidad automática con cualquier marca.
3. Vincula una cuenta existente o crea una smart account con credencial propia. Puede consultar sin saldo; para pagar debe disponer de fondos en una ruta soportada.
4. El asistente solicita herramientas de TilcAI y presenta opciones. TilcAI valida la intención, la fuente de la cotización, la política y el destinatario.
5. La aprobación exacta ocurre en una interfaz confiable del usuario. La delegación posterior tendrá monto, comercio, tipo de servicio, vigencia y revocación explícitos; conectar MCP no otorga permiso de gasto.
6. Una aplicación empresarial o un agente propio también puede consumir API REST desde un backend autenticado. Un SDK futuro empaquetaría autenticación, tipos, idempotencia y manejo de errores; no sustituiría la API ni MCP.

**API vs. MCP vs. SDK:** la API es el contrato de backend; MCP presenta herramientas al asistente; el SDK es una biblioteca opcional que facilita llamar a la API. A2A se prevé para coordinar agentes de distintas organizaciones, pero no es requisito para que el primer usuario compre a un negocio conectado.

~~~mermaid
flowchart LR
  U1["Persona nueva"] --> W["WhatsApp + pantalla segura"]
  U2["Persona con asistente"] --> M["Cliente MCP"]
  U3["Aplicación propia"] --> A["API REST / SDK futuro"]
  W --> G["Gateway TilcAI"]
  M --> G
  A --> G
  G --> C["Catálogo + cotización verificable"]
  C --> P["Política + aprobación del dueño"]
  P --> O["Orden + riel de pago"]
  O --> R["Conciliación + recibos"]
~~~

## 3. Wallet, fondos y confianza

**Cuenta del usuario, no «wallet del bot».** La persona conserva la credencial de propietario. El agente es software autorizado para pedir acciones; no es dueño de los fondos. El relayer paga comisiones de red cuando el diseño lo permite, pero no decide libremente a quién transferir el saldo.

**Fondeo cripto existente.** Para usuarios técnicos, integrar una wallet compatible y recibir USDC es el camino más corto. La prueba actual solo acredita Fuji → Stellar Testnet; cada red adicional requiere configuración y test de punta a punta. CCTP mueve USDC entre redes compatibles: no convierte bolivianos a USDC.

**Fondeo en bolivianos.** El flujo propuesto es: el proveedor de rampa presenta cotización, tasa, comisiones y requisitos de identidad → el usuario acepta → paga al proveedor mediante el medio local que este soporte, posiblemente QR → el proveedor confirma el fiat → entrega USDC a la cuenta vinculada → TilcAI concilia el depósito. TilcAI no debe mostrar «saldo disponible» basándose únicamente en la captura de un QR o un mensaje. Antes de prometer esta ruta hay que encontrar y evaluar un proveedor que opere realmente en Bolivia, soporte el activo/red requeridos y asuma la conversión y sus obligaciones. El estándar SEP-24 ofrece un patrón de integración con anchors, pero no garantiza un corredor boliviano.

**Recuperación.** Perder el teléfono, cambiar el número de WhatsApp y recuperar una cuenta son problemas distintos. El diseño de recuperación y poderes reales de firmantes se debe revisar antes de usar fondos reales. Ningún operador del chat debería poder reasignar una cuenta solo porque alguien controla el número.

## 4. Una compra ilustrativa

«Cotiza 20 bolsas de cemento para entrega el viernes».

1. TilcAI pregunta cantidad, marca/calidad, ubicación y fecha. No envía datos personales innecesarios a cada negocio.
2. Consulta solo negocios habilitados para cotizar ese producto. Cada uno responde con precio total, disponibilidad, vigencia, entrega, política de cancelación y destino de cobro validado.
3. El usuario compara ofertas. Si el inventario se confirma manualmente, el sistema muestra «pendiente de confirmación»; no lo presenta como stock garantizado.
4. Selecciona una oferta y aprueba el importe exacto. Una modificación de cantidad, precio o destinatario invalida esa aprobación.
5. TilcAI crea la orden, confirma la retención/reserva con el negocio, liquida el pago y espera la confirmación de entrega o retiro. Cada estado tiene evidencia distinta.
6. El usuario recibe un recibo de pago y, más tarde, una constancia de cumplimiento. Si falla una etapa, ve el estado real y la vía de resolución.

El mismo modelo sirve para entradas de cine, reposición de insumos de una cafetería o pagos recurrentes a proveedores; cambian la fuente de disponibilidad, la reserva y el cumplimiento, no la autoridad financiera.

## 5. Qué construir y en qué orden

| Paso | Entregable | Criterio de aceptación |
| --- | --- | --- |
| 1 | Un negocio piloto con catálogo pequeño y cotización trazable | Precios y disponibilidad vienen de una fuente operativa; cambios quedan registrados |
| 2 | Orden, política y aprobación por compra | Una cotización alterada o vencida no se paga |
| 3 | Primer cliente MCP real | Dos solicitudes equivalentes por MCP y API producen las mismas reglas y estados |
| 4 | Onboarding de cuenta SCA | La clave del dueño queda fuera de TilcAI; creación y recuperación se prueban |
| 5 | WhatsApp como canal guiado | Reintentos y mensajes duplicados no duplican órdenes ni pagos |
| 6 | Fondeo fiat con socio validado | Depósito se acredita solo tras confirmación verificable del proveedor |
| 7 | Delegación limitada y compras repetidas | Límites, pausa y revocación funcionan incluso con operaciones concurrentes |

El piloto más convincente muestra una compra real de testnet de punta a punta antes de prometer «cualquier empresa» o «cualquier blockchain».

## 6. Decisiones que necesita el equipo

1. ¿La primera cuenta de usuario será Stellar SCA, EVM SCA o ambas? La experiencia de WhatsApp debe ocultar complejidad, no ocultar qué red y activo usa el pago.
2. ¿Quién provee la credencial de propietario y el mecanismo de recuperación? La respuesta determina custodia y seguridad.
3. ¿Qué socio, si alguno, permite BOB → USDC Stellar en Bolivia y qué condiciones exige? Sin socio, esta entrada queda fuera del piloto.
4. ¿Qué cliente MCP se valida primero? Elegir uno y probar autenticación, permisos y aprobación, en vez de anunciar compatibilidad general.
5. ¿Qué operación concreta se completa primero: reserva de servicio, compra de producto o pago a proveedor? Debe tener un negocio real y una fuente de verdad.

## Referencias

- [Informe de producto TilcAI](../TILCAI_NUEVO_RUMBO_COMERCIO_AGENTICO_2026-09-29.md), §§ 5, 10–12 y 17.
- [Plan backend](../TILCAI_PLAN_ARQUITECTURA_BACKEND_INFRA_2026-10-02.md), §§ 12 y 15.
- [Fase SCA](../TILCAI_FASE_SCA_EMISION_DE_CUENTAS_2026-10-06.md), §§ 4 y 7–8.
- [WhatsApp Business Platform, funciones interactivas](https://whatsappbusiness.com/products/business-platform-features/) y [colecciones oficiales de Meta](https://www.postman.com/meta/whatsapp-business-platform/overview).
- [Especificación de herramientas MCP](https://modelcontextprotocol.io/specification/latest/server/tools) y [autorización MCP](https://modelcontextprotocol.io/specification/latest/basic/authorization).
- [Stellar: depósito y retiro SEP-24](https://developers.stellar.org/docs/platforms/anchor-platform/sep-guide/sep24/getting-started) y [transferencias CCTP](https://developers.stellar.org/docs/tokens/cross-chain-transfers).
