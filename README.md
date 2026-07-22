# Pobreza e ingresos de los hogares en el Perú: un Análisis Exploratorio de Datos con ENAHO 2025

**Proyecto Final — Curso R Studio**
**Autor:** Huguito

---

## Resumen

Este proyecto desarrolla un Análisis Exploratorio de Datos (EDA) sobre las condiciones de
ingreso, gasto y pobreza monetaria de los hogares peruanos, utilizando el Módulo Sumaria de
la Encuesta Nacional de Hogares (ENAHO) 2025 del INEI. Se documenta el proceso de
importación y limpieza de los datos, se presentan estadísticas descriptivas y visualizaciones,
y se profundiza en una relación específica identificada durante el EDA: la asociación entre
el tamaño del hogar y la incidencia de pobreza monetaria.

---

## 1. Introducción y contexto del conjunto de datos

- **Institución que proporciona los datos:** Instituto Nacional de Estadística e Informática
  (INEI), a través del [Portal de Microdatos](https://proyectos.inei.gob.pe/microdatos/).
- **Fuente:** Encuesta Nacional de Hogares (ENAHO) 2025, Módulo 34 "Sumaria".
- **Objetivo y temática:** la ENAHO da seguimiento periódico a las condiciones de vida de los
  hogares peruanos. El Módulo Sumaria resume, a nivel de hogar, los ingresos, los gastos y la
  clasificación oficial de pobreza monetaria calculada por el INEI, lo que permite analizar el
  bienestar económico de los hogares y sus determinantes.

**Variables analizadas:**

| Variable      | Descripción                                                              |
|---------------|---------------------------------------------------------------------------|
| `ubigeo`      | Ubicación geográfica (departamento/provincia/distrito)                    |
| `dominio`     | Dominio geográfico (Costa, Sierra, Selva, Lima Metropolitana)              |
| `estrato`     | Estrato (urbano/rural)                                                    |
| `mieperho`    | Número de miembros del hogar                                              |
| `inghog2d`    | Ingreso monetario total del hogar (mensual, S/)                            |
| `gashog2d`    | Gasto total del hogar (mensual, S/)                                        |
| `pobreza`     | Condición de pobreza (1 = pobre extremo, 2 = pobre no extremo, 3 = no pobre) |
| `factor07`    | Factor de expansión muestral                                              |

---

## 2. Metodología

### 2.1 Importación de datos

El archivo `Sumaria-2025.csv` es leído en R con `read_delim()`. Se identificaron tres
particularidades propias del formato de entrega del INEI que debieron corregirse para una
lectura correcta: el separador de campos es punto y coma (`;`), la codificación de caracteres
es Latin1, y los decimales están separados por coma en lugar de punto. Adicionalmente, la
variable `ubigeo` se importa como texto para preservar los ceros a la izquierda de los
códigos geográficos.

### 2.2 Limpieza y preparación

Sobre la base importada se realizaron las siguientes transformaciones (`scripts/EDA.R`):

- Selección de las variables relevantes y renombramiento a nombres más descriptivos
  (`n_miembros`, `ingreso_hog`, `gasto_hog`, `pobreza_cod`).
- Creación de variables derivadas: `departamento` (extraído de `ubigeo`), `es_junin`
  (comparación Junín vs. resto del país), `pobreza_cat` y `dominio_cat` (versiones etiquetadas
  de los códigos numéricos), `area` (urbano/rural a partir del estrato), `ingreso_pc` (ingreso
  per cápita del hogar) y `tam_hogar_cat` (tamaño de hogar agrupado en cuatro categorías).
- Filtrado de observaciones con ingreso negativo o tamaño de hogar inválido, y recorte del 1%
  superior de ingreso per cápita únicamente para fines de visualización.

### 2.3 Estadísticas descriptivas

Se calcularon estadísticos de resumen (media, mediana, mínimo, máximo) para el tamaño del
hogar, el ingreso y el gasto del hogar, además de tablas de frecuencia por condición de
pobreza, por área urbano/rural y por dominio geográfico.

### 2.4 Visualización

Se construyeron cinco gráficos con `ggplot2`, cada uno con título, subtítulo, etiquetas de
ejes, leyenda (cuando corresponde) y tema visual homogéneo, guardados individualmente en
`figures/` y combinados en `figures/collage_graficos.png`:

1. Distribución del ingreso per cápita según condición de pobreza (boxplot).
2. Ingreso per cápita promedio en Junín frente al resto del país, por área (barras).
3. Distribución del tamaño del hogar (histograma).
4. Número de hogares encuestados por dominio geográfico (barras horizontales).
5. Relación entre ingreso y gasto del hogar, coloreada por condición de pobreza (dispersión).

---

## 3. Resultados del EDA

- La condición de pobreza está claramente asociada al nivel de ingreso per cápita: los
  hogares clasificados como "pobres extremos" presentan ingresos sensiblemente menores y con
  menor dispersión que los hogares "no pobres".
- El ingreso per cápita promedio en Junín es menor al del resto del país, tanto en el ámbito
  urbano como en el rural.
- El tamaño del hogar muestra una dispersión considerable, con una concentración importante en
  hogares de 1 a 4 miembros y una cola de hogares más numerosos.
- Los dominios geográficos presentan un número desigual de hogares encuestados, reflejando el
  diseño muestral de la ENAHO.
- Se observa una relación positiva esperada entre ingreso y gasto del hogar, con los hogares
  "no pobres" ubicados sistemáticamente en la parte superior derecha del gráfico de dispersión.

Este último patrón —junto con la alta dispersión del tamaño del hogar— motivó profundizar en
la relación entre tamaño del hogar y pobreza en la segunda parte del proyecto.

---

## 4. Parte 2 — Análisis final

### 4.1 Pregunta de análisis

> **¿Existe una relación entre el tamaño del hogar y la probabilidad de que un hogar peruano
> sea clasificado en condición de pobreza monetaria?**

### 4.2 Análisis de la relación

Se calculó la correlación entre el número de miembros del hogar y el ingreso per cápita, y se
construyeron tablas e indicadores de incidencia de pobreza según tamaño del hogar
(`scripts/04_analisis_final.R`):

- **Correlación entre tamaño del hogar e ingreso per cápita:** -0.23 (relación negativa).
- **Incidencia de pobreza según tamaño del hogar:**

| Tamaño del hogar | % de hogares en pobreza |
|-------------------|--------------------------|
| 1-2 miembros       | 10.8%                    |
| 3-4 miembros       | 17.5%                    |
| 5-6 miembros       | 30.7%                    |
| 7+ miembros        | 45.9%                    |

Estos resultados se sintetizan en el gráfico `figures/04_pobreza_tamano_hogar.png`, que
muestra el porcentaje de hogares pobres en función del tamaño del hogar.

### 4.3 Discusión

El ingreso total del hogar no se reparte de forma proporcional al número de miembros: dos
hogares con ingresos totales similares pueden tener niveles de bienestar muy distintos si uno
de ellos tiene el doble de integrantes. Esto explica por qué el tamaño del hogar está asociado
negativamente con el ingreso per cápita, y por qué la incidencia de pobreza —definida a partir
de umbrales per cápita— se concentra de forma tan marcada en los hogares numerosos.

---

## 5. Conclusiones

- **Sí existe una relación clara** entre el tamaño del hogar y la pobreza monetaria en el
  Perú (ENAHO 2025): la incidencia de pobreza pasa de aproximadamente 11% en hogares de 1-2
  miembros a cerca de 46% en hogares de 7 o más miembros.
- Los hogares numerosos quedan sistemáticamente en desventaja al medir el bienestar en
  términos per cápita, incluso cuando su ingreso total no es necesariamente el más bajo.
- Junín se ubica por debajo del promedio nacional en ingreso per cápita, lo que sugiere que la
  combinación de hogares numerosos y menores ingresos regionales podría agravar la incidencia
  de pobreza en esta zona en particular.
- **Implicancia de política:** los programas sociales dirigidos a hogares numerosos (5 o más
  miembros) podrían tener mayor costo-efectividad en la reducción de la pobreza monetaria, ya
  que es en ese segmento donde se concentra la mayor incidencia.

---

## 6. Estructura del repositorio

```
Proyecto_Final/
│
├── data/                         # Sumaria-2025.csv (no incluido por peso; ver nota abajo)
├── figures/
│   ├── collage_graficos.png      # collage con los gráficos de la Parte 1
│   ├── g1_ingreso_pobreza.png
│   ├── g2_ingreso_junin.png
│   ├── g3_tamano_hogar.png
│   ├── g4_dominio.png
│   ├── g5_ingreso_gasto.png
│   └── 04_pobreza_tamano_hogar.png   # gráfico de la Parte 2
├── scripts/
│   ├── EDA.R                     # Parte 1: importación, limpieza, descriptivos, gráficos
│   └── 04_analisis_final.R       # Parte 2: pregunta de análisis y conclusiones
└── README.md
```

> **Nota sobre `data/`:** el archivo `Sumaria-2025.csv` no se incluye en el repositorio por su
> peso y por buenas prácticas de manejo de datos abiertos. Puede descargarse directamente del
> portal de Microdatos del INEI (ENAHO 2025 → Anual → Módulo 34: Sumaria).

### Cómo ejecutar el proyecto

1. Descargar `Sumaria-2025.csv` del portal de Microdatos del INEI y colocarlo en `data/`.
2. Ajustar la ruta `ruta_datos` al inicio de `scripts/EDA.R` y `scripts/04_analisis_final.R`.
3. Instalar los paquetes necesarios: `install.packages(c("tidyverse", "patchwork"))`.
4. Ejecutar `scripts/EDA.R` (Parte 1) y luego `scripts/04_analisis_final.R` (Parte 2).
