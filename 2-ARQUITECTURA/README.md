# Arquitectura TilcAI: cómo leer estos dos documentos

1. **[Arquitectura propuesta](TILCAI_ARQUITECTURA_PROPUESTA_2026-10-06.html)** responde **qué construimos y por qué**. Es una explicación de producto para discutir con el equipo, comercios piloto y aliados: problema, capacidades, caso ilustrativo de cemento y posicionamiento. Los identificadores y cotizaciones de la simulación son ejemplos, no contratos de API.
2. **[Diagrama de arquitectura y flujo](TILCAI_DIAGRAMA_ARQUITECTURA_FLUJO_2026-10-07.html)** responde **cómo se construye y qué falta comprobar**. Reúne los diagramas de componentes, compra, onboarding/fondos y emisión SCA; la secuencia operativa; estados técnicos; dependencias; y casos de uso.

Los estados de implementación se contrastan con el [plan backend](../TILCAI_PLAN_ARQUITECTURA_BACKEND_INFRA_2026-10-02.md), el [plan SCA](../TILCAI_FASE_SCA_EMISION_DE_CUENTAS_2026-10-06.md) y los repositorios. **Preparación técnica** significa código base o interfaces con pruebas locales; no significa que la API ya emita cuentas ni que exista una compra comercial completa. La ruta CCTP Fuji → Stellar está verificada en testnet; las otras rutas del laboratorio no se presentan como integraciones operativas.

Las copias de `FASE-1/PRIMERA-PRESENTACION` sirven al material de la primera presentación. Mantienen el mismo contenido conceptual y enlaces ajustados a su ubicación. Al cambiar decisiones o estados, revisar ambas ubicaciones.
