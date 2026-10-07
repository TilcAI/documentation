---
title: TilcAI — primera presentación pública
date: 2026-10-02
status: memoria-de-presentacion
tags:
  - tilcai
  - presentacion
  - demo
  - comercio-agentico
  - whatsapp
  - x402
  - cctp
  - stellar
---

# TilcAI — primera presentación pública

**Fecha:** viernes 2 de octubre de 2026.  
**Registro:** relato de Omar sobre lo presentado por el equipo, redactado el 6 de octubre de 2026.  
**Alcance técnico de la demostración:** pruebas y transacciones en *testnet*; esta memoria no certifica despliegue en producción.

## Qué presentamos

Presentamos TilcAI como infraestructura para que agentes de usuarios y agentes de empresas coordinen consultas, reservas y compras con reglas y pagos verificables. El agente del usuario interpreta una intención —por ejemplo, comprar dos entradas de cine para una función determinada o veinte bolsas de cemento— y la convierte en una solicitud comercial. Del otro lado, el agente de la empresa atiende esa solicitud mediante un catálogo de productos y servicios, condiciones y disponibilidad. La propuesta contempla identidad, validación, reputación, políticas de gasto, autorización y pagos x402, con Stellar como red de liquidación. El objetivo es que la operación pueda reconstruirse desde la petición hasta su comprobante, sin conferir al agente control ilimitado del dinero.

También explicamos la posibilidad de financiar pagos con USDC desde otras redes y liquidarlos en Stellar mediante CCTP. El equipo mencionó una cobertura prevista de diez redes —entre ellas Avalanche, Base y Arbitrum—. La ruta que la documentación técnica disponible registra como implementada y verificada en testnet es **Avalanche Fuji → Stellar Testnet**; la mención de diez redes describe la amplitud planteada o explorada, no diez rutas demostradas durante esta presentación.

## Recorrido de la demo en vivo

1. Desde WhatsApp, el compañero dio la instrucción: **«Compra 50 bolsas de cemento»**. El canal ya tenía una API y un número de WhatsApp configurados mediante un proveedor externo.
2. El flujo interactuó con el relayer y presentó la petición de pago en WhatsApp.
3. La persona confirmó que quería pagar y abrió la página de confirmación del pago.
4. Tras confirmar en esa página, se ejecutó el pago.
5. Al volver a WhatsApp, llegó un comprobante en forma de sticker, un mensaje de pago y dos enlaces para verificar las transacciones de **Avalanche** y **Stellar**.

La presentación combinó la **app web**, el **ejemplo operado en vivo desde WhatsApp** y el **relayer en ejecución**. Según la observación del equipo, fue el único proyecto de pagos agénticos A2A presentado en esa instancia, y la combinación de esos tres elementos sorprendió a la audiencia. Este registro no pretende ser un inventario verificado de todos los proyectos participantes ni una medición formal de la reacción del público.

## Qué prueba el hito y qué queda por validar

| Aspecto | Estado al presentar |
| --- | --- |
| Solicitud de compra por WhatsApp, confirmación de pago y respuesta con comprobante | Demostrado en vivo según el relato del equipo. |
| Pago crosschain Avalanche Fuji → Stellar Testnet con USDC | Implementado y verificado en testnet según el plan técnico del 2 de octubre. |
| Relayer y facilitador x402 | Componentes utilizados o probados por el equipo; la documentación técnica distingue el pago x402 directo probado del flujo crosschain CCTP. |
| Agente comprador y agente empresarial con catálogo real y negociación A2A completa | Propuesta de producto presentada; esta demo por sí sola no demuestra una integración generalizada de ambos agentes. |
| Políticas financieras completas, identidad, reputación y permisos delegados revocables | Arquitectura y objetivos de TilcAI; no se deben describir como capacidades verificadas por esta única compra. |
| Pagos desde diez redes hacia Stellar | Cobertura mencionada por el equipo; conviene registrar y verificar cada ruta de forma individual. |

## Valoración del avance

El avance más valioso fue convertir una arquitectura difícil de explicar en un recorrido que cualquier persona puede seguir: pedir algo por WhatsApp, aprobar el pago y recibir pruebas que puede abrir por su cuenta en dos redes. Esto hizo tangible la interoperabilidad y mostró trabajo real de integración. El siguiente reto es convertir la demo vertical en un producto repetible: vincular una cotización auténtica y un pedido de la empresa con identidad, límites de gasto, aprobación de condiciones exactas, conciliación, manejo de fallos y comprobante de entrega. Esa diferencia entre **pago demostrado** y **compra agéntica completa** debe mantenerse clara en futuras presentaciones.

## Referencias y material asociado

La demostración utilizó una interfaz externa de confirmación; este resumen explica el flujo sin asociar la arquitectura de TilcAI a una marca.

- [Fork del OpenZeppelin Relayer del compañero](https://github.com/SaulChoque/openzeppelin-relayer).
- [Fork del plugin facilitador x402](https://github.com/SaulChoque/relayer-plugin-x402-facilitator).
- [Nuevo rumbo de comercio agéntico](../TILCAI_NUEVO_RUMBO_COMERCIO_AGENTICO_2026-09-29.md) — definición y visión de producto.
- [Plan de arquitectura backend e infraestructura](../TILCAI_PLAN_ARQUITECTURA_BACKEND_INFRA_2026-10-02.md) — estados técnicos y ruta Avalanche → Stellar verificada en testnet.

**Nota sobre fuentes:** los enlaces de los forks fueron proporcionados por Omar. No se pudo consultar su contenido mediante la herramienta web al redactar este archivo; los detalles del recorrido proceden de su testimonio y los estados técnicos se contrastaron con la documentación local del proyecto.
