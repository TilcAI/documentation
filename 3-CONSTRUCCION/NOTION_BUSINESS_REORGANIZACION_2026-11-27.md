# Business Notion: organización y reutilización de bloques

Fecha: 2026-11-27. Trabajo realizado y verificado mediante notion_business_docs; sincronización del plan también verificada en notion_dev_docs. No modifica aplicaciones ni capacidades Solana.

## Resultado

Se incorporaron los requisitos de SCA Solana, rampa BOB→USDC, x402 y crosschain al Business existente. Se actualizaron 14 bloques de cinco páginas, se aprovecharon dos párrafos vacíos y se renombraron cuatro páginas. Las cinco páginas conservan exactamente los mismos IDs de bloques directos y la misma cantidad de bloques/subpáginas/tablas. No hubo creación, eliminación o traslado de páginas ni eliminación de bloques.

| Página | Organización y contenido | Bloques antes/después |
|---|---|---|
| [TilcAI · Producto y negocio](https://www.notion.so/3e2f83931c2d809b83b7df3a338fbd5d) | Portada vigente, antecedente Reputable y navegación entre producto, técnico y negocio; un párrafo vacío reutilizado | 5/5 |
| [Capacidades y roadmap](https://www.notion.so/3e2f83931c2d803aac5df8d307c5d920) | Cuatro prioridades Solana, secuencia/aceptación y antecedentes; un párrafo vacío reutilizado | 6/6 |
| [Arquitectura · referencia técnica](https://www.notion.so/3e2f83931c2d80839666ec35b1ae172a) | Índice hacia Dev Docs; listas históricas EVM/Stellar conservadas e identificadas como antecedentes | 4/4 |
| [Negocio · expedientes y validación](https://www.notion.so/410f83931c2d8018934dd26bb63a65d8) | Índice que conecta formularios, modelos e Instawards con el producto | 4/4 |
| [03 Roadmap de producto y sprint](https://www.notion.so/b53f83931c2d833aaa3a01b7bc37c764) | Nota de enlace al roadmap Solana; conserva SOW, D1/D2/D3, exclusiones y presupuesto | 30/30 |

## Coherencia de información

Business reúne requisitos, decisiones pendientes y aceptación; [Dev Docs](https://www.notion.so/41c2dc79a42581668b99c10fe454793c) mantiene arquitectura, APIs, pruebas y operación. El [plan técnico Solana](https://www.notion.so/4252dc79a4258163b1c7d34e3f71a5b6) enlaza ahora los requisitos Business publicados.

Las cuatro capacidades son planificación. Su aceptación exige misma SCA, evidencia de fondeo BOB/USDC, autorización real x402, crosschain conciliado y revocación efectiva. Las capacidades históricas Reputable Badge, Yellowmeter/crédito y batching se conservaron como antecedentes, sin presentarlas como implementación acreditada. No se modificaron los compromisos de Instawards al incorporar el roadmap general.

## Límite de cuota

[La documentación oficial de Notion](https://www.notion.com/help/understanding-block-usage) indica que borrar bloques o vaciar la papelera no reduce el contador después de alcanzar el límite. Por tanto, esta tarea no liberó cuota de creación. La solución aplicada usa edición de los bloques existentes, que Notion permite bajo esa restricción; no requiere eliminar información ni cambiar miembros o facturación. Crear páginas o bloques adicionales sigue sujeto al límite del espacio.

## Evidencia y límites

La lectura posterior de las cinco páginas confirmó cantidades, orden e IDs directos idénticos antes/después. Se conservaron tres subpáginas en la portada, dos listas con hijos en la referencia técnica, tres subpáginas de negocio y cuatro tablas del roadmap Instawards. Lectura Markdown completa de Capacidades y roadmap confirmó las cuatro prioridades, aceptación y antecedentes. La portada contiene subpáginas que el endpoint Markdown representa como unknown: se verificaron mediante lectura estructurada, sin reemplazar la página completa.

Se verificaron los cuatro títulos nuevos y la actualización remota del plan Dev Docs. No se leyó ni modificó el contenido de Test Accounts, ni se eliminaron plantillas, expedientes o tablas. La cantidad de bloques de todo el espacio y su facturación no fueron consultadas: solo se dispone del rechazo previo de creación por cuota y de la regla oficial.

[Instantánea previa de los bloques relevantes](NOTION_BUSINESS_REORGANIZACION_2026-11-27.json): permite consultar el texto anterior de producto, navegación y referencia técnica, sin incluir credenciales, Test Accounts o datos personales de expedientes. README y metadatos locales del plan se actualizaron para reflejar que Business ya está sincronizado.
