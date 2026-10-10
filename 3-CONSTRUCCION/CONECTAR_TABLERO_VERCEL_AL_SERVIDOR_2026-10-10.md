# Conectar el tablero de Vercel con el backend y el relayer del servidor

**Fecha:** 10 de octubre de 2026. **Aplica a:** `tilcai-web` desplegado en Vercel (`https://tilcai.vercel.app`) y a los contenedores `tilcai`, `tilcai-mainnet` y el OpenZeppelin Relayer del servidor de pruebas.
**Estado:** procedimiento escrito, **no ejecutado**. Tiene un límite conocido en Vercel (sección 2) que conviene leer antes de empezar.

## 1. Qué se conecta con qué

El sitio nunca habla con el relayer. El recorrido es de un solo sentido y sale del servidor:

```
relayer (:8080) ──webhook──▶ tilcai / tilcai-mainnet ──POST firmado──▶ tilcai-web (/api/monitor/events)
                              (también lo sondean)                      el navegador solo lee del sitio
```

De ahí salen tres consecuencias prácticas:

- **No hay que abrir puertos ni montar un túnel.** El servidor llama a Vercel por HTTPS de salida. El relayer sigue escuchando solo en el servidor.
- **Optipagos no se toca.** No cambia su contenedor, su `.env` ni su base. Lo único que se reinicia son los contenedores de TilcAI, unos segundos cada uno (sección 4).
- **El relayer no se reconfigura.** Sus avisos ya llegan a `tilcai`; no hay que cambiarle nada ni reiniciarlo.

## 2. Límite conocido antes de empezar

- **El sitio en Vercel guarda los eventos en memoria, por instancia.** En hosting sin servidor, un evento que recibe una instancia no lo ve un lector atendido por otra, y la memoria se pierde cuando la instancia se recicla. El tablero puede verse vacío o incompleto aunque las entregas respondan 200. La solución es un almacén duradero (Postgres o Redis) detrás de `MonitorStore`, pendiente en [tilcai-web#25](https://github.com/TilcAI/tilcai-web/issues/25). Mientras tanto el tablero fiable es el contenedor local (`:3311`).
- **Cada backend entrega a un solo destino.** `MONITOR_WEB_URL` es una sola URL: apuntarla a Vercel deja sin eventos nuevos al tablero local. Tener los dos a la vez requiere un cambio de código (un segundo destino), que hoy no existe.
- **La cuenta de Vercel de este servidor no tiene acceso al proyecto.** Los pasos de Vercel se hacen desde el panel, con una cuenta que sí lo tenga.

Si el objetivo es solo mostrar el tablero fuera del servidor, la alternativa sin estos límites es publicar el contenedor local detrás de un proxy con TLS.

## 3. En Vercel: variables y despliegue

En el proyecto `tilcai-web` → **Settings → Environment Variables**, entorno **Production**:

| Variable | Valor |
| --- | --- |
| `MONITOR_INGEST_SECRET` | El mismo `MONITOR_WEB_SECRET` del contenedor `tilcai` (testnet) |
| `MONITOR_INGEST_SECRET_MAINNET` | El mismo `MONITOR_WEB_SECRET_MAINNET` de `tilcai-mainnet`. Tiene que ser distinto del anterior |
| `MONITOR_DASHBOARD_TOKEN` | Un valor nuevo (`openssl rand -hex 32`). Quien abra `/es/monitor` lo presenta |
| `MONITOR_STORE_FILE` | No definirla: en Vercel no hay disco que sobreviva |

Los dos secretos de ingesta actuales están en `tilcai-web/.env.docker.local` del servidor. Se pueden reutilizar, o generar un par nuevo y usarlo también en la sección 4. No los pegues en chats ni en issues.

Después, **Deployments → Redeploy** del último despliegue de `main`: las variables solo entran en despliegues nuevos. `main` ya incluye el tablero por entorno (commit `612c1e0`).

Comprobación, antes de tocar el servidor:

```bash
curl -s -o /dev/null -w '%{http_code}\n' -X POST https://tilcai.vercel.app/api/monitor/events -d '{}'
# 401 = configurado y exige firma.   503 = falta MONITOR_INGEST_SECRET o no se redesplegó.
```

## 4. En el servidor: apuntar los backends a Vercel

URL de destino para los dos: `https://tilcai.vercel.app/api/monitor/events`.

### Mainnet (`tilcai-mainnet`)

En `tilcai-infrastructure/deploy/.env.mainnet`:

```
MONITOR_WEB_URL_MAINNET=https://tilcai.vercel.app/api/monitor/events
MONITOR_WEB_SECRET_MAINNET=<el valor de MONITOR_INGEST_SECRET_MAINNET en Vercel>
```

```bash
cd /home/saul-bms/proyectos/tilcai/tilcai-infrastructure
docker compose -f deploy/docker-compose.mainnet.yml --env-file deploy/.env.mainnet up -d
```

Compose recrea solo `tilcai-mainnet`. Los pagos en curso se retoman al arrancar: el estado está en su base.

### Testnet (`tilcai`)

Este contenedor se creó con `docker run`, así que se recrea con su misma configuración y dos valores cambiados. Es el que usa Optipagos: el corte dura lo que tarda en arrancar (unos segundos) y Optipagos sigue en marcha; una llamada que caiga justo en ese momento falla y se reintenta.

```bash
umask 077
docker inspect tilcai --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep -vE '^(PATH|NODE_VERSION|YARN_VERSION|HOSTNAME)=|^$' > ~/backups/tilcai-vercel.env
# Editar ~/backups/tilcai-vercel.env:
#   MONITOR_WEB_URL=https://tilcai.vercel.app/api/monitor/events
#   MONITOR_WEB_SECRET=<el valor de MONITOR_INGEST_SECRET en Vercel>
docker stop tilcai && docker rm tilcai
docker run -d --name tilcai --network host --restart unless-stopped \
  --env-file ~/backups/tilcai-vercel.env -v tilcai-data:/data tilcai/tilcai:local
curl -s http://127.0.0.1:8787/health
```

Nunca detengas procesos por nombre (`pkill -f`): en este servidor alcanza a los contenedores. Solo `docker stop` del contenedor exacto.

## 5. Comprobar

```bash
# Ninguna entrega rechazada desde el cambio (debe imprimir 0 en los dos):
for c in tilcai tilcai-mainnet; do docker logs --since 5m "$c" 2>&1 | grep -c 'monitor delivery to tilcai-web failed'; done
```

- `401 mismatch` en el log: el secreto del backend no es el de Vercel para ese entorno.
- `401 environment`: los secretos están cruzados (el de testnet firmando como mainnet o al revés).
- `503 not_configured`: faltan las variables en Vercel o no se redesplegó.

Luego abrir `https://tilcai.vercel.app/es/monitor`, presentar el token y buscar dos bloques, con mainnet primero. Si las entregas responden bien y el tablero aparece vacío o a medias, es el límite de la sección 2, no un error de configuración.

El backend solo envía lo nuevo. Para reenviar el historial a un sitio que arrancó vacío, poner `last_seq = 0` en la tabla `monitor_sinks` de la base de ese backend; el sitio descarta lo repetido.

## 6. Volver al tablero local

Restaurar los valores anteriores (`http://host.docker.internal:3311/api/monitor/events` en mainnet; el `MONITOR_WEB_URL` que tenía `tilcai`, guardado en `~/backups/docker-pre-mainnet-20261010/tilcai.env`) y repetir la sección 4. El contenedor `tilcai-web` local no hace falta tocarlo: sigue en `:3311` con sus eventos anteriores.
