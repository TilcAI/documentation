---
title: TilcAI — infraestructura integrada, flujo de compra y demostración
date: 2026-10-08
status: plan-de-integracion-y-guion-tecnico
tags:
  - tilcai
  - arquitectura
  - demo
  - x402
  - cctp
  - cuentas
---

# Infraestructura integrada y demostración de punta a punta

**Fecha de referencia:** 8 de octubre de 2026. **Objetivo de la demostración:** sábado 10 de octubre. Este documento reúne la visión completa sin confundirla con el software ya conectado. La meta del piloto es una operación limitada, verificable y reproducible en testnet; no una promesa de compras arbitrarias con cualquier activo o en cualquier red.

**Referencia de coordinación:** [contexto oficial](../0-OFICIAL/CONTEXTO_OFICIAL_TILCAI.md). Para dividir la implementación y comprobar dependencias, usar el [backlog de issues](../3-CONSTRUCCION/ISSUES_PROPUESTAS_2026-10-08.md): enlaza tareas existentes y las diez nuevas ya asignadas en GitHub.

## 1. Definición y escena que se debe enseñar

**TilcAI es la infraestructura que conecta la intención de un comprador con las capacidades comerciales de un negocio, aplica identidad, política y autorización, coordina una orden, ejecuta el pago por un riel soportado y entrega evidencia separada de pago y cumplimiento.** El comprador y el negocio pueden tener agentes, pero la autoridad sobre fondos y datos comerciales permanece fuera del modelo.

Para el pitch, mostrar **una sola historia**: una persona pide por WhatsApp «reserva un parqueo para las 16:00» o «compra 20 bolsas de cemento» → su asistente llama a TilcAI → el agente del negocio consulta una fuente de verdad y cotiza → TilcAI valida oferta y límites → la persona aprueba el importe y destinatario exactos → se paga en testnet → el negocio y la persona reciben el mismo estado de orden, recibo financiero y referencias verificables. La entrega, el retiro o la reserva confirmada se registra aparte. El negocio puede operar con agente propio; el primer adaptador también debe permitir un operador humano cuando no haya integración real.

Una persona con asistente propio entra por MCP (Model Context Protocol); una aplicación usa API REST y un SDK futuro. WhatsApp es un canal externo, no una firma. El negocio entra por agente propio, API/POS o una consola ligera. Todas las entradas usan los mismos contratos de comercio y pagos.

## 2. Límites de la infraestructura

| Dentro de TilcAI | Fuera de TilcAI, aunque se integra |
| --- | --- |
| API y herramientas MCP, identidad de usuario y tenant, catálogo normalizado, cotizaciones verificadas, orden, política, aprobación, idempotencia, ruteo de pagos, conciliación, recibos y auditoría | WhatsApp, modelos de IA y clientes de agentes, POS/inventario del negocio, proveedor de rampa fiat, Circle/Iris, Stellar/EVM, exploradores |
| Registro de cuentas emitidas, delegaciones y cuotas cuando la fase SCA esté operativa | Credencial privada del dueño de la cuenta, fondos del usuario, precios originales del negocio |
| Adaptador empresarial y eventos de cumplimiento | Entrega física, calidad del servicio y resolución comercial fuera de lo automatizado |

El relayer es un ejecutor de transacciones con políticas, firmantes y comisiones configurados. El plugin x402 dentro del relayer verifica y liquida payloads x402. CCTP de Circle es otro riel: quema USDC nativo en origen, espera atestación de Circle y mintea USDC nativo en destino. TilcAI decide cuándo cada riel sirve para una orden y concilia su resultado; **x402 y CCTP no son el mismo protocolo y aún no forman un único checkout comercial integrado**.

## 3. Mapa de componentes

~~~mermaid
flowchart LR
  subgraph Canales["Externos: canales y clientes"]
    WA["WhatsApp"]
    MCPCLIENT["Asistente propio con MCP"]
    APP["Aplicación con API"]
  end
  subgraph TilcAI["TilcAI: infraestructura común"]
    CH["Adaptador de canal"]
    MCP["Servidor MCP previsto"]
    API["Gateway REST y tenant"]
    ID["Identidad + cuentas + delegaciones"]
    BIZ["Directorio + adaptador comercial"]
    ORD["Cotización + orden + estados"]
    POL["Política + presupuesto + aprobación"]
    PAY["Router de pago"]
    REC["Conciliador + recibos + eventos"]
  end
  subgraph Negocio["Negocio: fuente de verdad"]
    AG["Agente vendedor"]
    POS["Catálogo / POS / agenda"]
    OPS["Operador y entrega"]
  end
  subgraph Redes["Externos: ejecución"]
    X402["Plugin x402 + Relayer"]
    BURN["Relayer + router en Fuji"]
    CCTP["Circle CCTP + Iris"]
    MINT["Relayer: mint en destino"]
    ST["Stellar USDC destino"]
  end
  WA --> CH --> API
  MCPCLIENT --> MCP --> API
  APP --> API
  API --> ID
  API --> BIZ --> AG --> POS
  AG --> OPS
  BIZ --> ORD --> POL --> PAY
  PAY --> X402 --> ST
  PAY --> BURN --> CCTP --> MINT --> ST
  X402 --> REC
  CCTP --> REC
  MINT --> REC
  REC --> API
  API --> WA
  API --> MCPCLIENT
  API --> AG
~~~

La flecha de pago directo Stellar y la ruta CCTP representan **alternativas**, no dos cobros de una misma orden. La API debe asociar orderId, quoteId, paymentAttemptId, hash de origen, hash de destino y estado de cumplimiento. Antes de repetir una operación incierta, concilia el intento anterior.

## 4. Secuencia operativa que debe funcionar

| Paso | Actor y acción | Dato/evidencia mínima | Estado |
| --- | --- | --- | --- |
| 01 | Persona solicita servicio por chat o asistente | Mensaje y principal autenticado | Solicitud |
| 02 | TilcAI normaliza intención y busca negocios habilitados | Producto, cantidad, fecha, ubicación; capacidades publicadas | Consulta |
| 03 | Agente del negocio consulta POS/catálogo o solicita confirmación al operador | Precio y disponibilidad con fuente y timestamp | Oferta pendiente o válida |
| 04 | Negocio devuelve cotización con vigencia, total, condiciones y cuenta de cobro verificada | quoteId, businessId, payTo, versión | Cotizada |
| 05 | TilcAI verifica identidad, oferta, presupuesto y reglas | Decisión ALLOW/DENY/REQUIRE_APPROVAL; ALLOW no es pago | Evaluada |
| 06 | Usuario aprueba la acción exacta en pantalla segura; se registra una orden idempotente | Aprobación vinculada a monto, activo, red, destino, oferta y expiración | Aprobada |
| 07 | Router elige **una** fuente de fondos: Stellar USDC directo o USDC de una red origen habilitada mediante CCTP | paymentAttemptId y ruta | Preparada |
| 08A | Pago Stellar directo: recurso o servicio exige pago x402, payload firmado pasa verify/settle del facilitador | Transferencia y hash Stellar; requiere probar USDC en el entorno real | Enviado → liquidado |
| 08B | Pago crosschain: pagador firma autorización exacta; relayer envía burn; Circle/Iris atesta; relayer mintea y reenvía en Stellar | Hash origen + atestación + hash destino | Burn → atestación → mint → liquidado |
| 09 | Conciliador verifica red, activo, monto, destinatario, nonce y estado on-chain | Recibo financiero; no inferir entrega | Pagado |
| 10 | Negocio confirma reserva, despacho o retiro usando su sistema/operador | Referencia de cumplimiento separada | Confirmado o pendiente |
| 11 | Ambos reciben resultado coherente y enlaces de prueba | orderId + recibo de pago + recibo comercial | Cerrado o en seguimiento |

Si la reserva o entrega falla después de pagar, el resultado es una excepción comercial visible, no una conversión automática de «pagado» a «entregado». El flujo de cancelación/devolución necesita sus propias reglas y todavía está pendiente.

~~~mermaid
sequenceDiagram
  actor U as Persona
  participant C as WhatsApp o cliente MCP
  participant T as TilcAI
  participant B as Agente del negocio
  participant S as Sistema/operador del negocio
  participant P as Relayer y riel de pago
  participant R as Stellar / Circle
  U->>C: Solicita producto o reserva
  C->>T: Intención estructurada
  T->>B: Consulta capacidad y disponibilidad
  B->>S: Lee precio/cupo o pide confirmación
  S-->>B: Respuesta comercial
  B-->>T: Cotización con vigencia y destino verificado
  T-->>C: Opciones + total
  C-->>U: Presenta cotización
  U->>T: Aprueba condiciones exactas en pantalla segura
  T->>P: Orden + intento de pago idempotente
  alt USDC Stellar
    P->>R: x402 verify / settle
  else USDC de red origen soportada
    P->>R: CCTP burn → Iris → mint en Stellar
  end
  R-->>T: Evidencia de liquidación
  T->>B: Orden pagada y referencia
  B->>S: Confirma reserva o entrega
  S-->>T: Evidencia de cumplimiento
  T-->>C: Estado + recibos + enlaces
  T-->>B: Estado + recibos + enlaces
  C-->>U: Confirmación y seguimiento
~~~

## 5. Cobertura de redes: laboratorio frente a producto

El laboratorio tilcai-cctp-engine modela **ocho redes testnet**: Ethereum Sepolia, Avalanche Fuji, Arbitrum Sepolia, Base Sepolia, Arc Testnet, Solana Devnet, Sui Testnet y Stellar Testnet. Tiene verificación de contratos, matriz de rutas y código de transferencia; su propio informe del 2 de octubre indica que la ejecución de todas las transferencias entre pares aún dependía de fondos y claves. El backend tilcai-infrastructure acredita **un** corredor completo: USDC Avalanche Fuji → Stellar Testnet, con modo gasless verificado. La cantidad de redes soportadas por Circle es mayor y cambia; no equivale a rutas habilitadas y ensayadas por TilcAI.

~~~mermaid
flowchart LR
  ETH["Ethereum Sepolia · laboratorio"] -.-> T["TilcAI + CCTP"]
  AVAX["Avalanche Fuji · verificado"] --> T
  ARB["Arbitrum Sepolia · laboratorio"] -.-> T
  BASE["Base Sepolia · laboratorio"] -.-> T
  ARC["Arc Testnet · laboratorio"] -.-> T
  SOL["Solana Devnet · laboratorio"] -.-> T
  SUI["Sui Testnet · laboratorio"] -.-> T
  T --> ST["Stellar Testnet · USDC del negocio"]
  SST["USDC Stellar del comprador"] -.-> X["x402 Stellar · probar con USDC"] -.-> ST
~~~

Línea continua = corredor CCTP verificado dentro del backend de TilcAI. Línea punteada = alcance del laboratorio o integración directa pendiente de prueba comercial. La ruta Stellar directa no hace burn/mint CCTP.

Para la web, dibujar las ocho redes alrededor de TilcAI y Stellar con una leyenda visible:

| Estado visual | Qué se puede decir |
| --- | --- |
| **Verificado en TilcAI** | Fuji → Stellar Testnet: pago USDC gasless, burn/mint y recibo técnico |
| **Preparado en laboratorio** | Otras siete redes de la matriz: contratos/rutas comprobados o simulados; falta transferencia y conciliación E2E por ruta |
| **Visión** | Más redes oficiales compatibles con Circle, tras incorporación y QA propios |

No decir «paga con cualquier dinero» ni «en cualquier blockchain». CCTP mueve **USDC nativo** entre redes habilitadas; otros tokens requieren una conversión previa distinta y un proveedor aparte. Tampoco equivale a fondear bolivianos. Si el usuario ya tiene USDC Stellar, no necesita CCTP: usa el riel directo cuando esté verificado para ese activo y cuenta.

## 6. Creación de cuenta desde un chat: diseño ejecutable

WhatsApp solo inicia el proceso y muestra estados. Una **pantalla web segura** vinculada a una sesión corta es la frontera para identidad, credenciales y firmas. El teléfono o identificador de chat no es una llave de la cuenta.

1. El canal recibe «crear cuenta» y genera una sesión con identificador de usuario, expiración, nonce y propósito. Se responde con un enlace de un solo uso. No se envían semillas ni claves por el chat.
2. El navegador abre un origen HTTPS de TilcAI y crea una credencial de propietario: preferentemente WebAuthn/passkey si el contrato y verificador están listos; alternativa ed25519 de usuario o conexión de wallet existente. Se valida challenge, origen, RP ID, credencial y clave pública.
3. El backend asocia al principal autenticado la **clave pública** y solicita POST /v1/accounts con tenant, red, externalRef e Idempotency-Key. Las credenciales técnicas del tenant se quedan en servidor.
4. El proveedor de cuentas calcula dirección y despliega smart account Stellar o EVM mediante el relayer; registra DEPLOYING y solo marca ACTIVE al comprobar despliegue on-chain. El relayer paga comisión; no se convierte en dueño.
5. El usuario ve dirección, red, activo, política de recuperación y cómo fondear. Crear cuenta no acredita fondos. No se genera una cuenta nueva por conversación.
6. Para comprar, se prepara una aprobación exacta del dueño. La delegación posterior es opcional, limitada y revocable; no se concede por pulsar «conectar agente».

**Piezas técnicas actuales o previstas:** backend Fastify + Zod + SQLite/worker y tipos tilcai-core; Stellar SDK 17.x y contratos Soroban basados en OpenZeppelin stellar-accounts 0.7.2; para EVM, viem y cuentas OpenZeppelin/ERC-4337; navegador con WebAuthn/passkeys; relayer para patrocinar despliegue/envío. Los puertos de cuentas/tenants y contratos base están en el PR de preparación SCA; factory, API de cuentas, recuperación probada y despliegues aún son trabajo pendiente. Elegir y fijar la biblioteca de servidor WebAuthn solo después de probar el formato de firma que espera el verificador on-chain.

**Fondeo:** wallet existente → USDC de la red habilitada → CCTP si es origen externo; o un proveedor de rampa fiat → USDC Stellar si se contrata un corredor real. TilcAI no debe acreditar saldo por un QR o un webhook no autenticado. No usar fondos de producción para probar este diseño.

## 7. Módulos y estado verificable

| Módulo | Función | Estado al 8/10 |
| --- | --- | --- |
| Contratos compartidos (IDs, estados, errores, intención y mandato) | Lenguaje común entre canales, API y pagos | Tipos y tests en tilcai-core; revisar/integrar |
| Canal WhatsApp | Entrada y salida de mensajes | Demostración externa del equipo; integración propia y prueba reproducible pendientes |
| Canal MCP | Herramientas del agente comprador | Contrato de 12 herramientas; servidor en ejecución pendiente |
| API crosschain v1 + worker | Cotizar, pagar y conciliar Fuji → Stellar | Implementado y verificado en testnet |
| Relayer OZ y plugin x402 | Enviar transacciones; verify/settle/supported | Riel x402 Stellar probado de forma aislada con XLM; relayer usado en el corredor CCTP |
| Laboratorio CCTP de ocho redes | Matriz, verificaciones y código por red | Código y verificación on-chain; transferencias E2E de todas las rutas no acreditadas |
| Tenant y cuotas | Aislar integradores y limitar uso | Puertos en PR SCA; persistencia/API pendientes |
| Cuenta SCA y delegación | Emitir cuenta y limitar al agente | Contratos base en PR SCA; M0–M5 y API pendientes |
| Negocio, catálogo y adaptador | Fuente de precio, disponibilidad y cotización | Puertos/diseño; primer adaptador operativo pendiente |
| Política y aprobación | Autoridad exacta o mandato limitado | Prototipo de política/tipos; enlace a firma real pendiente |
| Orden y cumplimiento | Relación cotización-pago-entrega | Diseño/puertos; implementación pendiente |
| Router unificado | Elegir Stellar directo o CCTP para una orden | Pendiente |
| Recibo de operación | Enlazar hashes con orden y evidencia comercial | Recibo técnico de pago existente; recibo de compra completo pendiente |
| Portal de negocio | Catálogo, solicitudes y confirmación | Propuesta de producto; no implementado |
| Rampa BOB ↔ USDC | Fondeo/cobro local | Socio y corredor aún por definir |

Dos PR abiertos en tilcai-infrastructure preparan el despliegue en contenedores y la fase SCA; **no están en main ni en el clon local base**. No contar esa preparación como API de cuentas terminada.

## 8. Ruta crítica para una demostración honesta el sábado

**Debe correr junto:** un cliente de prueba por chat o MCP → una oferta de negocio respaldada por datos → aprobación exacta → un riel de pago testnet → conciliación → mensajes a ambas partes con orderId y hashes. El agente del negocio puede ser un servicio con reglas y un operador de respaldo; el demo no depende de entrenar ni pagar un modelo distinto por negocio.

| Prioridad | Resultado comprobable |
| --- | --- |
| P0 | Reproducir con otro integrante el pago Fuji → Stellar y registrar entorno, hashes y resultado; ejecutar tests y typecheck |
| P0 | Adaptador de un negocio y una oferta con precio/stock/cupo realista y versión, aunque sea un catálogo controlado de piloto |
| P0 | Orden idempotente, aprobación exacta y vínculo orderId ↔ paymentAttemptId ↔ hashes |
| P0 | Dos vistas o mensajes consistentes: comprador y negocio ven pagado; entrega/reserva no se confunde con pago |
| P1 | Probar x402 en Stellar **con USDC**, no inferirlo de la prueba aislada con XLM |
| P1 | Conectar el canal de WhatsApp existente; si no hay acceso, usar una interfaz de prueba externa sin cambiar el backend |
| P1 | Cuenta SCA de prueba creada desde enlace seguro solo si M0/M1/M2 pasan; si no, conectar una cuenta testnet ya financiada y rotular la emisión como trabajo en curso |
| P2 | Añadir rutas Base/Arbitrum/Ethereum desde el laboratorio al backend, una por una, cada una con test E2E |
| P2 | Rampa boliviana, autonomía delegada y portal general para PYMES: después del corredor y del piloto |

No se eliminan módulos del plan; se distingue **lo que puede demostrarse ahora** de lo que seguirá construyéndose. La definición de «funcionando» para el sábado es una operación acotada que cualquier integrante pueda repetir siguiendo un runbook, sin depender de una sesión privada de un solo desarrollador.

## 9. Secuencia recomendada de la página y del pitch

1. **Qué es TilcAI:** una frase y una solicitud concreta del comprador.
2. **Problema de ambos lados:** el asistente no puede comprar con seguridad; el negocio no expone precio, cupo y cobro de forma verificable.
3. **Solución:** comprador ↔ TilcAI ↔ agente del negocio, con control humano.
4. **Operación al hacer scroll:** el pedido asciende por intención, oferta, política, aprobación, pago y dos recibos. Cada tarjeta revela una responsabilidad y un estado, no un supuesto movimiento de fondos.
5. **Rieles de pago:** nodo «USDC de origen» → TilcAI/CCTP → Stellar USDC; etiqueta fuerte en Fuji → Stellar y etiquetas de laboratorio en las otras redes. Ruta Stellar directa separada.
6. **Prueba en vivo:** chat, cotización, aprobación, estado de la orden y enlaces a hashes de testnet. Mostrar también quién confirmó la reserva o entrega.
7. **Estado real y siguiente integración:** verificado, en construcción y futuro, con responsables.
8. **Impacto medible:** número de negocios y usuarios **reales** del piloto, tasa de solicitudes completadas, tiempo de cotización y pagos conciliados. No inventar alcance o volumen.

La web actual tiene escenas y simulaciones útiles. Para el sábado, la sección nueva debe mostrar **evidencia en vivo** vinculada a una orden cuando el backend exista; si se usa una animación o fixtures, rotularla «simulación». No mezclar un hash real con una entrega ficticia sin explicarlo.

## 10. Pruebas para entender las piezas por separado

1. **x402/Relayer aislado:** ejecutar la guía reproducible de tilcai-core. Confirma supported, seis rechazos de verify, settle, hash y replay. La evidencia del 30/9 usa XLM nativo en Stellar Testnet; repetir con USDC exige permitir su SAC y fondear al pagador.
2. **CCTP de laboratorio:** ejecutar verify y matrix sin claves; transfer solo con wallets testnet y saldo. La matriz describe rutas posibles, no pagos comerciales de TilcAI.
3. **API crosschain de TilcAI:** instalar dependencias con tilcai-core al lado, test/typecheck, arrancar API+worker, comprobar relayer y ejecutar xpay a una cuenta Stellar con USDC. Verificar hash Fuji, atestación, hash Stellar y saldo del receptor.
4. **Flujo comercial integrado:** crear una orden de prueba y demostrar que cotización, firma, pago y cumplimiento comparten identificadores y que reintentos no duplican el pago.

En Windows/PowerShell, el clon local de tilcai-infrastructure en main todavía no contiene deploy/. Se puede reproducir **sin fondos** la base antes de levantar el relayer:

~~~powershell
cd "C:\Users\OMAR\Documents\OMAR\2026 ACTIVIDADES\23. STELLAR-ELITE\1_PROYECTO\IDEA-PROJECT\TilcAI\tilcai-infrastructure"
npm.cmd install
npm.cmd test
npm.cmd run typecheck
~~~

Para pago **testnet**: arrancar primero el relayer y completar una copia local de .env.example con RELAYER_URL, RELAYER_API_KEY y, para el modo de prueba gasless, DEV_EVM_PAYER_PRIVATE_KEY y CCTP_ROUTER_FUJI. El pagador necesita USDC de Fuji; el firmante del relayer necesita AVAX y XLM de testnet; el destinatario Stellar G… necesita cuenta y trustline USDC. No copiar secretos al repositorio ni a un issue.

~~~powershell
Copy-Item .env.example .env
# Editar .env localmente; nunca mostrarlo ni versionarlo.
npm.cmd run relayer:check
npm.cmd start
# En otra terminal, ya con el relayer operativo:
npm.cmd run xpay -- --amount 0.1 --to G_DIRECCION_STELLAR_CON_USDC --gasless
~~~

El Docker Compose del relayer + TilcAI está en el PR de contenedores, no en main. Para probarlo sin alterar main, crear un worktree del PR después de arrancar Docker Desktop:

~~~powershell
git fetch origin deploy/containers
git worktree add --detach ../tilcai-infrastructure-deploy FETCH_HEAD
cd ../tilcai-infrastructure-deploy
Copy-Item deploy/.env.example deploy/.env
# Completar API keys, keystore de testnet y passphrase en deploy/.env.
# En Git Bash o WSL, desde este worktree: bash ./deploy/build.sh
docker compose -f deploy/docker-compose.yml --env-file deploy/.env up -d
Invoke-RestMethod http://127.0.0.1:8787/health
~~~

La primera construcción del relayer compila Rust dentro de Docker y puede tardar. Una instalación nueva necesita generar y fondear su propio keystore de testnet; sin ese firmante el servicio no enviará transacciones. El ejemplo Docker del PR permite x402 con XLM nativo en Stellar, pero **no incluye todavía el SAC de USDC** en la lista permitida. Para probar x402 con USDC hay que habilitar el activo, fondear pagador y repetir verify/settle; no inferirlo de la salud del contenedor. El script reproducible de tilcai-core está en main remoto; un clon antiguo puede necesitar actualizarse antes de que exista scripts/payment-rail.

Los comandos concretos están en [tilcai-infrastructure/README](https://github.com/TilcAI/tilcai-infrastructure/blob/main/README.md), [prueba x402 aislada](https://github.com/TilcAI/tilcai-core/blob/main/docs/payment-rail-reproducibility.md) y [laboratorio CCTP](https://github.com/TilcAI/tilcai-cctp-engine/blob/main/README.md). El despliegue Docker conjunto está en el [PR de contenedores](https://github.com/TilcAI/tilcai-infrastructure/pull/1), aún abierto.

## Referencias de proyecto y protocolos

- [Incorporación del usuario](TILCAI_ADOPCION_USUARIOS_2026-10-08.md) y [del negocio](TILCAI_ADOPCION_EMPRESAS_PYMES_2026-10-08.md).
- [Plan backend](../TILCAI_PLAN_ARQUITECTURA_BACKEND_INFRA_2026-10-02.md), [fase SCA](../TILCAI_FASE_SCA_EMISION_DE_CUENTAS_2026-10-06.md) e [informe de producto](../TILCAI_NUEVO_RUMBO_COMERCIO_AGENTICO_2026-09-29.md).
- [OpenZeppelin Relayer](https://docs.openzeppelin.com/relayer/quickstart), [smart accounts Stellar](https://docs.openzeppelin.com/stellar-contracts/accounts/smart-account), [Circle: redes/domains CCTP](https://developers.circle.com/cctp/concepts/supported-chains-and-domains) y [MCP Tools](https://modelcontextprotocol.io/specification/latest/server/tools).
