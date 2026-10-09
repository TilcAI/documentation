# Monitorización de TilcAI: del backend al tablero

**Fecha:** 9 de octubre de 2026. **Repositorios:** `tilcai-infrastructure` (backend) y `tilcai-web` (frontend).
**Estado:** el recorrido completo está implementado y verificado en local contra servicios reales de testnet; el tablero con su diseño final es trabajo pendiente ([tilcai-web#25](https://github.com/TilcAI/tilcai-web/issues/25)).

Este documento explica qué pasa desde que algo ocurre en el backend hasta que una persona lo ve en el navegador: qué se registra, cómo viaja, cómo lo guarda el sitio, cómo se interpreta y qué falta. Sirve para construir el tablero sin leer primero el código de los dos lados.

## 1. En una página

```
            tilcai-infrastructure                                        tilcai-web
┌──────────────────────────────────────────────┐          ┌─────────────────────────────────────────┐
│ pagos crosschain ─┐                          │          │  POST /api/monitor/events               │
│ vault ────────────┤                          │  HTTPS   │   1. firma HMAC y antigüedad            │
│ API (5xx) ────────┤   monitor_events         │  POST    │   2. forma del lote                     │
│ avisos del relayer├─▶ (SQLite, `seq` crece) ─┼─────────▶│   3. MonitorStore (memoria)             │
│ mock QR Simple ───┤        │                 │ firmado  │        │                                │
│ foto de recursos ─┘        │                 │          │        ├─ GET /api/monitor/summary      │
│                            │                 │          │        ├─ GET /api/monitor/events       │
│  GET /v1/monitor/events ◀──┤                 │          │        └─ GET /api/monitor/stream (SSE) │
│  GET /v1/monitor/stream ◀──┤                 │          │                    │                    │
│  GET /v1/monitor/resources ┘                 │          │   /[lang]/monitor ◀┘ useMonitorFeed()   │
└──────────────────────────────────────────────┘          └─────────────────────────────────────────┘
        la fuente de verdad: guarda todo                          una copia reciente para mostrar
```

Cuatro ideas sostienen el diseño:

1. **El backend es la fuente de verdad.** Anota cada evento en su base, con una posición (`seq`) que solo crece. El sitio guarda una copia reciente y nada más.
2. **El backend empuja; el sitio no lo busca.** El sitio vive en internet y el backend puede vivir detrás de una red privada: quien puede iniciar la conexión es el backend.
3. **Al menos una vez y en orden.** El backend solo avanza su cursor cuando el sitio responde `2xx`. Si el sitio estuvo caído, recibe después todo lo que se perdió. El sitio descarta lo repetido por el `id` del evento.
4. **Monitorizar no puede romper lo monitorizado.** Emitir un evento nunca lanza un error ni espera a la red. El envío al sitio corre en un bucle distinto del que concilia pagos.

## 2. Estado: qué está hecho y qué no

| Pieza | Estado | Evidencia |
| --- | --- | --- |
| Registro de eventos, foto de recursos y alertas en el backend | **Implementado y probado** | 86 tests unitarios en `tilcai-infrastructure` (17 del monitor, 10 de la API y 14 del mock de QR) |
| Eventos de pagos crosschain y desembolsos del vault | **Implementado y verificado con desembolsos reales en Fuji** | Prueba E2E del 9/10: seis desembolsos `CONFIRMED` con sus eventos |
| Eventos del mock de QR Simple | **Implementado y verificado** | Misma prueba E2E: `qr.created` → `qr.paid` → `qr.callback_delivered` |
| Receptor de avisos del OpenZeppelin Relayer | **Implementado; probado con avisos firmados de prueba** | El relayer real sigue enviando sus avisos a otra URL: falta apuntarlo a TilcAI (§ 4.3) |
| Envío firmado a `tilcai-web`, con reintento y recuperación | **Implementado y verificado** | Entregas reales entre las dos instancias locales; recuperación comprobada reiniciando el sitio |
| Ingesta, almacén, lectura y flujo en vivo en `tilcai-web` | **Implementado y verificado en navegador** | 11 tests; captura de `/es/monitor` con los eventos de la prueba E2E |
| Interpretación de eventos y alertas (ES/EN) | **Implementado** | `src/lib/monitor/interpret.ts`; un test comprueba que cubre todos los tipos y códigos del backend |
| Vista `/[lang]/monitor` | **Base funcional, sin diseño final** | Tarjetas, alertas y lista de eventos. Sin gráficos ni histórico |
| Tablero con su diseño | **Pendiente** | [tilcai-web#25](https://github.com/TilcAI/tilcai-web/issues/25) |
| Almacén duradero en el sitio | **Pendiente** | Hoy es memoria: no sirve con más de una instancia (§ 5.2) |
| Despliegue en contenedores con estos cambios | **Sin probar** | No se reconstruyó ninguna imagen; el contenedor en uso sigue con la versión anterior |

## 3. El contrato: `tilcai-monitor-v1`

Es lo único que los dos repositorios comparten. Lo define el backend ([`src/modules/monitor/domain.ts`](https://github.com/TilcAI/tilcai-infrastructure/blob/main/src/modules/monitor/domain.ts)) y el sitio lo copia ([`src/lib/monitor/contract.ts`](https://github.com/TilcAI/tilcai-web/blob/main/src/lib/monitor/contract.ts)). Un tipo o un campo nuevo se añade en los dos lados; un test del sitio compara las dos listas cuando los repositorios están uno al lado del otro.

### 3.1 Un evento

```json
{
  "seq": 47,
  "id": "evt_6a65e062-48e7-4899-be1d-f875b8078ea0",
  "type": "vault.disbursement.transition",
  "source": "tilcai",
  "severity": "info",
  "subject": "vault_disbursement_04d42c60-f53f-4534-b430-bc26e6dd8c99",
  "summary": "Desembolso de 1 USDC SUBMITTED → CONFIRMED: Disbursed event verified",
  "data": { "disbursementId": "vault_disbursement_04d4…", "from": "SUBMITTED", "to": "CONFIRMED", "amount": "1", "txHash": "0xb175…", "explorer": "https://testnet.snowtrace.io/tx/0xb175…" },
  "at": "2026-10-09T08:07:58.412Z"
}
```

| Campo | Qué es |
| --- | --- |
| `seq` | Posición en el registro del backend. Crece siempre; puede saltarse números. Es el cursor de quien lee del backend |
| `id` | Identificador único (`evt_<uuid>`). Con él el sitio reconoce un evento repetido |
| `type` | Qué pasó. Lo que va antes del primer punto es su **categoría** (`vault`, `qr`, `relayer`…) |
| `source` | De quién habla: `tilcai`, `relayer` o `qr-simple` |
| `severity` | `info`, `warning` o `error` |
| `subject` | La entidad afectada: un pago, un desembolso, una transacción del relayer, un QR, un código de alerta |
| `summary` | Una línea legible sin abrir `data`. La escribe el backend, en español |
| `data` | Los hechos, distintos por tipo (§ 3.3). Nunca lleva secretos (§ 8) y no pasa de 16 kB |
| `at` | Cuándo ocurrió, en UTC (ISO 8601) |

### 3.2 Un envío

```http
POST /api/monitor/events
Content-Type: application/json
X-Tilcai-Timestamp: 1791533278
X-Tilcai-Signature: v1=8cac9852ba6db796cf12fee8f3df5e29e3d143e840968d14a667bb844d06f8f7
X-Tilcai-Delivery: d9973894-0279-4f15-91e8-5d680771297a

{
  "schema": "tilcai-monitor-v1",
  "deliveryId": "d9973894-0279-4f15-91e8-5d680771297a",
  "sentAt": "2026-10-09T08:07:58.500Z",
  "origin": { "env": "testnet", "instance": "bms-server" },
  "head": 47,
  "events": [ { "seq": 46, … }, { "seq": 47, … } ]
}
```

- `origin.instance` distingue un backend de otro: varios pueden reportar al mismo sitio.
- `head` es la última posición del registro al salir el envío. Con ella el sitio sabe cuánto le falta (`head − último seq recibido`).
- Hasta 100 eventos por envío; el sitio acepta hasta 500 y 1 MB.
- **La firma** es `v1=` + HMAC-SHA256, en hexadecimal, de `"<X-Tilcai-Timestamp>.<cuerpo exacto>"` con el secreto compartido. El sitio rechaza un envío sin firma, con otra firma o con más de cinco minutos de diferencia respecto a su reloj.

Respuestas del sitio:

| Código | Cuerpo | Qué hace el backend |
| --- | --- | --- |
| `200` | `{ "ok": true, "accepted": 2, "duplicates": 0, "cursor": 52 }` | Avanza su cursor |
| `400` | `{ "error": "invalid", "reason": "events[0].type" }` | Reintenta más tarde (y deja el motivo en su `lastError`) |
| `401` | `{ "error": "unauthorized", "reason": "missing" \| "stale" \| "mismatch" }` | Reintenta: revisar el secreto o el reloj |
| `413` | `{ "error": "too_large" }` | Reintenta |
| `503` | `{ "error": "not_configured" }` | Reintenta: falta `MONITOR_INGEST_SECRET` en el sitio |

### 3.3 Los tipos de evento

| Tipo | Cuándo se emite | Lo más útil de `data` |
| --- | --- | --- |
| `system.started` | Arranca un proceso | `role` (`all`, `api`, `worker`), `vault`, `qrMock`, `monitorPush` |
| `system.stopping` | Un proceso recibe una señal y se cierra | `signal` |
| `resources.snapshot` | Cada `MONITOR_RESOURCES_INTERVAL_MS` (30 s) | La foto completa (§ 4.4). Siempre `info` |
| `alert.raised` | Una condición empieza a estar mal | `code` (también en `subject`) |
| `alert.cleared` | Esa condición deja de cumplirse | `code`, `since` |
| `api.request_rejected` | La API responde `5xx` | `route`, `status`, `code`, `repeatedSinceLast` (agrupado por minuto) |
| `crosschain.payment.transition` | Un pago CCTP se crea (`from: null`) o cambia de estado | `paymentId`, `from`, `to`, `paymentState`, `burnTxHash`, `mintTxHash`, `failureCode` |
| `crosschain.payment.uncertain` | Un pago queda sin poder probar qué pasó en la cadena | `paymentId`, `state`, `error` |
| `vault.disbursement.transition` | Un desembolso se crea o cambia de estado | `disbursementId`, `from`, `to`, `recipient`, `amount`, `reference`, `txHash`, `explorer` |
| `vault.disbursement.uncertain` | Una llamada al relayer termina sin respuesta | `disbursementId`, `state`, `error` |
| `vault.disbursement.rejected` | El vault no puede aceptar un desembolso | `code` (`BUDGET`, `PAUSED`, `PAYMENT_LIMIT`, `SERVICE_UNAVAILABLE`), `amount`, `balance`, `pending`, `reference` |
| `relayer.transaction_update` | Aviso del relayer: una transacción cambió de estado | `relayerId`, `transactionId`, `status`, `hash`, `related` |
| `relayer.state_update` | Aviso del relayer: se deshabilitó o volvió | `relayerId`, `enabled`, `reason` |
| `relayer.notification` | Cualquier otro aviso del relayer | `event`, `payloadType`, `payload` |
| `qr.token_issued` | Alguien inicia sesión en el mock de QR | `tokenId`, `name`, `expiresAt` |
| `qr.created` | El mock emite un QR | `qrId`, `amount`, `description`, `expiresAt` |
| `qr.paid` | Alguien pulsa «Simular depósito» | `qrId`, `amount`, `payerName`, `payerBank` |
| `qr.expired` | Un QR vence sin pago | `qrId`, `amount` |
| `qr.callback_delivered` | Quien cobra confirma el aviso de pago | `qrId`, `attempts`, `url` |
| `qr.callback_failed` | El aviso de pago no fue confirmado | `qrId`, `attempts`, `final`, `error` |

## 4. El backend, por dentro

### 4.1 Dónde nacen los eventos

Los servicios no conocen el tablero: reciben un `EventSink` (una sola función, `emit`) y lo llaman en los mismos puntos donde ya escribían su log.

| Fuente | Dónde se emite | Archivo |
| --- | --- | --- |
| Pagos crosschain | En cada transición de estado (`move`), al crear el pago y la primera vez que queda incierto | `src/modules/crosschain/service.ts` |
| Vault | En cada transición, al crear el desembolso, cuando queda incierto y cuando el vault lo rechaza | `src/modules/vault/service.ts` |
| API | En el manejador de errores, solo para `5xx`, una vez por minuto por ruta y código | `src/apps/api/server.ts` |
| Avisos del relayer | Al recibir un webhook válido | `src/apps/api/monitor-routes.ts` |
| Mock de QR Simple | Login, QR generado, depósito, vencimiento, cada intento de aviso | `src/modules/qrsimple/service.ts` |
| Recursos y alertas | En el bucle de mantenimiento | `src/apps/worker/loop.ts`, `src/modules/monitor/resources.ts` |
| Ciclo de vida | Al arrancar y al detenerse | `src/apps/lifecycle.ts` |

`MonitorService.emit` hace cuatro cosas, y ninguna puede fallar hacia quien llama:

1. Limpia `data`: convierte los `bigint` a texto, sustituye por `[redacted]` los valores cuya clave termina en `secret`, `password`, `private`, `authorization`, `apiKey`, `token` o `signature`, y recorta los textos largos.
2. Inserta la fila en `monitor_events`. Si el evento trae una clave de deduplicación ya vista, no se guarda otra vez.
3. Avisa a quien escucha dentro del mismo proceso (el flujo en vivo y el bucle de envío), para que no esperen al siguiente ciclo.
4. Si algo de lo anterior falla, lo deja en el log y sigue.

### 4.2 Las tablas (migración 4)

| Tabla | Para qué |
| --- | --- |
| `monitor_events` | El registro. `seq` autoincremental, `id` único, `dedupe_key` único opcional. Se purga lo más antiguo que `MONITOR_RETENTION_DAYS` (14) |
| `monitor_sinks` | Un destino por fila (hoy solo `web`): hasta qué `seq` se envió, intentos fallidos seguidos, cuándo reintentar y el último error |
| `monitor_alerts` | Lo que está mal ahora mismo, con el momento en que empezó |

### 4.3 Avisos del OpenZeppelin Relayer

El relayer envía un `POST` a la notificación que tenga configurada cada vez que una transacción cambia de estado o un relayer se deshabilita:

```json
{
  "id": "5f1c1c9a-0000-4000-8000-000000000001",
  "event": "transaction_update",
  "payload": { "payload_type": "transaction", "id": "tx-abc", "hash": "0x9d3f…", "status": "confirmed", "relayer_id": "avalanche-fuji-relayer", "from": "0xcc0b…", "to": "0x841d…", "nonce": 42 },
  "timestamp": "2026-10-09T07:00:00+00:00"
}
```

Lo recibe `POST /v1/webhooks/relayer`. Esta ruta no usa la clave de la API: la autentica el propio relayer.

- **Con firma** (`RELAYER_WEBHOOK_SIGNING_KEY` definida): la cabecera `X-Signature` debe ser el HMAC-SHA256, en base64, del cuerpo exacto con la clave de firma de la notificación. Es el esquema del relayer 1.8.x (`src/services/notification/mod.rs`).
- **Sin firma** (variable vacía): solo se aceptan avisos que llegan desde el propio equipo.

Cada aviso se convierte en un evento con `dedupe_key = relayer:<id del aviso>`, así que un reintento del relayer no lo duplica. Si la transacción la envió TilcAI, `data.related` dice a qué pertenece:

```json
"related": { "kind": "vault_disbursement", "id": "vault_disbursement_04d4…" }
```

`kind` puede ser `vault_disbursement`, `crosschain_burn` o `crosschain_mint`. Se busca por el id de transacción que el relayer devolvió al enviarla.

**Los avisos sirven para ver, no para decidir.** Un pago o un desembolso solo se da por liquidado cuando TilcAI comprobó la cadena por su cuenta.

**Para activarlos** hay que apuntar el relayer a TilcAI. En el despliegue del repositorio (`deploy/relayer/config/config.json`) ya está escrito:

```json
"notifications": [
  { "id": "tilcai-monitor", "type": "webhook", "url": "http://tilcai:8787/v1/webhooks/relayer",
    "signing_key": { "type": "env", "value": "WEBHOOK_SIGNING_KEY" } }
]
```

y cada relayer lleva `"notification_id": "tilcai-monitor"`. El relayer que corre hoy en el servidor del equipo usa otra configuración (su notificación apunta a un sitio de pruebas externo): **no se cambió**, así que por ahora no llega ningún aviso real.

### 4.4 La foto de recursos y las alertas

Cada 30 segundos el backend toma una foto (`ResourceMonitor.snapshot`) y la emite como `resources.snapshot`:

| Bloque | Contenido |
| --- | --- |
| `process` | Rol, pid, versión de Node, tiempo en marcha, memoria (`rssBytes`, `heapUsedBytes`), `cpuLoad` (fracción de un núcleo desde la foto anterior) y retraso del event loop (`mean`, `p99`, `max`, en ms) |
| `host` | Nombre, núcleos, carga media, memoria total y libre |
| `database` | Ruta y tamaño del archivo, y filas por estado de cada cola: pagos crosschain, desembolsos, QR del mock, avisos pendientes, eventos |
| `relayer` | Si responde y, por relayer: red, dirección, pausa, si se deshabilitó, y saldo de gas (AVAX o XLM) |
| `vault` | Dirección, saldo, lo comprometido en desembolsos en curso, tope por desembolso, límite diario y lo disponible hoy, pausa, si el operador es el relayer |
| `monitor` | Última posición del registro y, por destino, cuánto le falta por recibir y su último error |
| `alerts` | Lo que está mal en esta foto |

Las lecturas externas (relayer, cadena) tienen 8 segundos de límite cada una; si una falla, la foto sale igual con el error en su bloque.

Las alertas se calculan de la foto:

| Código | Severidad | Condición | Qué hacer |
| --- | --- | --- | --- |
| `VAULT_EMPTY` | error | El vault tiene 0 USDC | Enviar USDC de Fuji **al contrato vault**, no a la cuenta del relayer |
| `VAULT_INSUFFICIENT` | error | Saldo menor que lo comprometido | Recargar |
| `VAULT_LOW` | warning | Saldo menor que el tope por desembolso | Recargar antes de un desembolso grande |
| `VAULT_PAUSED` | error | El contrato está en pausa | Solo el dueño lo reanuda |
| `VAULT_OPERATOR_MISMATCH` | error | El operador no es la cuenta del relayer | El dueño debe corregirlo o los desembolsos revierten |
| `VAULT_DAILY_LIMIT_REACHED` | warning | Disponible hoy = 0 | Sigue a las 00:00 UTC o el dueño sube el límite |
| `VAULT_UNREADABLE` | warning | No se pudo leer el contrato | Revisar el RPC |
| `RELAYER_DOWN` | error | El relayer no responde | Nada se envía hasta que vuelva |
| `RELAYER_UNAUTHENTICATED` | warning | Falta `RELAYER_API_KEY` | Definirla |
| `RELAYER_UNREADABLE:<id>` | warning | No se pudo leer un relayer | Revisar su id y sus logs |
| `RELAYER_PAUSED:<id>` | error | Relayer en pausa | Reanudarlo |
| `RELAYER_DISABLED:<id>` | error | El relayer se deshabilitó solo | Suele ser su RPC o su saldo |
| `RELAYER_LOW_GAS:<id>` | warning | Menos de 0,05 AVAX o 5 XLM | Fondear su cuenta |
| `MONITOR_SINK_FAILING:<destino>` | warning | 3 o más envíos fallidos seguidos | Revisar `MONITOR_WEB_URL` y el secreto |
| `PAYMENTS_UNCERTAIN` | warning | Hay pagos en estado incierto | Mirar los que lleven mucho tiempo |
| `EVENT_LOOP_SLOW` | warning | p99 del event loop sobre 500 ms | Revisar CPU |

Una alerta produce **un evento cuando aparece** (`alert.raised`) y **otro cuando se resuelve** (`alert.cleared`), no uno por cada foto. La tabla `monitor_alerts` recuerda cuáles están activas aunque el proceso se reinicie.

**Un vault por red (2026-10-09).** La foto de recursos lleva `vaults`: una entrada por red con vault (`eip155:43113`, `stellar:testnet`), el de Fuji primero; `vault` sigue siendo el de Fuji para un tablero anterior. Las alertas del vault de Fuji conservan su código; las de otra red llevan la red como destino, `VAULT_EMPTY:stellar:testnet`, y el tablero las muestra en la tarjeta de ese vault.

`VAULT_EMPTY` existe por un caso real: el 8 de octubre el vault estuvo vacío un día entero —la recarga había llegado a la cuenta del relayer, no al contrato— y nadie lo vio porque el único síntoma era un cliente reintentando cada cinco minutos.

### 4.5 El envío al sitio

`WebForwarder` corre en el bucle de mantenimiento, una vez por segundo y enseguida cuando el propio proceso emite algo:

```
leer monitor_sinks('web')  ──▶ ¿toca reintentar ya?  ── no ──▶ salir
          │ sí
          ▼
leer hasta 100 eventos con seq > last_seq  ──▶ ¿ninguno?  ──▶ salir
          │
          ▼
firmar y enviar  ──▶ 2xx ──▶ last_seq = seq del último, attempts = 0
          │
          └─▶ error ──▶ attempts + 1, esperar 2 s × 2^attempts (máximo 5 min), guardar el error
```

- Si hay atraso, envía hasta cinco lotes seguidos por ciclo.
- Tras tres fallos seguidos aparece la alerta `MONITOR_SINK_FAILING:web`.
- Para volver a enviar todo desde el principio (por ejemplo, tras reiniciar un sitio que guarda en memoria) basta con poner `last_seq = 0` en `monitor_sinks`: el sitio descarta lo que ya tenga.

### 4.6 Leer del backend directamente

Para scripts, pruebas o para un sitio que quiera rellenarse por su cuenta. Todas piden `Authorization: Bearer <TILCAI_API_KEYS>`.

| Ruta | Devuelve |
| --- | --- |
| `GET /v1/monitor/events?after=<seq>&limit=<1-500>&type=<tipo o prefijo.>&source=…&severity=…` | `{ schema, head, events }`. Sin `after`, los últimos `limit` |
| `GET /v1/monitor/stream?after=<seq>` | Server-Sent Events: `id: <seq>`, `event: monitor`, `data: <evento>`. Reanuda con `Last-Event-ID` |
| `GET /v1/monitor/resources` | `{ schema, resources, alerts }`: una foto tomada en el momento (compartida 5 s entre peticiones) |

### 4.7 Dos bucles que no se esperan

```
conciliación (cada WORKER_POLL_MS)      mantenimiento (cada 1 s, o al emitir un evento)
  pagos crosschain que tocan              avisos pendientes del mock de QR
  desembolsos del vault que tocan         vencimiento de QR
                                          envío de eventos al sitio
                                          foto de recursos (cada 30 s)
                                          purga de eventos antiguos (cada hora)
```

Un sitio lento o un callback que no responde nunca retrasan un pago. Los dos bucles viven en el proceso `worker` (o en `all`): un despliegue solo con `api` registra eventos pero no los envía.

## 5. El sitio, por dentro

### 5.1 Ingesta: `POST /api/monitor/events`

[`src/app/api/monitor/events/route.ts`](https://github.com/TilcAI/tilcai-web/blob/main/src/app/api/monitor/events/route.ts), en este orden:

1. Sin `MONITOR_INGEST_SECRET` → `503`. Un sitio sin configurar no acepta nada.
2. Lee el cuerpo como texto (hace falta el texto exacto para la firma) y rechaza más de 1 MB.
3. `verifyDelivery`: cabeceras presentes, antigüedad de cinco minutos como máximo, firma igual a la recalculada (comparación en tiempo constante).
4. `parseDelivery`: comprueba el lote campo por campo y se queda solo con los campos declarados. Un tipo de evento que el sitio aún no conoce se acepta si tiene forma de tipo: un backend más nuevo no rompe un sitio más viejo.
5. `MonitorStore.ingest`: guarda lo nuevo y responde cuántos aceptó y cuántos ya tenía.

### 5.2 El almacén: `MonitorStore`

[`src/lib/monitor/store.ts`](https://github.com/TilcAI/tilcai-web/blob/main/src/lib/monitor/store.ts). Vive en la memoria del proceso del servidor, una instancia compartida por todas las rutas.

- Guarda los últimos `MONITOR_STORE_CAPACITY` eventos (2000). Lo más antiguo se descarta.
- Asigna a cada evento su propia posición, `cursor`, que es la que usa el navegador. No se puede usar el `seq` del backend porque puede haber varios backends y cada uno cuenta por su lado.
- Reconoce repetidos por `origin.instance` + `id`.
- Mantiene, por backend: `head`, último `seq` recibido, hora de la última entrega, la última foto de recursos y las alertas activas. Las alertas salen de la foto más reciente, y entre fotos se ajustan con `alert.raised` y `alert.cleared`.
- Con `MONITOR_STORE_FILE` añade cada evento a un archivo de líneas JSON y recarga su final al arrancar.

**Su límite principal.** Es una copia en memoria:

- Empieza vacío con cada proceso (salvo que use el archivo).
- En hosting sin servidor (Vercel, donde está el sitio hoy) cada instancia tiene su propia memoria: un evento que recibe una instancia no lo ve un lector atendido por otra. **Para que el tablero funcione desplegado hace falta un almacén duradero** (Postgres o Redis) detrás de la misma clase. Es parte de la issue del tablero.
- No se pierde nada del lado del backend: guarda el registro completo y vuelve a enviar lo que el sitio no confirmó.

### 5.3 Lectura

| Ruta | Devuelve |
| --- | --- |
| `GET /api/monitor/summary` | `{ cursor, stored, capacity, receiving, origins: [...], counts: { bySeverity, bySource, byCategory } }`. Cada origen trae `env`, `instance`, `head`, `lastSeq`, `lastDeliveryAt`, `resources`, `resourcesAt` y `alerts` |
| `GET /api/monitor/events?after=<cursor>&limit=&type=&source=&severity=` | `{ schema, cursor, events }`. Cada evento añade `cursor` y `origin`. Sin `after`, los más recientes |
| `GET /api/monitor/stream?after=<cursor>` | Server-Sent Events con los eventos nuevos (`event: monitor`). Reanuda con `Last-Event-ID`; envía un comentario cada 20 s para que los proxys no corten la conexión |
| `POST /api/monitor/session` `{ token }` | Cambia el token del tablero por una cookie de sesión. `DELETE` la borra |

**Quién puede leer** ([`access.ts`](https://github.com/TilcAI/tilcai-web/blob/main/src/lib/monitor/access.ts)). Los datos incluyen saldos, direcciones e identificadores de operaciones, así que no son públicos por omisión:

- Con `MONITOR_DASHBOARD_TOKEN`: quien lo presente, en la cookie `tilcai_monitor` (la pone la página; guarda un valor derivado del token, no el token) o en `Authorization: Bearer` (para scripts).
- Sin esa variable: abierto en desarrollo, cerrado en producción (`503`).

### 5.4 Interpretación

El backend envía hechos; el significado para una persona vive en [`src/lib/monitor/interpret.ts`](https://github.com/TilcAI/tilcai-web/blob/main/src/lib/monitor/interpret.ts), en español e inglés:

- `categoryOf(type)` y `CATEGORY_LABELS`: la categoría de un evento y su nombre.
- `EVENT_CATALOG` y `explainEvent(type, lang)`: título y explicación de cada tipo. Por ejemplo, para `vault.disbursement.rejected`: «El vault no pudo aceptar un desembolso: sin fondos (BUDGET), en pausa (PAUSED) o sobre sus límites (PAYMENT_LIMIT). No se envió nada; quien llama reintentará».
- `ALERT_CATALOG` y `explainAlert(code, lang)`: título, qué hacer y, en los códigos con destino (`RELAYER_LOW_GAS:avalanche-fuji-relayer`), de qué relayer se trata.

Un tipo o un código que el catálogo no conoce se muestra por su nombre, sin romper la página.

### 5.5 La página y el hook

`/[lang]/monitor` es una página estática: no trae datos del servidor. Todo lo pide el navegador a `/api/monitor/*` con el hook [`useMonitorFeed()`](https://github.com/TilcAI/tilcai-web/blob/main/src/components/monitor/useMonitorFeed.ts):

```
al montar ──▶ GET summary + GET events?limit=500
                 │ 401 → estado "locked" (formulario del token → POST session → recargar)
                 │ 503 → estado "unconfigured"
                 ▼
            estado "ready" ──▶ EventSource /api/monitor/stream?after=<cursor>
                                  │ evento nuevo → se añade a la lista (máximo 500 en pantalla)
                                  │ si es resources.snapshot o alert.* → vuelve a pedir summary
                                  └ si se corta → el navegador reconecta solo y retoma donde iba
            además, summary cada 30 s por si el flujo se quedó callado
```

Devuelve `{ state, connection, summary, events, reload, unlock, signOut }`. Es la única pieza que el tablero necesita para tener datos.

`MonitorBoard` es la vista base construida sobre ese hook: alertas activas con su indicación, una fila de tarjetas por backend (vault, gas de cada relayer, memoria, event loop, colas, eventos) y la lista de eventos con filtros por categoría, severidad y texto; al abrir un evento se ve su explicación y sus datos. Las fotos de recursos no aparecen en la lista salvo que se filtre por «Recursos»: ya están en las tarjetas. No tiene gráficos ni histórico.

## 6. Tres recorridos

### 6.1 Una compra con QR, de punta a punta

Es la prueba E2E del 9 de octubre (optipagos-backend como quien cobra):

| # | Qué pasa | Evento |
| --- | --- | --- |
| 1 | El bot pide un QR por Bs 11,92 | `qr.created` |
| 2 | Alguien pulsa «Simular depósito» | `qr.paid` |
| 3 | TilcAI avisa al bot y este responde `{success:true}` | `qr.callback_delivered` |
| 4 | El bot confirma el pago consultando el QR y pide el desembolso | `vault.disbursement.transition` (`null → REQUESTED`) |
| 5 | TilcAI simula y envía `disburse` por el relayer | `vault.disbursement.transition` (`REQUESTED → SUBMITTED`) |
| 6 | TilcAI lee el recibo y comprueba el evento `Disbursed` del contrato | `vault.disbursement.transition` (`SUBMITTED → CONFIRMED`, con `txHash`) |

Entre el paso 2 y el 6 pasaron entre 12 y 16 segundos.

### 6.2 El vault se queda sin fondos

| # | Qué pasa | Evento |
| --- | --- | --- |
| 1 | La siguiente foto ve saldo 0 | `alert.raised` (`VAULT_EMPTY`, error) |
| 2 | Un cliente pide un desembolso | `vault.disbursement.rejected` (`BUDGET`), y otro por cada reintento |
| 3 | Alguien recarga el contrato | — |
| 4 | La siguiente foto ve saldo | `alert.cleared` (`VAULT_EMPTY`) |
| 5 | El cliente reintenta | `vault.disbursement.transition` × 3 hasta `CONFIRMED` |

### 6.3 El sitio se cae y vuelve

| # | Qué pasa |
| --- | --- |
| 1 | El envío falla. El backend anota el error y espera 4 s, 8 s, 16 s… hasta 5 minutos |
| 2 | Al tercer fallo: `alert.raised` (`MONITOR_SINK_FAILING:web`). El evento queda en el registro y viajará con los demás |
| 3 | El backend sigue registrando todo; los pagos no se enteran |
| 4 | El sitio vuelve. El siguiente envío entrega lo acumulado en lotes de 100 |
| 5 | `alert.cleared` |

## 7. Ponerlo en marcha

### 7.1 Variables

| Lado | Variable | Valor |
| --- | --- | --- |
| Backend | `MONITOR_WEB_URL` | `<sitio>/api/monitor/events`. Vacía: los eventos se quedan en el backend |
| Backend | `MONITOR_WEB_SECRET` | El secreto compartido, 16 caracteres o más (`openssl rand -hex 32`) |
| Backend | `MONITOR_RESOURCES_INTERVAL_MS` | Cada cuánto se toma la foto. Por defecto 30000 |
| Backend | `MONITOR_RETENTION_DAYS` | Días que se conserva el registro. Por defecto 14 |
| Backend | `RELAYER_WEBHOOK_SIGNING_KEY` | La `WEBHOOK_SIGNING_KEY` del relayer |
| Sitio | `MONITOR_INGEST_SECRET` | El mismo secreto que `MONITOR_WEB_SECRET` |
| Sitio | `MONITOR_DASHBOARD_TOKEN` | Lo que presenta quien abre el tablero |
| Sitio | `MONITOR_STORE_FILE` | Opcional: archivo para conservar los eventos entre reinicios de un servidor único |
| Sitio | `MONITOR_STORE_CAPACITY` | Opcional: eventos en memoria. Por defecto 2000 |

### 7.2 En local, paso a paso

```sh
SECRETO=$(openssl rand -hex 32)

# 1. El sitio
cd tilcai-web
printf 'MONITOR_INGEST_SECRET=%s\nMONITOR_DASHBOARD_TOKEN=un-token-para-entrar\n' "$SECRETO" > .env.local
pnpm install --frozen-lockfile && pnpm build && pnpm start        # http://localhost:3000

# 2. El backend (necesita el relayer en localhost:8080 y su .env habitual)
cd ../tilcai-infrastructure
MONITOR_WEB_URL=http://localhost:3000/api/monitor/events MONITOR_WEB_SECRET=$SECRETO npm start

# 3. Abrir http://localhost:3000/es/monitor y escribir el token
```

A los pocos segundos aparecen `system.started` y la primera foto de recursos. Para ver más movimiento sin tocar fondos, activar el mock de QR (`QR_MOCK_ENABLED=true`, con `QR_MOCK_EMAIL` y `QR_MOCK_PASSWORD`), generar un QR y pulsar «Simular depósito» en `http://127.0.0.1:8787/mock/vendis/`.

Comprobar sin navegador:

```sh
curl -H "Authorization: Bearer un-token-para-entrar" http://localhost:3000/api/monitor/summary
curl -H "Authorization: Bearer $TILCAI_API_KEY" "http://127.0.0.1:8787/v1/monitor/events?limit=20"
```

## 8. Seguridad

- **Dos secretos distintos, dos direcciones.** `MONITOR_WEB_SECRET` / `MONITOR_INGEST_SECRET` protege la escritura (backend → sitio). `MONITOR_DASHBOARD_TOKEN` protege la lectura (persona → sitio). Ninguno llega al navegador: la cookie guarda un valor derivado.
- **El navegador nunca habla con el backend** ni conoce su dirección o su clave.
- **Los eventos no llevan secretos.** El backend sustituye por `[redacted]` los valores con nombre de secreto antes de guardarlos, y de un aviso del relayer no copia el `data` de la transacción. Sí llevan direcciones públicas, saldos, montos, identificadores de operaciones y hashes: por eso la lectura pide token.
- **Lo que llega se muestra como texto.** El sitio valida la forma del lote y React escapa el contenido: un `summary` con HTML no se ejecuta.
- **Un envío capturado no sirve más tarde:** la firma cubre la hora y el sitio rechaza lo que tenga más de cinco minutos.
- **Los avisos del relayer** se aceptan firmados o, sin clave configurada, solo desde el mismo equipo.

## 9. Límites y pendientes

1. **Almacén en memoria en el sitio** (§ 5.2). Bloquea el uso del tablero en el despliegue actual de Vercel con más de una instancia.
2. **El relayer real no envía sus avisos a TilcAI** (§ 4.3). El receptor está probado con avisos firmados de prueba, no con el relayer en marcha.
3. **Sin histórico ni gráficos.** El sitio guarda 2000 eventos y la última foto de cada backend; no hay series de tiempo de memoria, saldo o latencia. El registro completo de 14 días está en el backend.
4. **Los textos de `summary` vienen en español** desde el backend. La interpretación del sitio sí está en los dos idiomas.
5. **El lint de `tilcai-web` no corre** en `main` (TypeScript 7 no es compatible con la versión instalada de `typescript-eslint`). Es anterior a este trabajo; los tipos y los tests sí pasan.
6. **No se reconstruyó la imagen Docker de TilcAI.** El contenedor en uso no tiene nada de esto hasta que se despliegue la versión nueva.

## 10. Dónde está cada cosa

| Qué | Backend (`tilcai-infrastructure`) | Sitio (`tilcai-web`) |
| --- | --- | --- |
| Contrato | `src/modules/monitor/domain.ts` | `src/lib/monitor/contract.ts` |
| Registro / almacén | `src/modules/monitor/service.ts`, `repository.ts` | `src/lib/monitor/store.ts` |
| Envío / ingesta | `src/modules/monitor/forwarder.ts` | `src/app/api/monitor/events/route.ts` |
| Firma | `forwarder.ts` (`signDelivery`) | `src/lib/monitor/signature.ts` |
| Recursos y alertas | `src/modules/monitor/resources.ts` | `src/lib/monitor/interpret.ts` (`ALERT_CATALOG`) |
| Avisos del relayer | `src/modules/monitor/relayer-webhook.ts`, `correlate.ts` | — |
| Rutas de lectura | `src/apps/api/monitor-routes.ts` | `src/app/api/monitor/{summary,events,stream,session}/route.ts` |
| Acceso | `src/apps/api/auth.ts` | `src/lib/monitor/access.ts` |
| Bucles | `src/apps/worker/loop.ts` | — |
| Vista | — | `src/components/monitor/`, `src/app/[lang]/monitor/page.tsx` |
| Tests | `test/unit/monitor.test.ts`, `api-monitor.test.ts`, `qrsimple.test.ts` | `test/monitor.test.ts` |
