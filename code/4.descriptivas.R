                # ---------------------------#
                # Estadísticas descriptivas  #
                # ---------------------------#

library(dplyr)
library(ggplot2)
library(sf)

setwd("C:/Users/USUARIO/Documents/GitHub/TF_EU_STCH")

panel <- st_read("data/final/simulacion.shp")

panel <- as.data.frame(panel)

# ---------------------------#
# Evolución de precios de tratados y controles con momento de evento
# ---------------------------#

# Grupos
panel_graf <- panel %>%
  mutate(group = ifelse(is.na(tret_yr), "Nunca tratado", "Tratado"))

# Promedio para tratados (por año relativo al evento)
treated_es <- panel_graf %>%
  filter(!is.na(evnt_tm)) %>%   # solo tratados
  group_by(evnt_tm) %>%
  summarise(mean_log_price = mean(log_prc, na.rm = TRUE),
            group = "Tratado",
            .groups = "drop")

# Promedio para nunca tratados (por año)
never_es <- panel_graf %>%
  filter(is.na(tret_yr)) %>%     # controles puros
  group_by(year) %>%
  summarise(mean_log_price = mean(log_prc, na.rm = TRUE),
            .groups = "drop") %>%
  mutate(
    # alineamos usando el mínimo treat_year observado
    evnt_tm = year - min(panel_graf$tret_yr, na.rm = TRUE),
    group = "Nunca tratado"
  )

# Unir para graficar
panel_graf_1 <- bind_rows(treated_es, never_es)

price_evol <- ggplot(panel_graf_1, aes(evnt_tm, mean_log_price, color = group)) +
  geom_line(size = 1.1) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_x_continuous(limits = c(-5, 5)) +
  labs(
    x = "Tiempo relativo al inicio del tratamiento",
    y = "Promedio del log del precio",
    color = "") +
  theme_minimal(14)

price_evol

ggsave("results/fig_price_evol.pdf", price_evol, width = 8, height = 5)

# ---------------------------#
# Distribución de precios
# ---------------------------#

price_dist <- ggplot(panel_graf, aes(x = log_prc, fill = factor(treated))) +
  geom_density(alpha = 0.4) +
  scale_fill_manual(values = c("steelblue", "tomato"),
                    labels = c("Control", "Tratado")) +
  labs(x = "Log del precio",
       y = "Densidad",
       fill = "",) +
  theme_minimal(base_size = 14)
  
price_dist

ggsave("results/fig_price_distribution.pdf", price_dist, width = 8, height = 5)

## Y solo para pre-treatment

panel_pre <- panel %>% filter(year < tret_yr | is.na(tret_yr))

price_dist_pre <- ggplot(panel_pre, aes(x = log_prc, fill = factor(treated))) +
  geom_density(alpha = 0.4) +
  scale_fill_manual(values = c("steelblue", "tomato"),
                    labels = c("Control", "Tratado")) +
  labs(x = "Log del precio",
       y = "Densidad",
       fill = "",) +
  theme_minimal(base_size = 14)

price_dist_pre

# ---------------------------#
# Gráfica de Asignación
# ---------------------------#


panel_assign <- panel %>%
  mutate(
    status = case_when(
      is.na(tret_yr) ~ "Nunca tratado",
      tret_yr == year ~ "Se trata este año",
      tret_yr <  year ~ "Ya tratado",
      tret_yr >  year ~ "Aún no tratado"
    )
  )

# Crear una tabla con combinaciones de año y estado de la manzana
panel_count <- panel_assign %>%
  count(year, status) %>%
  tidyr::complete(
    year,
    status = c("Nunca tratado", "Aún no tratado", "Se trata este año", "Ya tratado"),
    fill = list(n = 0)
  )

treat_year <- ggplot(panel_count, aes(x = year, y = n, fill = status)) +
  geom_col(position = "stack", alpha = 0.9) +
  scale_fill_manual(
    values = c(
      "Nunca tratado" = "#88C0D0",
      "Aún no tratado" = "#C4D7E0",
      "Se trata este año" = "#8E7DBE",
      "Ya tratado" = "steelblue4"
    )
  ) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(
    x = "Año",
    y = "Número de manzanas",
    fill = "") +
  theme_minimal(base_size = 14)

treat_year

ggsave("results/fig_treat_year_obs.pdf", treat_year, width = 8, height = 5)

