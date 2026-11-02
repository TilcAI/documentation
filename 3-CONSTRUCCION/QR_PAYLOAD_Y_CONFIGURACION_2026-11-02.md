# QR Simple y configuración bancaria

Corte: 2026-11-02 UTC. Rama publicada: feat/qr-providers-fallback en
[tilcai-infrastructure](https://github.com/TilcAI/tilcai-infrastructure/tree/feat/qr-providers-fallback).

## Generación desde payload

El commit dfb7006 elimina la lectura de una imagen fija por el servicio y genera el PNG con
`renderQrPng(qrMatrix(payload))`. El payload configurado no vacío tiene prioridad; en otro
caso usa el payload propio del código almacenado. La función no distingue desarrollo de
producción. Esto describe la generación de imagen del simulador, sin acreditar un cobro.

Las pruebas comprueban imagen del payload propio, del configurado y coherencia entre
base64 y URL. Pasaron las 15 pruebas de test/unit/qrsimple.test.ts.

El archivo src/modules/qrsimple/bank-qr.png se publicó en e064378 junto con los archivos
locales pendientes. Es una imagen QR bancaria real; el servicio ya no la importa ni devuelve
como imagen fija. No usarla como ejemplo de un QR sintético.

## Configuración publicada en e064378

- BANECO_BASE_URL usa por defecto https://apimkt.baneco.com.bo/apiGateway/ en el esquema,
  .env.example y Compose general/mainnet. La URL de certificación anterior era
  https://apimktdesa.baneco.com.bo/ApiGateway/. Seleccionar endpoint y credenciales por entorno.
- Compose mainnet añade un bind de MAINNET_TAILSCALE_IP a los de loopback y bridge.
  Configurar la IP de cada host; el valor predeterminado pertenece al despliegue existente.
- El comentario de .env.example aún menciona certificación aunque su valor es producción.
  Seguir el valor efectivo y corregir ese comentario en una próxima modificación del backend.

La generación del PNG y los tests locales no prueban abono, callback autenticado o
conciliación. No se ejecutaron operaciones bancarias reales durante estos cambios.
