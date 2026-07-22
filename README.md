# Proyecto Final - R Studio
## Análisis Exploratorio de Datos: Pobreza e ingresos de los hogares en el Perú

**Autor:** Huguito
**Curso:** R Studio
**Fecha de entrega:** 25 de julio de 2026

---

## 1. Contexto del conjunto de datos

- **Institución:** Instituto Nacional de Estadística e Informática (INEI), a través del
  [Portal de Microdatos](https://proyectos.inei.gob.pe/microdatos/).
- **Fuente:** Encuesta Nacional de Hogares (ENAHO) 2025, Módulo 34 "Sumaria".
- **Objetivo/temática:** la ENAHO permite dar seguimiento a las condiciones de vida de los
  hogares peruanos. El Módulo Sumaria resume, a nivel de hogar, los ingresos, gastos y la
  clasificación oficial de pobreza monetaria calculada por el INEI.
- **Principales variables:**

| Variable      | Descripción                                              |
|---------------|-----------------------------------------------------------|
| `ubigeo`      | Ubicación geográfica (departamento/provincia/distrito)    |
| `dominio`     | Dominio geográfico (Costa, Sierra, Selva, Lima Metrop.)   |
| `estrato`     | Estrato (urbano/rural)                                    |
| `mieperho`    | Número de miembros del hogar                              |
| `inghog2d`    | Ingreso monetario total del hogar (mensual, S/)            |
| `gashog2d`    | Gasto total del hogar (mensual, S/)                        |
| `pobreza`     | Condición de pobreza (1 pobre extremo, 2 pobre no extremo, 3 no pobre) |
| `factor07`    | Factor de expansión muestral                               |

## 2. Estructura del repositorio

```
Proyecto_Final/
│
├── data/                         # (Sumaria-2025.csv - no incluido por peso; ver nota abajo)
├── figures/
│   ├── collage_graficos.png      # collage con los graficos de la Parte 1
│   ├── g1_ingreso_pobreza.png
│   ├── g2_ingreso_junin.png
│   ├── g3_tamano_hogar.png
│   ├── g4_dominio.png
│   ├── g5_ingreso_gasto.png
│   └── 04_pobreza_tamano_hogar.png   # grafico de la Parte 2
├── scripts/
│   ├── EDA.R                     # Parte 1: importacion, limpieza, descriptivos, graficos
│   └── 04_analisis_final.R       # Parte 2: pregunta de analisis y conclusiones
└── README.md
```

> **Nota sobre `data/`:** el archivo `Sumaria-2025.csv` no se sube al repositorio por su
> peso y por buenas prácticas de manejo de datos abiertos. Se puede descargar directamente
> del portal de Microdatos del INEI (ENAHO 2025 → Anual → Módulo 34: Sumaria).

## 3. Cómo ejecutar el proyecto

1. Descargar `Sumaria-2025.csv` del portal de Microdatos del INEI y colocarlo en `data/`.
2. Ajustar la ruta `ruta_datos` al inicio de `scripts/EDA.R` y `scripts/04_analisis_final.R`.
3. Instalar los paquetes necesarios: `install.packages(c("tidyverse", "patchwork"))`.
4. Ejecutar `scripts/EDA.R` (Parte 1) y luego `scripts/04_analisis_final.R` (Parte 2).

---

## 4. Parte 2 — Pregunta de análisis

> **¿Existe una relación entre el tamaño del hogar y la probabilidad de que un hogar
> peruano sea clasificado en condición de pobreza monetaria?**

Este análisis parte de un hallazgo del EDA: fuerte dispersión en el tamaño del hogar y una
relación visible entre ingreso per cápita y pobreza.

### Resultados

- Correlación entre tamaño del hogar e ingreso per cápita: **-0.23** (relación negativa).
- Incidencia de pobreza según tamaño del hogar:

| Tamaño del hogar | % de hogares en pobreza |
|-------------------|--------------------------|
| 1-2 miembros       | 10.8%                    |
| 3-4 miembros       | 17.5%                    |
| 5-6 miembros       | 30.7%                    |
| 7+ miembros        | 45.9%                    |

### Conclusiones finales

- **Sí existe una relación clara** entre el tamaño del hogar y la pobreza monetaria en el
  Perú (ENAHO 2025): la incidencia de pobreza pasa de ~11% en hogares de 1-2 miembros a
  ~46% en hogares de 7 o más miembros.
- El ingreso total del hogar no se reparte de forma proporcional al número de miembros: los
  hogares numerosos quedan sistemáticamente en desventaja al medir el bienestar en términos
  per cápita, incluso si su ingreso total no es necesariamente el más bajo.
- **Implicancia:** los programas sociales dirigidos a hogares numerosos (5 o más miembros)
  podrían tener mayor costo-efectividad en la reducción de la pobreza monetaria, ya que es
  en ese segmento donde se concentra la mayor incidencia.

---

## 5. Difusión

Hallazgo publicado en LinkedIn/X con el gráfico `04_pobreza_tamano_hogar.png`
(`scripts/04_analisis_final.R`). Captura de la publicación adjunta en el repositorio.

## 6. Link del repositorio

`[completar con el link de GitHub una vez publicado]`
