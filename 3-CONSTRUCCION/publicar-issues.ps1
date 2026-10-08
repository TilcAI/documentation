# Publica las diez issues NUEVAS del backlog, una sola vez por ID.
# Requiere gh auth login con permiso de escritura en los repos de TilcAI.
# No modifica las issues ya abiertas ni sus responsables.
[CmdletBinding()]
param([switch]$Preview)

$ErrorActionPreference = 'Stop'
$backlogPath = Join-Path $PSScriptRoot 'ISSUES_PROPUESTAS_2026-10-08.md'
$backlog = Get-Content -LiteralPath $backlogPath -Raw -Encoding UTF8

$items = @(
  @{ Id='TIL-02'; Repo='TilcAI/tilcai-infrastructure'; Title='Agente vendedor piloto y cotización verificable'; Assignee='JHAMILCALI'; Priority='P0'; Dependencies='tilcai-core#3' }
  @{ Id='TIL-03'; Repo='TilcAI/tilcai-infrastructure'; Title='Orden persistente, política y aprobación exacta'; Assignee='joseemen11'; Priority='P0'; Dependencies='TIL-02, tilcai-core#6' }
  @{ Id='TIL-04'; Repo='TilcAI/tilcai-infrastructure'; Title='Vincular orden aprobada al pago CCTP Fuji → Stellar'; Assignee='SaulChoque'; Priority='P0'; Dependencies='TIL-03, infraestructura#3–5' }
  @{ Id='TIL-05'; Repo='TilcAI/tilcai-infrastructure'; Title='Conciliación y recibos coherentes para comprador y negocio'; Assignee='JHAMILCALI'; Priority='P0'; Dependencies='TIL-03, TIL-04' }
  @{ Id='TIL-06'; Repo='TilcAI/tilcai-infrastructure'; Title='Adaptador WhatsApp para el flujo común de compra'; Assignee='SaulChoque'; Priority='P0'; Dependencies='contrato v1; acceso al canal usado en la demo' }
  @{ Id='TIL-07'; Repo='TilcAI/tilcai-web'; Title='Relato web de la operación y evidencia real de testnet'; Assignee='OmarQV'; Priority='P0'; Dependencies='contrato v1, TIL-05; coordinar con tilcai-web#9' }
  @{ Id='TIL-08'; Repo='TilcAI/tilcai-infrastructure'; Title='Demo comercial testnet reproducible por otro integrante'; Assignee='OmarQV'; Priority='P0'; Dependencies='TIL-02 a TIL-07; QA infraestructura#4 y #10' }
  @{ Id='TIL-10'; Repo='TilcAI/tilcai-infrastructure'; Title='Emisión Stellar desde enlace seguro iniciado en chat'; Assignee='joseemen11'; Priority='P1'; Dependencies='infraestructura#6–9, #11–12' }
  @{ Id='TIL-12'; Repo='TilcAI/tilcai-infrastructure'; Title='Servidor MCP comprador sobre servicios comunes'; Assignee='OmarQV'; Priority='P1'; Dependencies='tilcai-core#1–3, TIL-03' }
  @{ Id='TIL-14'; Repo='TilcAI/tilcai-infrastructure'; Title='Segunda red de origen CCTP con prueba E2E'; Assignee='SaulChoque'; Priority='P1'; Dependencies='TIL-04, TIL-05' }
)

if (-not $Preview) {
  if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'No se encontró GitHub CLI (gh).' }
  & gh auth status 1>$null
  if ($LASTEXITCODE -ne 0) { throw 'gh no está autenticado. Ejecuta gh auth login antes de publicar.' }
}

foreach ($item in $items) {
  $pattern = '(?ms)^### ' + [regex]::Escape($item.Id) + '\b[^\r\n]*\r?\n(.*?)(?=^### TIL-|^## |\z)'
  $match = [regex]::Match($backlog, $pattern)
  if (-not $match.Success) { throw "No se encontró el detalle de $($item.Id) en el backlog." }
  $detail = $match.Groups[1].Value.Trim()
  $title = "[$($item.Id)][$($item.Priority)] $($item.Title)"
  $body = @"
## Objetivo y aceptación

$detail

## Coordinación

- Prioridad: $($item.Priority).
- Dependencias: $($item.Dependencies).
- Referencia de proyecto: documentación TilcAI, `3-CONSTRUCCION/ISSUES_PROPUESTAS_2026-10-08.md`.
- Trabajo existente: conservar sus issues y responsables; esta issue cubre la integración descrita arriba.
- Evidencia para cerrar: tests aplicables, PR y demo reproducible o hashes de testnet cuando haya pago.
"@
  if ($Preview) {
    Write-Output "$($item.Repo) | $($item.Assignee) | $title"
    continue
  }

  $found = & gh issue list --repo $item.Repo --state all --search $item.Id --json title,url --limit 100 | ConvertFrom-Json
  if ($LASTEXITCODE -ne 0) { throw "No se pudieron consultar issues de $($item.Repo)." }
  $same = @($found | Where-Object { $_.title.StartsWith("[$($item.Id)]") })
  if ($same.Count -gt 0) {
    Write-Output "EXISTE $($item.Id): $($same[0].url)"
    continue
  }

  $bodyFile = [System.IO.Path]::GetTempFileName()
  try {
    [System.IO.File]::WriteAllText($bodyFile, $body, [System.Text.UTF8Encoding]::new($false))
    $url = & gh issue create --repo $item.Repo --title $title --assignee $item.Assignee --body-file $bodyFile
    if ($LASTEXITCODE -ne 0) { throw "Falló la creación de $($item.Id)." }
    Write-Output "CREADA $($item.Id): $url"
  }
  finally {
    Remove-Item -LiteralPath $bodyFile -ErrorAction SilentlyContinue
  }
}
