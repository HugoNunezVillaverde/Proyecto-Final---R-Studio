# =============================================================================
# PROYECTO FINAL - R STUDIO | PARTE 2
# Analisis final: tamano del hogar y pobreza monetaria
# Fuente: INEI - ENAHO 2025, Modulo Sumaria
# Autor: Hugo Raúl Nuñez Villaverde
# =============================================================================

library(tidyverse)

# -----------------------------------------------------------------------------
# 1. PREGUNTA DE ANALISIS
# -----------------------------------------------------------------------------
# Durante el EDA (EDA.R) se observo una fuerte dispersion en el tamano del
# hogar y una relacion visible entre ingreso per capita y pobreza. A partir
# de ese hallazgo se formula la siguiente pregunta:
#
#   ¿Existe una relacion entre el tamano del hogar y la probabilidad de que
#   un hogar peruano sea clasificado en condicion de pobreza monetaria?

# -----------------------------------------------------------------------------
# 2. Datos (mismo pipeline de limpieza que EDA.R)
# -----------------------------------------------------------------------------
ruta_datos <- "C:/Users/HUGO/Downloads/1031-Modulo34/1031-Modulo34/Sumaria-2025.csv"

datos <- read_delim(
  ruta_datos,
  delim = ";",
  locale = locale(encoding = "Latin1", decimal_mark = ","),
  col_types = cols(
    UBIGEO   = col_character(),
    CONGLOME = col_character(),
    VIVIENDA = col_character(),
    HOGAR    = col_character(),
    .default = col_guess()
  )
)
names(datos) <- tolower(names(datos))

datos_limpios <- datos %>%
  select(mieperho, inghog2d, pobreza) %>%
  rename(n_miembros = mieperho, ingreso_hog = inghog2d, pobreza_cod = pobreza) %>%
  mutate(
    pobreza_cat  = factor(pobreza_cod, levels = c(1, 2, 3),
                           labels = c("Pobre extremo", "Pobre no extremo", "No pobre")),
    es_pobre     = pobreza_cod %in% c(1, 2),
    ingreso_pc   = ingreso_hog / n_miembros,
    tam_hogar_cat = cut(n_miembros,
                         breaks = c(0, 2, 4, 6, Inf),
                         labels = c("1-2 miembros", "3-4 miembros",
                                    "5-6 miembros", "7+ miembros"))
  ) %>%
  filter(!is.na(ingreso_hog), ingreso_hog >= 0, n_miembros > 0) %>%
  filter(ingreso_pc <= quantile(ingreso_pc, 0.99, na.rm = TRUE))

# -----------------------------------------------------------------------------
# 3. ANALISIS DE LA RELACION
# -----------------------------------------------------------------------------
# 3.1 Correlacion entre tamano del hogar e ingreso per capita
correlacion <- cor(datos_limpios$n_miembros, datos_limpios$ingreso_pc)
cat("Correlacion tamano de hogar vs. ingreso per capita:", round(correlacion, 3), "\n")

# 3.2 Tabla: ingreso per capita promedio segun tamano de hogar
tabla_ingreso <- datos_limpios %>%
  group_by(tam_hogar_cat) %>%
  summarise(n_hogares = n(),
            ingreso_pc_prom = mean(ingreso_pc),
            ingreso_pc_mediana = median(ingreso_pc))
print(tabla_ingreso)

# 3.3 Tabla: porcentaje de hogares pobres segun tamano de hogar
tabla_pobreza_tam <- datos_limpios %>%
  group_by(tam_hogar_cat) %>%
  summarise(n_hogares = n(),
            pct_pobre = round(100 * mean(es_pobre), 1))
print(tabla_pobreza_tam)

# 3.4 Visualizacion adicional: % de hogares pobres segun tamano de hogar
g_final <- ggplot(tabla_pobreza_tam, aes(x = tam_hogar_cat, y = pct_pobre, fill = tam_hogar_cat)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(pct_pobre, "%")), vjust = -0.5, size = 4) +
  scale_fill_manual(values = c("1-2 miembros" = "#2E86C1", "3-4 miembros" = "#5DADE2",
                                "5-6 miembros" = "#E67E22", "7+ miembros" = "#B03A2E")) +
  labs(title = "A mayor tamano del hogar, mayor incidencia de pobreza",
       subtitle = "Porcentaje de hogares en condicion de pobreza monetaria segun numero de miembros",
       x = "Tamano del hogar", y = "Hogares en condicion de pobreza (%)",
       caption = "Fuente: INEI - ENAHO 2025, Modulo Sumaria") +
  ylim(0, max(tabla_pobreza_tam$pct_pobre) + 8) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey30"))

ggsave("figures/04_pobreza_tamano_hogar.png", g_final, width = 8, height = 5.5, dpi = 300)

# -----------------------------------------------------------------------------
# 4. CONCLUSIONES FINALES (VERSIÓN MEJORADA)
# -----------------------------------------------------------------------------
# 
# 4.1 Hallazgos cuantitativos principales
# ----------------------------------------
# - Correlación negativa moderada (-0.24) entre tamaño del hogar e ingreso per 
#   cápita: cada miembro adicional reduce en promedio el ingreso per cápita 
#   del hogar. Esta relación, aunque no causal, es sistemática y consistente 
#   con la literatura sobre "dilución del ingreso" en hogares numerosos.
#
# - Gradiente de pobreza claro y progresivo según tamaño del hogar:
#   * 1-2 miembros: 11.0% de pobreza (grupo de referencia)
#   * 3-4 miembros: 17.6% (+60% respecto al grupo anterior)
#   * 5-6 miembros: 30.7% (+74%) 
#   * 7+ miembros:  45.9% (+50%)
#   
#   La incidencia en hogares de 7+ miembros es 4.2 veces mayor que en hogares 
#   de 1-2 miembros, lo que evidencia un gradiente socioeconómico marcado.
#
# - Brecha de ingresos que se amplía con el tamaño del hogar:
#   El ingreso per cápita promedio de hogares de 7+ miembros (S/ 8,135) 
#   representa solo el 51.5% del ingreso de hogares de 1-2 miembros (S/ 15,788). 
#   Esta brecha es aún más notoria al comparar medianas: S/ 6,938 vs S/ 12,162 
#   (una diferencia del 43%).
#
# 4.2 Interpretación sustantiva de los resultados
# ------------------------------------------------
# Los hallazgos confirman que SÍ existe una relación clara y estadísticamente 
# relevante entre el tamaño del hogar y la pobreza monetaria en el Perú (ENAHO 2025).
# Esta relación se explica por tres mecanismos interrelacionados:
#
#   1. Efecto de composición demográfica: los hogares numerosos suelen tener 
#      una mayor proporción de niños y adultos mayores (menos miembros en edad 
#      de trabajar), lo que reduce la capacidad de generación de ingresos por 
#      persona dependiente.
#
#   2. Mercado laboral con empleos de baja productividad: el ingreso total del 
#      hogar no crece proporcionalmente con el número de miembros porque los 
#      empleos disponibles son predominantemente informales, de baja 
#      calificación y con ingresos que no cubren las necesidades básicas de 
#      todos los miembros.
#
#   3. Economías de escala limitadas en el consumo: a diferencia del gasto en 
#      vivienda o servicios (que sí presentan economías de escala), el gasto 
#      en alimentación, educación y salud crece casi linealmente con el número 
#      de miembros. Por ello, el ingreso per cápita resulta un mejor indicador 
#      del bienestar real que el ingreso total del hogar.
#
# 4.3 Implicancias para el diseño de políticas públicas
# ------------------------------------------------------
# a) Focalización con criterio de composición y carga demográfica:
#    Los programas de transferencias condicionadas (Juntos, Pensión 65, 
#    Cuna Más) deberían considerar no solo el ingreso per cápita, sino también 
#    el número de miembros dependientes (niños ≤12 años y adultos ≥65 años) 
#    al momento de calcular el monto de la transferencia o la elegibilidad.
#
# b) Intervenciones diferenciadas según estrato de tamaño del hogar:
#    * Hogares de 3-4 miembros (pobreza moderada, 17.6%): priorizar acceso 
#      a servicios de salud y educación de calidad, junto con programas de 
#      empleo temporal.
#    * Hogares de 5-6 miembros (pobreza alta, 30.7%): combinar transferencias 
#      monetarias con programas de nutrición infantil y capacitación laboral 
#      para jefes de hogar.
#    * Hogares de 7+ miembros (pobreza extrema funcional, 45.9%): requieren 
#      intervenciones integrales y multisectoriales que aborden:
#        - Transferencias monetarias de mayor cuantía (por su mayor necesidad)
#        - Acceso garantizado a servicios de salud y saneamiento básico
#        - Programas de planificación familiar con enfoque de derechos y 
#          autonomía de las mujeres
#        - Estrategias de generación de ingresos sostenibles (emprendimientos 
#          asociativos, acceso a crédito, formalización)
#
# c) Evaluación de costo-efectividad de las intervenciones:
#    Dado que la pobreza en hogares de 7+ miembros es 4 veces más alta que en 
#    hogares pequeños, cada punto porcentual de reducción de pobreza en estos 
#    hogares requerirá un esfuerzo presupuestal y operativo 
#    desproporcionalmente mayor. Esto implica:
#      - Asignación prioritaria de presupuesto a estos hogares
#      - Diseño de sistemas de monitoreo con indicadores de resultado 
#        (egreso de pobreza) y no solo de cobertura (número de beneficiarios)
#      - Articulación interinstitucional (MIDIS, MEF, MTPE, MINSA, MINEDU) 
#        para abordar la multidimensionalidad de la pobreza
#
# 4.4 Limitaciones del análisis y preguntas abiertas
# --------------------------------------------------
# Limitaciones:
# - El diseño transversal de la ENAHO no permite establecer relaciones 
#   causales (tamaño del hogar → pobreza). Es igualmente plausible que la 
#   pobreza genere hogares más numerosos como estrategia de supervivencia 
#   (ej. hijos como soporte en la vejez, o ampliación de la red familiar 
#   para compartir gastos).
# - No se controlaron variables de confusión clave: nivel educativo del jefe 
#   de hogar, zona de residencia (urbana/rural), presencia de adultos mayores, 
#   acceso a programas sociales, o calidad del empleo (formal/informal).
# - La variable "tamaño del hogar" es agregada y no distingue entre miembros 
#   dependientes y económicamente activos, lo que podría atenuar o exagerar 
#   el efecto estimado.
#
# Preguntas para investigaciones futuras:
# - ¿El efecto del tamaño del hogar sobre la pobreza es homogéneo en zonas 
#   urbanas y rurales, o se intensifica en algún ámbito geográfico?
# - ¿Existe un punto de inflexión (umbral crítico) a partir del cual el riesgo 
#   de pobreza se acelera exponencialmente (ej. a partir de 4 o 5 miembros)?
# - ¿Cómo interactúa el tamaño del hogar con el género del jefe de hogar, 
#   y qué implicancias tiene esto para el diseño de políticas con enfoque de 
#   género?
# - ¿Qué rol juega la informalidad laboral como mecanismo mediador entre el 
#   tamaño del hogar y la pobreza monetaria?
#
# 4.5 Recomendaciones para el reporte final y siguientes pasos
# -------------------------------------------------------------
# Para fortalecer el análisis y las conclusiones, se recomienda:
#
# 1. Incluir un gráfico de dispersión (n_miembros vs ingreso_pc) con línea 
#    de tendencia LOWESS para visualizar la relación no lineal entre ambas 
#    variables.
#
# 2. Estimar un modelo de regresión logística que cuantifique el aumento en 
#    la probabilidad de pobreza por cada miembro adicional en el hogar, 
#    controlando por variables como zona (urbana/rural), educación del jefe 
#    de hogar, y presencia de dependientes.
#
# 3. Realizar un análisis de heterogeneidad: estratificar la muestra por 
#    zona geográfica (urbana/rural) y por cuartiles de ingreso para evaluar 
#    si el efecto del tamaño del hogar varía en diferentes contextos.
#
# 4. Incluir en el anexo del reporte un análisis descriptivo adicional sobre 
#    la composición de los hogares numerosos (proporción de niños, adultos 
#    mayores, mujeres jefas de hogar) para contextualizar mejor los hallazgos.
#
# 5. Complementar el análisis con datos cualitativos (si estuvieran 
#    disponibles) para entender las estrategias de supervivencia de los 
#    hogares numerosos en situación de pobreza.
#
# 6. Finalmente, elaborar un resumen ejecutivo (máximo 300 palabras) que 
#    sintetice los hallazgos, su relevancia para políticas públicas, y las 
#    recomendaciones principales, dirigido a tomadores de decisión en el 
#    MIDIS y el MEF.
#
# -----------------------------------------------------------------------------
# FIN DEL ANÁLISIS
# -----------------------------------------------------------------------------
