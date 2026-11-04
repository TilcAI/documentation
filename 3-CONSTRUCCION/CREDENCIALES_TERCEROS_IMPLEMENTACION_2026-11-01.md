# Third-party credentials: implemented contract and deployment

Branch: feat/third-party-credentials, based on 73805cc (Vault/Soroban fixes).

## Implemented

Operator CLI creates tenants, issues expiring/scoped keys and rotates/revokes them. New keys
are restricted to the configured testnet/mainnet environment. SQLite migration 8 is additive;
key events contain IDs, kinds and timestamps only. Authentication reads revocation, expiry
and tenant status each time; last-use updates are throttled to once a minute.

`GET /v1/auth/context` returns:

```json
{
  "tenantId": "tenant_example",
  "tenantName": "Fexpo",
  "scopes": ["payments"],
  "environment": "testnet",
  "credential": {
    "id": "tenant_key_example", "tenantId": "tenant_example", "hint": "tilc_test_abcd",
    "label": "backend", "scopes": ["payments"], "source": "issued",
    "environment": "testnet", "createdAt": "2026-11-01T00:00:00.000Z",
    "expiresAt": "2027-01-30T00:00:00.000Z"
  }
}
```

The hint is a short partial identifier, not a usable secret. Legacy dev loopback has
credential=null. Authentication errors use 401; scope or operator restriction failures use
403. Invalid presented credentials cannot become the development operator. GET doesn't consume
sponsored-operation quota. There is no key-management privilege for a tenant.

## Onboarding Optipagos/Fexpo

Create separate tenants and issue payments keys only for their backend integrations. Add
accounts:read/write only where needed. Give each environment and service a separate secret,
transport using HTTPS and a secret manager, confirm tenant/scope/environment with introspection,
then configure the SDK or MCP. Existing data assigned to tenant_legacy is not transferred
merely by issuing a new tenant key: reconcile ownership and plan migration explicitly if
partners need access to historical payments.

Deploy backend migration before SDK/MCP introspection usage. Back up SQLite, verify migration
ID availability (6 is QR; 7 is sponsored holds already integrated; this change uses 8), run migration on a restored copy,
then confirm legacy operator and one test tenant. Restoring old code would ignore new expiry
and environment rules; do not roll back to an auth implementation that bypasses those rules.
A rollback requires revoking affected secrets and restoring a reviewed compatible release.

Do not create partner keys against the production DB as part of tests. Test tenants in this
change exist only in disposable databases. No production credentials were issued.

## SDK and MCP

SDK 0.4.0 adds `tilcai.auth.context()` and `apiKeyProvider` (sync or async) resolved on each
request/retry; it takes priority over static/environment key. On provider failure no request
is sent and details are redacted. Authenticated requests and event streams reject redirects.

Existing tilcai-mcp adds `tilcai_auth_context`, accepts TILCAI_API_KEY or
TILCAI_API_KEY_FILE (mutually exclusive), and rereads the file on every protected request.
Update mounted secrets atomically and with restrictive permissions. Tool errors omit raw
exception text. Issuance/revocation are not model tools. Existing payment tools and their
signing behavior remain; the new auth work does not make them an OAuth delegation system.

MCP transport remains stdio. Remote multiuser MCP requires a separately designed OAuth
resource server and authorization code/PKCE with token audience validation; API keys here
serve the configured backend integration, not individual user consent.

## Verification

Backend: 206 unit tests, typecheck, plus prior 5 Python deploy and 12 Rust Vault tests.
SDK: 85 tests, typecheck, ESM/CJS build and smoke package checks.
MCP: 7 tests, typecheck and build; in-memory MCP transport exercises tools/list and tools/call,
credential file rotation and secret-free outputs. No public network financial tests run.

No rate limiter is added here: existing daily sponsorship quotas are not request-rate limits.
Set gateway per-tenant request limits and alert on expiry/revocation during rollout. Audit
covers issue/revoke/rotate operations from the operator CLI; env-key synchronization keeps
its existing configuration-driven lifecycle.

Comprobación adicional: backend local real + SDK + cliente MCP pasaron introspección, rotación mediante proveedor dinámico y rechazo 401 de la clave anterior. El ejecutable MCP compilado pasó initialize/tools/list/tools/call mediante stdio sin acceder a una red pública.

## Publicación · 2026-11-02 UTC

Ramas feat/third-party-credentials publicadas: infrastructure b47165e (implementación
60e3199, incluye fixes Vault/Soroban), SDK f27f333 y MCP 2417706. La publicación no
acredita despliegue ni emisión de credenciales reales. Ver el
[estado de repositorios](ESTADO_REPOSITORIOS_2026-11-01.md).

## Integration update · 2026-11-04

PR #53 combines the credential branch with current main while preserving the latest Vault safeguards. Migration 8 follows deployed migrations 1–7 without rewriting them; upgrade tests cover schemas 5 and 7. Historical issued keys default to testnet and retain no expiry until rotated. Before mainnet, inventory and explicitly reissue keys in the intended environment. Do not silently reinterpret historical authorizations.

SDK and MCP consume the private Core package @tilcai/core@0.1.0 through the tilcai-core alias. Their repository CI access is configured; web access/integration remains deferred until the monitor is separated. No real partner credentials were issued during tests.
