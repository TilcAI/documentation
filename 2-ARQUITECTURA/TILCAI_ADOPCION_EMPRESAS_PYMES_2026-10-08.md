---
title: TilcAI — incorporación de empresas, negocios y PYMES
date: 2026-10-08
status: propuesta-de-producto
tags:
  - tilcai
  - empresas
  - comercios
  - integracion
  - modelo-comercial
---

# Incorporación de empresas, negocios y PYMES

**Pregunta:** ¿por qué usaría TilcAI una empresa que no tiene página moderna, agente de IA ni equipo técnico?

**Respuesta:** no tiene que comprar ni programar un agente para empezar. TilcAI puede ofrecerle una **consola comercial gestionada** donde publique un catálogo pequeño, confirme disponibilidad, reciba solicitudes, emita cotizaciones y vea órdenes y pagos. Esa consola alimenta un adaptador empresarial con reglas verificables. Para negocios con sistema propio, el mismo adaptador se conecta por API, webhooks o un conector específico. Un asistente de IA que atienda en lenguaje natural es una capa opcional; las operaciones críticas siguen respaldadas por datos y permisos del negocio.

**Estado al 8 de octubre de 2026:** la infraestructura tiene un riel crosschain Fuji → Stellar Testnet probado, contratos compartidos y puertos de módulos comerciales. No hay un portal de comercio, catálogo/stock real conectado, agente vendedor operativo ni compra comercial completa listos para ofrecer a PYMES. Lo siguiente es una propuesta de adopción, no una descripción de un producto ya lanzado.

## 1. Problema, solución y prueba

| Problema de la PYME | Qué propone TilcAI | Cómo se demuestra |
| --- | --- | --- |
| Llegan pedidos por chat y nadie sabe si el precio o stock está vigente | Catálogo con versión, vigencia y fuente de disponibilidad | La cotización reproduce exactamente los datos publicados o confirmados |
| Un cliente pregunta mientras el dueño está ocupado | Bandeja de solicitudes; respuestas estructuradas y, opcionalmente, asistente | Se responde o queda pendiente de un operador; no se inventa disponibilidad |
| Reservas y pedidos se duplican o se pierden | Orden identificable, idempotencia y estados | Un reintento no crea otra reserva ni otro cargo |
| Pago, venta y entrega quedan en canales diferentes | Pago conciliado y recibos vinculados a la orden | El negocio ve qué se pagó y qué falta entregar |
| Un agente externo no sabe cómo comprarle al negocio | Capacidad comercial común y adaptador de TilcAI | Dos clientes compradores usan el mismo catálogo y las mismas reglas |

**Frase comercial honesta:** «Conectamos tus productos o servicios a solicitudes de clientes asistidos por IA; tú conservas los precios, la disponibilidad, el destino de cobro y la confirmación de entrega. Podemos empezar con un portal sencillo, sin reemplazar tu sistema ni contratar un agente propio».

**Qué no vendemos en esta primera etapa:** un modelo que adivina inventario, un plugin universal para cualquier POS, pagos fiat bolivianos ya resueltos, compras sin aprobación, ni un chatbot genérico separado de la operación comercial.

## 2. Qué significa «agente de la empresa»

En TilcAI, el agente vendedor es la **interfaz operativa** que responde solicitudes mediante capacidades autorizadas: consultar servicios, devolver disponibilidad, cotizar, retener cupo, confirmar orden y reportar cumplimiento. Puede implementarse de tres maneras:

1. **Sin modelo de IA (recomendado para el piloto):** servicio de reglas + catálogo/portal + operador humano cuando haga falta. Es el modo más barato y comprobable. Ya «escucha» solicitudes estructuradas de agentes compradores.
2. **Asistente gestionado por TilcAI:** un runtime compartido interpreta preguntas y usa las mismas herramientas. El modelo redacta o clasifica; no fija por sí solo precio, stock, cobro ni autoridad. El negocio puede pagar por uso y establecer un tope mensual.
3. **Agente propio de la empresa:** su equipo conecta su servidor o aplicación mediante API y, más adelante, A2A. TilcAI conserva las verificaciones, la orden y el riel de pago. La empresa elige y paga su proveedor de IA si usa uno.

No hace falta entrenar un modelo por empresa ni dejar una instancia permanentemente encendida para cada negocio. La decisión de producto recomendada es **ofrecer la puerta de entrada gestionada**, sin convertir la construcción de chatbots a medida en el núcleo de TilcAI. Esto amplía el alcance del informe de producto hacia una consola de incorporación y operación; el equipo debe ratificar el alcance y su coste.

## 3. Cuatro caminos de integración

| Camino | Para quién | Qué instala o administra el negocio | Qué entrega TilcAI | Primera capacidad segura |
| --- | --- | --- | --- | --- |
| A. Consola gestionada | Negocio sin software ni agente | Usuario operador; catálogo y disponibilidad manual | Portal privado, adaptador, bandeja, cotizaciones y órdenes | Consultar y solicitar cotización; confirmar manualmente |
| B. Archivo o sincronización simple | Negocio con planilla o sistema cerrado | Exportación CSV/hoja y revisión de cambios | Importador validado y publicación versionada | Catálogo; stock sujeto a actualización o confirmación |
| C. API/webhooks o conector POS | Negocio con sistema de ventas/inventario | Credenciales, endpoints y mapeo de productos | Adaptador específico con pruebas y eventos | Precio/stock en tiempo real y retención si el sistema lo permite |
| D. Agente propio | Empresa con equipo técnico | Su runtime, credenciales y reglas internas | API comercial, herramientas y futura interoperabilidad A2A | Capacidad certificada por operación, no acceso irrestricto |

Un mismo negocio puede pasar de A a C sin perder su identidad, historial de órdenes o destino de cobro. «Plugin» significa un conector para un producto concreto y versionado, no un archivo mágico que entiende cualquier inventario. El SDK futuro reduce trabajo de integración para desarrolladores; la consola resuelve la adopción de quienes no tienen desarrolladores.

## 4. Incorporación paso a paso del primer negocio

1. **Elegir un caso limitado.** Por ejemplo, una ferretería con dos marcas de cemento y retiro en tienda; o un cine con una función concreta. No empezar con todo el catálogo.
2. **Registrar la empresa.** Nombre comercial, contacto del operador, categoría, ubicación, políticas de entrega/cancelación y persona responsable. La publicación del nombre y logo requiere autorización.
3. **Definir su tenant y permisos.** Cada negocio o integrador opera bajo identidad propia. Los usuarios del portal tienen roles separados: operador de ventas, administrador de catálogo y administrador de cobro. Una credencial técnica no se pega en el navegador ni en el chat.
4. **Vincular cuenta de cobro.** El titular demuestra control de la cuenta y fija el destino permitido. Cambiarlo exige autenticación fuerte, nueva verificación y versión; una cotización antigua no autoriza pagar a un destino nuevo.
5. **Cargar la oferta.** Producto o servicio, identificador interno, precio o regla de cotización, impuestos/costes visibles cuando correspondan, stock/cupos, horario, zona, plazo de respuesta y vigencia. Cada dato tiene fuente y fecha de actualización.
6. **Elegir grado de automatización.** «Consulta automática» es diferente de «precio automático», «reserva» y «confirmación de venta». Si el negocio no puede prometer stock en tiempo real, la respuesta queda pendiente de confirmación humana.
7. **Probar escenarios negativos.** Precio vencido, stock cero, pedido duplicado, operador sin permiso, destino de cobro cambiado, pago incierto y reserva caducada.
8. **Activar un piloto acotado.** Lista de clientes permitidos, red de prueba, topes de importe, soporte humano y observación de cada estado. La habilitación de fondos reales requeriría decisiones y verificaciones adicionales.

### Ejemplo: ferretería sin página ni agente

El dueño entra a la consola, carga «Cemento A, bolsa de 50 kg, 20 unidades disponibles para retiro», precio y fecha de actualización. Un usuario pide 20 bolsas por su propio chat. TilcAI consulta el catálogo; si el stock fue cargado manualmente, crea una **solicitud de confirmación**, no una reserva automática. El dueño confirma 20 unidades y vigencia del precio desde la consola. TilcAI presenta la cotización al comprador, valida su aprobación y solo entonces prepara el pago. La ferretería ve la orden pagada y marca «retirado» cuando entrega las bolsas. El recibo financiero y la constancia de entrega son distintos.

### Ejemplo: restaurante con POS

El adaptador consulta menú y disponibilidad en el POS. El pedido se retiene con un identificador de reserva y vencimiento. Si el sistema permite confirmar la orden después del pago, TilcAI coordina ambas etapas y recupera reintentos. Si el POS no soporta retención, el negocio debe aceptar un flujo de confirmación humana o un producto que tolere ese riesgo. No se promete automatización mayor a la capacidad real del POS.

### La misma PYME también puede ser compradora

Una cafetería puede vender sus productos a agentes de clientes y, con otra política, usar TilcAI para reponer café cada semana. El encargado registra proveedor permitido, producto, monto máximo y día de solicitud. El agente pide cotización; un operador confirma recepción o aprueba la compra exacta según la regla vigente. Programar una solicitud no equivale a autorizar todos los pagos futuros. El negocio puede tener ambos papeles bajo una identidad organizacional, con cuentas, roles y presupuestos separados.

Otros segmentos para probar el contrato: peluquería (agenda y reserva), consultorio no regulado (turnos, sin prometer atención sanitaria), taller (repuestos y disponibilidad), librería (catálogo), mayorista (cotización por volumen), ferretería (stock y entrega), restaurante (menú), cafetería (reposición), organizador de eventos (cupos) y proveedor de mantenimiento (visita y presupuesto). Cada uno necesita una fuente de verdad y reglas propias; ninguno justifica anunciar un «conector universal».

## 5. Arquitectura empresarial mínima

~~~mermaid
flowchart LR
  B["Agente comprador o WhatsApp TilcAI"] --> G["Gateway y orden TilcAI"]
  G --> M["Adaptador comercial por negocio"]
  P["Portal del negocio"] --> M
  S["POS / inventario / agenda opcional"] --> M
  A["Agente propio opcional"] --> M
  M --> Q["Oferta y disponibilidad con fuente"]
  Q --> G
  G --> C["Política + aprobación del comprador"]
  C --> R["Pago + conciliación"]
  R --> O["Orden y recibos para ambas partes"]
~~~

**Contrato común propuesto:** businessId y tenantId; serviceId/SKU; disponibilidad con fuente y timestamp; cotización con quoteId, importe/activo, impuestos/costes, payTo verificado, vigencia y condiciones; reserva con holdId y vencimiento; orden con orderId; eventos de pago, cancelación, devolución y cumplimiento. Las operaciones de escritura tienen clave de idempotencia. El modelo de IA solo ve datos necesarios y no recibe claves de cobro ni secretos de integración.

**Principio operativo:** una empresa puede exponer «consultar» antes de poder «cobrar»; puede «cotizar» antes de tener retención de stock; puede cobrar antes de automatizar entrega. TilcAI debe mostrar exactamente qué capacidad está habilitada. A2A es una forma futura de conversación entre agentes, no un requisito para abrir el primer negocio.

## 6. Cómo llegar a las empresas

1. **Vender un resultado, no «IA + blockchain».** «Recibe solicitudes de clientes asistidos, responde con precio vigente y registra pagos y entregas sin perder el control».
2. **Empezar donde duele.** Ferreterías con cotizaciones repetidas, restaurantes con pedidos, salones con agenda, proveedores con recompra semanal. La primera entrevista mide volumen de solicitudes, errores y tiempo de respuesta.
3. **Ofrecer entrada sin migración.** Portal privado y catálogo reducido; después importación; finalmente API/POS si el negocio lo justifica.
4. **Configurar juntos el primer flujo.** Probar una solicitud realista con dueño y operador, registrar excepciones y medir si ahorra trabajo.
5. **Mostrar evidencia.** Cotización, aprobación, pago y entrega vinculados a una orden. Ningún estado se anuncia antes de la evidencia correspondiente.
6. **Convertir el piloto en producto repetible.** Si cada nuevo negocio exige código especial, todavía es consultoría; normalizar capacidades, campos y conectores por categoría.

**Cliente inicial recomendado:** negocio dispuesto a aportar un catálogo acotado y confirmar solicitudes durante el piloto. No es indispensable que ya tenga agente ni sitio web. El valor inicial es más solicitudes atendidas con menos coordinación manual y mejor trazabilidad; el canal de ventas adicional se demuestra con operaciones repetidas, no solo con una demo.

**Para el pitch deck:** mostrar los dos lados en **una sola operación**, no presentar dos productos. Una lámina puede enseñar persona con WhatsApp o agente propio → TilcAI (identidad, oferta, política, autorización, pago) → negocio con portal o POS → recibo y cumplimiento. Otra lámina muestra las dos puertas de incorporación de compradores y las cuatro de empresas. El problema comercial aparece en ambos extremos: el usuario no puede delegar una compra segura y el negocio no tiene una interfaz confiable para atenderla.

## 7. Oferta y modelo de ingresos propuestos

| Oferta | Incluye | Cómo podría cobrarse | Riesgo/coste a medir |
| --- | --- | --- | --- |
| Piloto asistido | Alta, catálogo corto, consola y flujo de testnet | Piloto acordado; eventual tarifa de puesta en marcha | Horas de incorporación y soporte |
| Plataforma básica | Portal, solicitudes, cotizaciones, órdenes, webhooks | Suscripción por negocio + límites de uso claros | Hosting, soporte, mensajes y almacenamiento |
| Asistente gestionado | Interpretación de lenguaje y atención con herramientas | Bolsa mensual de uso con límite y excedentes explícitos | Tokens de modelo, WhatsApp, abuso y revisión humana |
| Integración avanzada | Conector POS/ERP, API, SLA y analítica | Alta técnica + suscripción o volumen | Mantenimiento del conector y cambios del POS |
| Riel de pago | Conciliación y recibos | Evaluar tarifa separada por operación cuando corresponda | Costes de red, relayer, cumplimiento y estructura comercial |

**No fijar todavía «20 USD al mes».** Primero medir por negocio: mensajes entregados, solicitudes, consultas al modelo, coste por token, comisiones patrocinadas, soporte, conversiones y operaciones terminadas. La tarifa debe cubrir esos costes y el valor recibido. La suscripción a una herramienta de programación como Codex o Claude Code **no es una licencia que TilcAI pueda redistribuir** como agente empresarial. Si TilcAI aloja el asistente, contrata un proveedor de modelos mediante la modalidad comercial/API que corresponda, administra la facturación y limita consumo por tenant. Si la empresa trae su propio agente, paga su proveedor y TilcAI le factura la infraestructura acordada.

WhatsApp es un coste aparte y variable por mercado/categoría de mensaje. Una empresa no necesita su número propio en el primer piloto si el comprador habla con TilcAI y el operador atiende en la consola. Si desea atención en su número oficial, se evalúa alta en WhatsApp Business Platform, plantillas, permisos y costes con Meta; no se presume que un número personal o un bot informal sirva como integración comercial permanente.

## 8. Secuencia recomendada de construcción

| Etapa | Construir | Demostración de que funciona |
| --- | --- | --- |
| 0. Base actual | Riel de pago testnet y contratos comunes | Un pago técnico se liquida y se concilia |
| 1. Comercio mínimo | Perfil empresarial, catálogo, cotización, orden y portal de operador | Negocio sin agente responde y confirma una solicitud |
| 2. Compra controlada | Política, aprobación exacta y vínculo orden-pago-entrega | Cliente compra un ítem del catálogo sin pago duplicado |
| 3. Integración repetible | Importador y un adaptador POS o de agenda | Segundo negocio entra sin duplicar el orquestador |
| 4. Canales | MCP para agente comprador y WhatsApp guiado | Mismo negocio atiende solicitudes de dos canales |
| 5. Automatización | Asistente gestionado opcional, A2A y mandatos | El modelo no altera precios ni destinatario; el dueño conserva límites |

La fase SCA puede avanzar en paralelo: emite cuentas y separa tenants, pero no reemplaza catálogo, cotización u órdenes. La primera compra comercial necesita ambas mitades.

## 9. Decisiones que debe cerrar el equipo

1. ¿La consola empresarial entra en el producto principal? Recomendación: **sí**, como interfaz ligera de onboarding y operación; no como constructor general de websites o chatbot personalizado.
2. ¿Qué vertical prueba primero el contrato comercial? Elegir uno con stock o agenda comprobable y un operador disponible.
3. ¿Quién firma y publica una cotización: TilcAI en nombre del negocio, su sistema o ambos? Definir cadena de confianza y caducidad antes del piloto.
4. ¿Qué rol y evidencia se exige para cambiar destino de cobro, precios y disponibilidad?
5. ¿Cuál es la política cuando se cobra pero el negocio no puede cumplir? Documentar cancelación, devolución, tiempos y soporte antes de cobrar en producción.
6. ¿La empresa recibe USDC o necesita liquidación local? Si quiere bolivianos, evaluar un proveedor de salida fiat separado de TilcAI; CCTP no resuelve esa conversión.
7. ¿Quién paga coste de modelo, mensajes, gas patrocinado y soporte? Medirlo por tenant desde el primer piloto.

## Referencias

- [Informe de producto TilcAI](../TILCAI_NUEVO_RUMBO_COMERCIO_AGENTICO_2026-09-29.md), §§ 2, 5, 10, 12 y 25.
- [Plan backend](../TILCAI_PLAN_ARQUITECTURA_BACKEND_INFRA_2026-10-02.md), §§ 12 y 15.
- [Fase SCA](../TILCAI_FASE_SCA_EMISION_DE_CUENTAS_2026-10-06.md), §§ 4 y 7–8.
- [Incorporación del usuario comprador](TILCAI_ADOPCION_USUARIOS_2026-10-08.md).
- [WhatsApp Business Platform: funciones](https://whatsappbusiness.com/products/business-platform-features/), [onboarding para empresas](https://www.postman.com/meta/whatsapp-business-platform/overview) y [precios](https://whatsappbusiness.com/resources/faq/).
- [Stellar: patrón de rampa fiat SEP-24](https://developers.stellar.org/docs/platforms/anchor-platform/sep-guide/sep24/getting-started).
