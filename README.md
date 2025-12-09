# Valuing Construction Shocks: Housing Market Responses to the First Metro Line in Bogotá

Este repositorio contiene el código y los recursos para el Trabajo Final de Economía Urbana (TF_EU_STCH). El proyecto evalúa el efecto causal del inicio de la construcción de la Primera Línea del Metro de Bogotá (PLMB) sobre los precios de vivienda, utilizando un diseño de Diferencias en Diferencias (DID) con tratamiento escalonado y datos simulados calibrados al contexto de Bogotá.

## Descripción del Proyecto

El estudio simula un panel de datos a nivel de manzana para el periodo 2016-2026. Se explota la variación exógena generada por el cronograma de construcción de la PLMB para estimar el impacto en dos variables de resultado:
1.  **Precios de Oferta (Bid-Price):** Expectativas de los vendedores.
2.  **Precios de Transacción (Sale-Price):** Precios de cierre efectivos.

Para este trabajo se utilizan RStudio, Stata, y ArcGIS. R y ArcGIS se utilizan para la construcción espacial y simulación. Stata se utiliza para llevar a cabo la estimación econométrica. 

## Estructura del Repositorio

El proyecto se divide en tres scripts principales que deben ejecutarse en orden:

### 1. Construcción de la Base Espacial
*   **Script:** `1.limpieza.R`
*   **Descripción:** 
    *   Procesa los shapefiles de manzanas de Bogotá (2018).
    *   Cruza información con la caracterización poblacional de la Empresa Metro de Bogotá (EMB).
    *   Define el grupo de tratamiento (Área de Influencia), crea el insumo para la construcción del grupo de control mediante un *buffer* espacial en ArcGIS. 
    *   Se asigna el tratamiento escalonado (años 2021-2025) según los tramos de obra en ArcGIS. 
*   **Inputs:** Utiliza los datos en "data/raw": capa del área de influencia de la EMB, la capa a nivel manzana de catastro, y la capa de la línea de intervención de la PLMB
*   **Outputs:** Genera Shapefile "manzanas.shp", ubicado en "data/intermediate/R"


### 2. Simulación del Proceso Generador de Datos y Estimación
*   **Script:** `02.simulacion.R`
*   **Descripción:**
    *   Genera un panel de 11 años (2016-2026).
    *   Simula covariables (crimen y población) mediante caminatas aleatorias truncadas.
    *   Construye la estructura de error con autocorrelación espacial (UPZ) y temporal (AR1).
    *   Impone los Efectos de Tratamiento Promedio en los Tratados (ATT) dinámicos.
    *   **Estimación:** Realiza una estimación preliminar utilizando el estimador de Dobles Diferencias (TWFE) con el paquete `fixest`.
*   **Inputs:** Toma como base el shapefile "manzanas.shp"
*   **Outputs:** Genera Shapefile "simulación.shp", ubicado en "data/final"


### 3. Estimaciones
*   **Do-file:** `03.estimaciones.do`
*   **Descripción:**
    *   Utiliza los datos simulados para llevar a cabo las estimaciones de TWFE y estudio de eventos
    *   Genera las gráficas de resultados asociadas a las estimaciones principales. 
    *   Realiza las estimaciones de robustez (Callaway & Sant'Anna, Borusyak, Chaisemartin, Sun & Abraham)
*   **Inputs:** Toma como base la tabla de atributos "simulacion.dbf"
*   **Outputs:** Genera gráficas de resultados ubicadas en la carpeta "results"

### 4. Estadísticas Descriptivas y Gráficos
*   **Script:** `04.descriptivas.R`
*   **Descripción:**
    *   Genera visualizaciones para validar el diseño y los supuestos.
    *   Gráfica de evolución de precios (tendencias paralelas).
    *   Densidades de precios (balance pre-tratamiento).
    *   Histograma de asignación del tratamiento por año.
*   **Inputs:** Toma como base el archivo "simulacion.shp"
*   **Outputs:** Genera gráficas de estadísticas descriptivas ubicadas en la carpeta "results"

### Las capas y mapas generados a través de ArcGIS se encuentran en las carpetas "data/intermediate/ArcGIS" y "Results", respectivamente.

Autores:
María Corina Hernandez
Sara Valentina Torres
