# Solana: primer incremento de implementación

Fecha: 2026-11-27. Estado: base experimental implementada y emisión SCA + ATA finalizada en Devnet mediante el fork del relayer; sin transferencias USDC. Repositorios modificados: tilcai-core, tilcai-infrastructure y documentation. Se conservaron los cambios preexistentes. Core no tiene una nueva publicación de paquete. El estado de publicación/despliegue se registra abajo.

## Alcance realizado

Este incremento comienza SOL-01/SOL-02 y la parte experimental de contratos de SOL-04. Ninguno de esos hitos se declara completamente aceptado. La emisión productiva SCA, rampa BOB→USDC, x402 y crosschain siguen pendientes.

### Core y dependencias locales

Se compiló el core desde su lockfile. El problema de carga anterior tenía dos causas locales: infrastructure apuntaba a una copia antigua de core y SDK carecía del alias instalado. `tilcai-core/scripts/link-local.mjs` valida consumidores y vincula explícitamente el core compilado; no edita manifests ni lockfiles y no reemplaza directorios reales. La instalación normal del registro continúa siendo el procedimiento de CI/releases, sujeto a acceso al registro privado.

El nuevo subpath optativo `@tilcai/core/experimental/solana` (alias `tilcai-core/experimental/solana`) contiene IDs CAIP-2 Devnet/mainnet, mints USDC nativos, referencias de transacción y roles settings/vault/ATA. Valida formatos base58 y longitudes decodificadas, preservando mayúsculas. No verifica firmas, pertenencia onchain ni existencia de fondos. Los tipos `SolanaNetworkId` y `MultichainNetworkId` son aditivos; el `NetworkId` de APIs existentes mantiene EVM/Stellar. El paquete no fue publicado con una versión nueva.

### Persistencia de identidad

La migración 10 reemplaza índice y trigger para aplicar comparación sin mayúsculas solo a redes EVM, y comparación exacta a las demás. Lookup e inmutabilidad del repositorio siguen la misma regla. Evita colisiones o búsquedas erróneas entre direcciones base58 que difieren en mayúsculas.

La prueba migra una base en versión 9, conserva la cuenta previa byte por byte, reaplica migraciones de manera idempotente, mantiene lookup EVM, almacena dos identidades Solana distintas, bloquea duplicados y mutaciones de identidad desde repositorio y SQL directo, y comprueba integridad/FKs. La verificación inicial se ejecutó sobre bases de prueba. No se habilitó Solana en tipos/rutas productivas ; la aplicación operativa se registra en la sección de despliegue. La reversión a un índice que pliega mayúsculas requeriría revisar datos nuevos; no ofrecer un rollback destructivo automático.

### Prototipo Squads Devnet

El paquete privado `tilcai-infrastructure/tools/solana` tiene lockfile y dependencias fijadas: Squads 2.1.4, web3.js 1.98.4 y SPL Token 0.4.15. Esta frontera permite evaluar el SDK real sin cambiar dependencias de la aplicación.

`deriveIdentity` separa settings PDA, vault PDA y ATA USDC. `prepareIssuance` consulta genesis Devnet, programa ejecutable y configuración/discriminador/treasury del programa; comprueba un techo explícito de tarifa de creación. Construye transacción legacy sin firmar, con create y creación ATA idempotente cuando hacen falta; devuelve blockhash, lastValidBlockHeight y firmantes públicos requeridos. No carga dotenv ni posee claves ni envía transacciones.

La configuración candidata tiene un owner con permisos completos, threshold 1, timeLock 0, sin config authority ni rent collector. Sponsor y creation key son externos y distintos, sin membresía o autoridad sobre fondos. La creation key deberá ser persistida/firmada por el actor externo cuando se integre el servicio; el prototipo no resuelve esa custodia ni tenant/idempotencia. El techo comprobado es la tarifa de creación del programa, no fees de transacción ni rent.

`inspectIssuance` verifica datos finalizados: owner del programa, discriminador, create key/bump, configuración y miembro esperado, y ATA con mint USDC, autoridad vault, SPL Token, inicialización, freeze, delegate y close authority. La etiqueta ACTIVE del prototipo significa identidad estructural verificada; no acredita permisos temporales, compatibilidad x402/CCTP ni aprobación productiva. Si ya existe la configuración válida, solo prepara ATA pendiente; si ambas existen, no genera otra transacción.

## Verificación realizada

Entorno local: Node 25.7.0; no sustituye la validación CI/runtime soportada del proyecto.

| Comprobación | Resultado |
|---|---|
| Core: build, typecheck y tests | 36/36 pasan; export experimental optativo ESM/CJS, base58 y vinculación local incluidos |
| Infrastructure: typecheck y tests | 324/324 pasan, incluida actualización de identidad/migración 10 |
| SDK, sin cambios de fuente | 86/86 tests; typecheck y build pasan con core local |
| Prototipo: instalación desde lock, lint, typecheck y tests | 15/15 pasan; preparación, firmantes, inspección/repetición y ataques de red/owner/mint/configuración/ATA |
| Lint backend | El comando estándar no arrancó porque faltaba ESLint en su instalación local. Se ejecutó correctamente el mismo conjunto de reglas con el toolchain aislado y fijado de tools/solana |
| Smoke de paquete SDK instalado | Falló en npm install del consumidor temporal; el script usa registro GitHub y modo silent. Diagnóstico posterior: E403 del registro privado GitHub Packages; no se declara validado el consumo instalado desde registro |

El lint alternativo usa:
`node tools/solana/node_modules/eslint/bin/eslint.js --config tools/solana/eslint.config.mjs src test`.
No se cambió la configuración productiva ni se omitieron sus tres reglas.

Se obtuvo evidencia adicional mediante lecturas reales de `https://api.devnet.solana.com` el **2026-11-27T05:14:46.170Z**: programa/configuración reconocidos, estado ABSENT, tarifa de creación observada 0 lamports y transacción sin firmar construida con dos firmantes requeridos. Esa tarifa no es precio prometido ni costo total. Esta primera evidencia es solo preparación; la emisión posterior figura abajo. La evidencia sanitizada está en `tilcai-infrastructure/tools/solana/evidence/devnet-preparation.json`.

## Reproducción

Desde tilcai-core: `npm ci --ignore-scripts`, `npm run build` y `node scripts/link-local.mjs ../tilcai-infrastructure ../tilcai-sdk` para estos consumidores locales. El helper sustituye solo links o entradas ausentes; rechaza un directorio instalado real. Con dependencias de los consumidores disponibles, ejecutar typecheck/tests normalmente.

Desde infrastructure/tools/solana: `npm ci --ignore-scripts`, `npm run lint`, `npm run typecheck` y `npm test`. Desde infrastructure, los scripts adicionales `typecheck:solana` y `test:solana` remiten a la herramienta; su instalación separada sigue siendo explícita.

La CLI `npm run prepare:account -- OWNER_PUBLIC_KEY CREATE_PUBLIC_KEY SPONSOR_PUBLIC_KEY MAX_CREATION_FEE_LAMPORTS` solo requiere material público y devuelve bytes sin firmar. Está restringida a Devnet y no envía nada. Ver el README de la herramienta antes de usarla.

## Trabajo pendiente y siguiente aceptación

Completar SOL-02 exige aprobación de wallet real y custodia/idempotencia del servicio, verificar saldo/transferencia y demostrar x402 y CCTP desde la misma SCA. Faltan medición/techos de rent y fees, revisión de versión/binario/upgrade authority/auditoría, wallet/owner approval y persistencia de intentos inciertos. Hasta pasar ese gate, Squads permanece candidato y no se registra como AccountDeployer.

Los grants TTL/revoke deben probarse mediante RPC directo; SpendingLimit v4 no aporta expiración absoluta ni autorización CCTP genérica. Rampa conserva sus dependencias: operador BOB, reserva de liquidez, cotización firme, evidencia monetaria y payout conciliado; no se conectó el QR al prototipo.

[Plan completo y avance verificado en Notion Dev Docs](https://www.notion.so/4252dc79a4258163b1c7d34e3f71a5b6).

## Referencias técnicas

[Squads multisigCreateV2](https://github.com/Squads-Protocol/v4/blob/main/sdk/multisig/src/instructions/multisigCreateV2.ts), [PDAs](https://github.com/Squads-Protocol/v4/blob/main/sdk/multisig/src/pda.ts), [Circle USDC](https://developers.circle.com/stablecoins/usdc-contract-addresses), [x402 exact/SVM](https://github.com/x402-foundation/x402/blob/main/specs/schemes/exact/scheme_exact_svm.md).


## Emisión real mediante el fork · 2026-11-27

Se reconstruyó y verificó el fork propio `SaulChoque/openzeppelin-relayer`, commit
`2226ebc221afb398ecbf899943596bb881284efa`, en saul-bms. La corrección Docker copia las
bibliotecas OpenSSL disponibles y valida el cargador; se conservaron los 12 relayers previos.
Se añadió un signer cifrado y relayer Devnet dedicado con máximo dos firmas, 1M lamports de fee,
1232 bytes y programas Squads/ATA permitidos. La clave del sponsor permanece en el signer.
No se publicaron secretos ni se sustituyó el relayer operativo de producción.

La herramienta usa firma externa de creation key y patrocinio/envío exclusivamente por el fork;
verifica mensaje y firmas conservados, simula con sigVerify y persiste/fsync la referencia pública
antes del POST. ACK incierto requiere reconciliar, sin nuevo envío automático. El journal local
no sustituye persistencia multi-tenant. ATA-only sigue cerrado para envío.

El usuario fondeó el sponsor de prueba tras fallar el faucet con 410 Gone. A las 06:08:31 UTC
la emisión quedó FINALIZED, confirmada de nuevo mediante reconciliación de solo lectura:

- Firma: `23B2VzumJH54CWTkSsj5AwXLcKL7nfQbai194ATS66VLMPtmaMLfXKtVQqimHmGuubJsWnoZTnjPQShKGEYHFQx7`
- Settings SCA: `H5sJWV214LTsZh5BRaLVbnbTTdrG4eCRyPk5MxnJoJnS`
- Vault: `CtDfWxPk4LBxFvGTgW1bc9pcTHi8t2CtNiY3vuuCZEqR`
- ATA USDC Devnet: `DXZeTzHkTRqTK5Z3KrXANhFs98ePdu2oHPSgzEeNQf4c`
- Relayer: `solana-devnet-relayer`, submission `fd50ff88-5aff-451b-89d6-aa0ebf90fe37`.

Evidencia pública: `tools/solana/evidence/devnet-issuance-1795759708225.json` en infrastructure.
El owner es una fixture desechable en memoria; no representa aprobación de wallet de usuario.
No se transfirió USDC ni se probó x402/CCTP desde esta cuenta. La inspección verifica settings,
vault derivado y ATA finalizados, no todos los requisitos de producto.

Resultados: 461 pruebas pasan (36 core, 324 backend, 86 SDK y 15 prototipo). El prototipo también
pasó typecheck y 15 pruebas en Node 24.22.3 dentro de Docker remoto.

## Decisión x402 y pendientes

Por instrucción del usuario se prioriza el facilitador/plugin del fork OpenZeppelin. No hay
fallback de envío RPC ni selección automática de CDP. Su existencia no prueba compatibilidad
con autorización CPI de Squads: siguen pendientes el gate exact/SVM verify/settle, transferencia
USDC, grants TTL/revoke, CCTP, rampa e integración HTTP multi-tenant.

## Despliegue

CI no publica ni despliega automáticamente (steps deshabilitados). La instalación nueva desde
GitHub Packages falló E403 con las credenciales disponibles. Se preparó una imagen de actualización
de fuentes sobre el runtime verificado 59917c41, con dependencias y lockfile sin cambios; el smoke
del candidato confirma migración 10 y métodos Solana del cliente. Se hizo backup SQLite coherente
antes del cambio. El rollout manual ya está verificado en `saul-tilcai-lor`:

- Core main: `45d8631e94d659c3649e27827c2da15e6fa72e10`; backend main/desplegado: `48b6f07dee3ba3aa8089ea1371205805fb03dced`.
- Imagen activa `sha256:b056d339f44b0d33cdb63b262a156d305516983b5402752cc12318894184dd7a` con label de revisión completa; 112 hashes de archivos del runtime coinciden con Git.
- `/health` y `/ready`: HTTP 200, todos los checks requeridos pasan. `/v1/routes`: 401 sin credencial y 200 con credencial operativa, sin publicar su valor.
- SQLite: migración 9→10, quick_check ok, cero errores FK y mismas identidades de cuentas antes/después.
- Testnet conservado, mainnet deshabilitado; Redis y relayer existente sanos. Solo se recreó el API.
- La imagen usa etiqueta con nombre GHCR pero fue construida localmente; no se publicó en el registro. Core conserva su versión publicada anterior.

[Evidencia sanitizada](SOLANA_PRODUCCION_EVIDENCIA_2026-11-27.json). El directorio operativo del
servidor `/srv/tilcai/releases/solana-candidate-20261127` conserva Dockerfile y fuentes exportadas
del commit. Backup coherente inmediato en `/srv/tilcai/backups/solana-20261127/pre-rollout.sqlite`;
rollback de imagen `tilcai/tilcai-api:rollback-solana-20261127`. No restaurar DB automáticamente:
primero detener escritores y revisar cambios posteriores al backup.

La emisión Devnet usa el fork de BMS. El API desplegado recibe las bases de persistencia y el
cliente tipado; no registra aún un provider HTTP Solana ni anuncia las cuatro capacidades como listas.

## CI de los commits publicados

[Core 45d8631: success](https://github.com/TilcAI/tilcai-core/actions/runs/45950644385).
[Backend 48b6f07: success](https://github.com/TilcAI/tilcai-infrastructure/actions/runs/45950644645):
offline lint/typecheck/tests y verificaciones Soroban; build Docker y smoke del contenedor pasan.
El job automático deploy quedó skipped según su configuración; el rollout descrito fue manual autorizado.
