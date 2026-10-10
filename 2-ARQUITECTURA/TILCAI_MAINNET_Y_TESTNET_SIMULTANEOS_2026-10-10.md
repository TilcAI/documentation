# TilcAI en mainnet y testnet a la vez

**Fecha:** 10 de octubre de 2026. **Repositorios:** `tilcai-infrastructure` (backend) y `tilcai-web` (tablero).
**Estado:** las dos instancias corren en el servidor de pruebas desde el 2026-10-10 y la ruta Avalanche → Stellar liquidó dos pagos reales de 0.01 USDC en mainnet. Ningún contrato propio tiene auditoría independiente. La guía operativa es [`deploy/MAINNET_DEPLOYMENT.md`](https://github.com/TilcAI/tilcai-infrastructure/blob/main/deploy/MAINNET_DEPLOYMENT.md).

## 1. La decisión: dos instancias, no una

Testnet y mainnet corren como dos procesos de la misma imagen. `TILCAI_ENV` elige las redes al arrancar y un proceso nunca atiende las dos.

| | Testnet (`tilcai`) | Mainnet (`tilcai-mainnet`) |
| --- | --- | --- |
| Redes | Avalanche Fuji → Stellar Testnet | Avalanche C-Chain → Stellar Public Network |
| API | `:8787` | `127.0.0.1:18787` |
| Base SQLite, claves de API, secreto del tablero | propios | propios, distintos de los de testnet |
| Relayers | `avalanche-fuji-relayer`, `stellar-example` | `avalanche-relayer`, `stellar-relayer` |
| Clave de desarrollo, firma local, simulador de QR | permitidos | el proceso se niega a arrancar con ellos |
| Envío de fondos | siempre | solo con `MAINNET_TRANSACTIONS_ENABLED=true` |

Se eligió así porque un error de configuración en un proceso compartido podría mezclar fondos de prueba con reales: con dos procesos, una clave de testnet no existe en mainnet. El costo es operar dos contenedores y dos bases.

## 2. Qué existe en mainnet

- `TilcaiCctpRouter` en Avalanche C-Chain: `0xf6a2EdE00c441863519C6B30A1eb2d04E61847AB`, sin owner ni upgrade. Es el único contrato propio desplegado y el único que la instancia exige.
- Un pago gasless de 0.01 USDC liquidado el 2026-10-10 en unos 27 segundos, con comisión CCTP 0: burn `0x3bfdc1021f1d1277e7ae05065b157c7346a4f8e072fea4c03ab430ee0b739056`, mint `cead8c23f46687dc90feba1242a20382756454366fc287f7b66b11ffe10ebbc0`. Se hizo con una copia del código de ese día, antes de los cambios de esta fecha.
- Un segundo pago de 0.01 USDC, ya contra la instancia `tilcai-mainnet` y por su API (`npm run e2e:gasless`), liquidado en 1 min 45 s: burn `0xcfb8bb2d8aa214d09d93ce6ecdb3d2a0883c7a92f8f05ad523173431051c4413`, mint `43c32917b08c685abeca884188302531eca6a2caad63bdf9a25e81b2bd124821`.
- Cuentas de contrato, vaults y x402 quedan apagados en mainnet hasta desplegar y verificar sus contratos. Cada dirección que se configure enciende su función.

## 3. Qué cambió en el código

- **Validación de arranque** (`src/config/env.ts`): mainnet exige lo que la ruta crosschain necesita (base, claves, un relayer por cadena, router, RPC) y trata el resto como funciones opcionales. Un mismo relayer puede servir a los dos entornos; los separa el id de relayer.
- **Preflight** (`npm run mainnet:preflight`): compara el código desplegado de cada contrato propio con su artefacto compilado, sin contar los `immutable`.
- **Prueba de extremo a extremo** (`npm run e2e:gasless`): paga contra una instancia por su API como lo haría un tercero. La clave de quien paga no sale del proceso de la prueba. Verificada en testnet y en mainnet.
- **Compose** (`deploy/docker-compose.mainnet.yml`, `deploy/.env.mainnet.example`): la instancia de mainnet y, opcional, un relayer propio.
- **Tablero** (`tilcai-web`): un bloque por backend, mainnet primero y etiquetado como fondos reales, con filtro por entorno. Mainnet entrega sus eventos con un secreto propio (`MONITOR_INGEST_SECRET_MAINNET`) y cada secreto vale solo para su entorno.

## 4. Riesgos aceptados y pendientes

- **Sin auditoría.** El router mueve USDC de quien firma una autorización; no custodia saldo.
- **Relayer compartido.** Usa el mismo firmante que testnet y no tiene lista de receptores permitidos: quien obtenga la clave de su API puede gastar su AVAX y XLM. Pendiente: relayer propio de mainnet con firmantes independientes.
- **Sin avisos del relayer en mainnet.** Los pagos avanzan por sondeo; el tablero no muestra eventos `relayer.*` de mainnet.
- **RPC públicos y SQLite.** Suficientes para pruebas de bajo volumen, no para operar.
- **Dos liquidaciones reales, ambas de 0.01 USDC.** No se probaron montos mayores, concurrencia ni fallos en mainnet.
