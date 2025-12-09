# Valuing Construction Shocks: Housing Market Responses to the First Metro Line in Bogotá

Este repositorio contiene el código y los recursos para el Trabajo Final de Economía Urbana (TF_EU_STCH). El proyecto evalúa el efecto causal del inicio de la construcción de la Primera Línea del Metro de Bogotá (PLMB) sobre los precios de vivienda, utilizando un diseño de Diferencias en Diferencias (DID) con tratamiento escalonado y datos simulados calibrados al contexto de Bogotá.

## 📋 Descripción del Proyecto

El estudio simula un panel de datos a nivel de manzana para el periodo 2016-2026. Se explota la variación exógena generada por el cronograma de construcción de la PLMB para estimar el impacto en dos variables de resultado:
1.  **Precios de Oferta (Bid-Price):** Expectativas de los vendedores.
2.  **Precios de Transacción (Sale-Price):** Precios de cierre efectivos (panel desbalanceado).

Todo el flujo de trabajo, desde la construcción espacial hasta la estimación econométrica (TWFE), se realiza en **R**.

## 🗂️ Estructura del Repositorio

El proyecto se divide en tres scripts principales que deben ejecutarse en orden:

### 1. Construcción de la Base Espacial
*   **Script:** `01_creacion_base_manzanas.R`
*   **Descripción:** 
    *   Procesa los shapefiles de manzanas de Bogotá (2018).
    *   Cruza información con la caracterización poblacional de la Empresa Metro de Bogotá (EMB).
    *   Define el grupo de tratamiento (Área de Influencia) y construye el grupo de control mediante un *buffer* espacial.
    *   Asigna el tratamiento escalonado (años 2021-2025) según los tramos de obra.

### 2. Simulación del Proceso Generador de Datos y Estimación
*   **Script:** `02_simulacion_datos.R`
*   **Descripción:**
    *   Genera un panel balanceado de 11 años (2016-2026).
    *   Simula covariables (crimen y población) mediante caminatas aleatorias truncadas.
    *   Construye la estructura de error con autocorrelación espacial (UPZ) y temporal (AR1).
    *   Impone los Efectos de Tratamiento Promedio en los Tratados (ATT) dinámicos.
    *   **Estimación:** Realiza una estimación preliminar utilizando el estimador de Dobles Diferencias (TWFE) con el paquete `fixest`.

### 3. Estadísticas Descriptivas y Gráficos
*   **Script:** `03_estadisticas_descriptivas.R`
*   **Descripción:**
    *   Genera visualizaciones para validar el diseño y los supuestos.
    *   Gráfica de evolución de precios (tendencias paralelas).
    *   Densidades de precios (balance pre-tratamiento).
    *   Histograma de asignación del tratamiento por año.

Autores:
María Corina Hernandez
Sara Valentina Torres
