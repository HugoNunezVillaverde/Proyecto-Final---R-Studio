# =============================================================================
# PROYECTO FINAL - R STUDIO
# Analisis Exploratorio de Datos (EDA)
# Pobreza e ingresos de los hogares en el Peru - ENAHO 2025, Modulo Sumaria
# Fuente: INEI - Instituto Nacional de Estadistica e Informatica
# Autor: Hugo Raúl Nuñez Villaverde
# =============================================================================

# -----------------------------------------------------------------------------
# 0. Librerias
# -----------------------------------------------------------------------------
library(tidyverse)
library(patchwork)  # para armar el collage de graficos

# -----------------------------------------------------------------------------
# 1. CONTEXTO DEL CONJUNTO DE DATOS
# -----------------------------------------------------------------------------
# Institucion: Instituto Nacional de Estadistica e Informatica (INEI)
#   Portal de Microdatos: https://proyectos.inei.gob.pe/microdatos/
# Fuente: Encuesta Nacional de Hogares (ENAHO) 2025, Modulo 34 "Sumaria"
# Objetivo/tematica: la ENAHO permite dar seguimiento a las condiciones de vida
#   de los hogares peruanos. El Modulo Sumaria resume, a nivel de hogar, los
#   ingresos, gastos y la clasificacion oficial de pobreza monetaria del INEI.
# Principales variables analizadas:
#   conglome, vivienda, hogar : identificadores del hogar
#   ubigeo, dominio, estrato  : ubicacion geografica y ambito urbano/rural
#   mieperho                  : numero de miembros del hogar
#   inghog2d                  : ingreso monetario total del hogar (mensual, S/)
#   gashog2d                  : gasto total del hogar (mensual, S/)
#   pobreza                   : condicion de pobreza (1 pobre extremo,
#                                2 pobre no extremo, 3 no pobre)
#   factor07                  : factor de expansion muestral

# -----------------------------------------------------------------------------
# 2. IMPORTACION DE DATOS
# -----------------------------------------------------------------------------
# El archivo de INEI viene delimitado por ";", en codificacion Latin1 y con
# los numeros decimales separados por coma (formato regional europeo/INEI).

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

# El INEI entrega los nombres de columna en mayusculas; se estandarizan
names(datos) <- tolower(names(datos))

glimpse(datos)

# -----------------------------------------------------------------------------
# 3. LIMPIEZA Y PREPARACION
# -----------------------------------------------------------------------------
datos_limpios <- datos %>%
  select(conglome, vivienda, hogar, ubigeo, dominio, estrato,
         mieperho, inghog2d, gashog2d, pobreza, factor07) %>%
  rename(
    n_miembros  = mieperho,
    ingreso_hog = inghog2d,
    gasto_hog   = gashog2d,
    pobreza_cod = pobreza
  ) %>%
  mutate(
    departamento = str_sub(ubigeo, 1, 2),
    es_junin     = if_else(departamento == "12", "Junin", "Resto del pais"),
    pobreza_cat  = factor(pobreza_cod,
                           levels = c(1, 2, 3),
                           labels = c("Pobre extremo", "Pobre no extremo", "No pobre")),
    dominio_cat  = factor(dominio,
                           levels = 1:8,
                           labels = c("Costa Norte", "Costa Centro", "Costa Sur",
                                      "Sierra Norte", "Sierra Centro", "Sierra Sur",
                                      "Selva", "Lima Metropolitana")),
    area         = if_else(estrato %in% c(1, 2, 3, 4, 5), "Urbano", "Rural"),
    ingreso_pc   = ingreso_hog / n_miembros,
    tam_hogar_cat = cut(n_miembros,
                         breaks = c(0, 2, 4, 6, Inf),
                         labels = c("1-2 miembros", "3-4 miembros",
                                    "5-6 miembros", "7+ miembros"))
  ) %>%
  filter(!is.na(ingreso_hog), ingreso_hog >= 0, n_miembros > 0) %>%
  # se recorta el 1% superior de ingreso per capita solo para fines de
  # visualizacion (no se elimina de las tablas de estadisticas descriptivas)
  filter(ingreso_pc <= quantile(ingreso_pc, 0.99, na.rm = TRUE))

glimpse(datos_limpios)

# -----------------------------------------------------------------------------
# 4. ESTADISTICAS DESCRIPTIVAS
# -----------------------------------------------------------------------------
# Resumen general
summary(datos_limpios %>% select(n_miembros, ingreso_hog, gasto_hog, ingreso_pc))

# Distribucion de hogares por condicion de pobreza
tabla_pobreza <- datos_limpios %>%
  count(pobreza_cat) %>%
  mutate(porcentaje = round(100 * n / sum(n), 1))
print(tabla_pobreza)

# Ingreso per capita promedio: Junin vs. resto del pais
tabla_junin <- datos_limpios %>%
  group_by(es_junin) %>%
  summarise(
    n_hogares       = n(),
    ingreso_pc_prom = mean(ingreso_pc, na.rm = TRUE),
    ingreso_pc_med  = median(ingreso_pc, na.rm = TRUE),
    tam_hogar_prom  = mean(n_miembros, na.rm = TRUE)
  )
print(tabla_junin)

# Pobreza por area urbano/rural
tabla_area <- datos_limpios %>%
  count(area, pobreza_cat) %>%
  group_by(area) %>%
  mutate(porcentaje = round(100 * n / sum(n), 1))
print(tabla_area)

# Hogares por dominio geografico
tabla_dominio <- datos_limpios %>%
  count(dominio_cat, sort = TRUE)
print(tabla_dominio)

# -----------------------------------------------------------------------------
# 5. VISUALIZACION DE DATOS
# -----------------------------------------------------------------------------
tema_proyecto <- theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        plot.subtitle = element_text(color = "grey30"))

# Grafico 1: Ingreso per capita segun condicion de pobreza
g1 <- ggplot(datos_limpios, aes(x = pobreza_cat, y = ingreso_pc, fill = pobreza_cat)) +
  geom_boxplot(show.legend = FALSE, outlier.alpha = 0.3) +
  scale_fill_manual(values = c("Pobre extremo" = "#B03A2E",
                                "Pobre no extremo" = "#E67E22",
                                "No pobre" = "#2E86C1")) +
  labs(title = "Ingreso per capita segun condicion de pobreza",
       subtitle = "ENAHO 2025, Modulo Sumaria",
       x = "Condicion de pobreza", y = "Ingreso per capita (S/ mensual)",
       caption = "Fuente: INEI - ENAHO 2025") +
  tema_proyecto

# Grafico 2: Ingreso per capita promedio por area (Junin vs. resto del pais)
datos_g2 <- datos_limpios %>%
  group_by(es_junin, area) %>%
  summarise(ingreso_pc_prom = mean(ingreso_pc, na.rm = TRUE), .groups = "drop")

g2 <- ggplot(datos_g2, aes(x = area, y = ingreso_pc_prom, fill = es_junin)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  scale_fill_manual(values = c("Junin" = "#1F618D", "Resto del pais" = "#AAB7B8"),
                     name = "Ambito") +
  labs(title = "Ingreso per capita promedio segun area de residencia",
       subtitle = "Comparacion entre Junin y el resto del pais, ENAHO 2025",
       x = "Area", y = "Ingreso per capita promedio (S/ mensual)",
       caption = "Fuente: INEI - ENAHO 2025") +
  tema_proyecto +
  theme(legend.position = "top")

# Grafico 3: Distribucion del tamano del hogar
g3 <- ggplot(datos_limpios, aes(x = n_miembros)) +
  geom_histogram(binwidth = 1, fill = "#5B2C6F", color = "white") +
  labs(title = "Distribucion del tamano del hogar",
       subtitle = "Numero de miembros por hogar, ENAHO 2025",
       x = "Numero de miembros del hogar", y = "Numero de hogares",
       caption = "Fuente: INEI - ENAHO 2025") +
  tema_proyecto

# Grafico 4: Hogares por dominio geografico
g4 <- datos_limpios %>%
  count(dominio_cat) %>%
  ggplot(aes(x = fct_reorder(dominio_cat, n), y = n, fill = dominio_cat)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(title = "Numero de hogares encuestados por dominio geografico",
       subtitle = "ENAHO 2025, Modulo Sumaria",
       x = "Dominio geografico", y = "Numero de hogares",
       caption = "Fuente: INEI - ENAHO 2025") +
  tema_proyecto

# Grafico 5: Relacion entre ingreso y gasto del hogar, segun pobreza
g5 <- ggplot(datos_limpios, aes(x = ingreso_hog, y = gasto_hog, color = pobreza_cat)) +
  geom_point(alpha = 0.25, size = 1) +
  scale_color_manual(values = c("Pobre extremo" = "#B03A2E",
                                 "Pobre no extremo" = "#E67E22",
                                 "No pobre" = "#2E86C1"),
                      name = "Condicion de pobreza") +
  labs(title = "Relacion entre ingreso y gasto del hogar",
       subtitle = "ENAHO 2025, Modulo Sumaria",
       x = "Ingreso total del hogar (S/ mensual)",
       y = "Gasto total del hogar (S/ mensual)",
       caption = "Fuente: INEI - ENAHO 2025") +
  tema_proyecto +
  theme(legend.position = "bottom")

# Crear el directorio figures si no existe
if(!dir.exists("figures")) {
  dir.create("figures")
}

# Guardar cada gráfico por separado en figures/
ggsave("figures/g1_ingreso_pobreza.png", g1, width = 7, height = 5, dpi = 300)
ggsave("figures/g2_ingreso_junin.png",   g2, width = 7, height = 5, dpi = 300)
ggsave("figures/g3_tamano_hogar.png",    g3, width = 7, height = 5, dpi = 300)
ggsave("figures/g4_dominio.png",         g4, width = 7, height = 5, dpi = 300)
ggsave("figures/g5_ingreso_gasto.png",   g5, width = 7, height = 5, dpi = 300)

# Collage con todos los graficos
collage <- (g1 | g2) / (g3 | g4) / g5 +
  plot_annotation(
    title = "EDA - Pobreza e ingresos de los hogares en el Peru (ENAHO 2025)",
    theme = theme(plot.title = element_text(face = "bold", size = 14))
  )

ggsave("figures/collage_graficos.png", collage, width = 12, height = 14, dpi = 300)

# -----------------------------------------------------------------------------
# Conclusiones preliminares del EDA
# -----------------------------------------------------------------------------
# - Existe una relacion clara entre la condicion de pobreza y el ingreso per
#   capita del hogar: los hogares "pobres extremos" tienen ingresos muy por
#   debajo de los hogares "no pobres".
# - Junin muestra un ingreso per capita promedio menor al del resto del pais.
# - Se observa una fuerte dispersion en el tamano del hogar, lo cual motiva
#   el analisis de la Parte 2 (ver 04_analisis_final.R).
