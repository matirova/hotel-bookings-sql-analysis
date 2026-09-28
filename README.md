#  Análisis Integral de Reservas Hoteleras & Revenue Management

Proyecto de análisis de datos orientado al negocio hotelero, diseñado para evaluar patrones de demanda, rendimiento financiero (ADR), segmentación de mercado y factores de riesgo de cancelación. El proyecto integra **SQL avanzado** para la extracción y transformación de datos con un **Dashboard Ejecutivo en Tableau** para la toma de decisiones estratégicas.

---

## Tecnologías y Herramientas
* **SQL:** Consultas complejas, CTEs, Funciones de Ventana (`ROW_NUMBER`), y lógica condicional avanzada (`CASE WHEN`).
* **Tableau Public:** Diseño de dashboard interactivo con enfoque "top-down" (tendencias temporales y palancas de negocio).
* **Documentación:** Informes ejecutivos y modelado de negocio.

---

## Estructura del Análisis (SQL)
El script SQL incluido en este repositorio (`hotel_bookings_analysis.sql`) aborda los siguientes ejes analíticos:
1. **Volumen de reservas y ADR por mes y hotel:** Análisis de estacionalidad y tarifa promedio.
2. **Top 10 semanas con mayor demanda:** Uso de funciones de ventana para identificar los periodos pico.
3. **Patrones de estancia:** Evaluación de noches de fin de semana vs. semana.
4. **Análisis de Riesgo por *Lead Time* (Anticipación):** Segmentación de plazos de reserva para identificar zonas críticas de cancelación.
5. **Rendimiento por Canal y Segmento de Mercado:** Identificación de los canales más rentables y de mayor volumen (ej. *Online TA*).
6. **Análisis de Cancelaciones y Tipos de Depósito:** Factores que incrementan la tasa de anulación de reservas.
7. **Composición Familiar y Solicitudes Especiales:** Clasificación de huéspedes mediante lógica condicional compleja.

---

## Dashboard Interactivo (Tableau Public)
El tablero consolida las métricas clave de negocio en una sola vista ejecutiva:
* **Flujos temporales:** Demanda mensual y semanal por tipo de hotel (*City Hotel* vs *Resort Hotel*).
* **Palancas de rendimiento:** ADR, tasa de cancelación por tipo de depósito y volumen por segmento de mercado.
* **Gestión de riesgos:** Curva de cancelaciones basada en el tiempo de anticipación (*Lead Time*).

 **[Explora el Dashboard en Vivo en Tableau Public]((https://public.tableau.com/views/DASHBOARHOTELBOOKINGS/Dashboard1?:language=es-ES&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link))**

---

##  Principales Insights de Negocio
* **Dominio del canal Online TA:** Representa el mayor volumen de reservas, requiriendo estrategias de fidelización específicas.
* **Riesgo crítico de cancelación:** Las reservas realizadas con más de 60 días de anticipación concentran el mayor volumen de cancelaciones, lo que sugiere la necesidad de políticas de depósitos más estrictas en ese segmento.
* **Comportamiento tarifario:** Se observan diferencias claras en el ADR y la tasa de cancelación entre los hoteles urbanos (*City*) y vacacionales (*Resort*).

---

