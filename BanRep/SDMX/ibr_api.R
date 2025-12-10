# ==============================================================================
# PUNTO 2 Web Scraping y Uso de API 
# ==============================================================================

# LITERAL A

# Descargamos librerias y extraemos las tasas diarias del IBR Overnight desde la API SDMX del Banco de la República
# Obtenemos información histórica del indicador desde el 1 de enero de 2020 hasta el 31 de octubre de 2025


library(httr)
library(xml2)
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)

# Configuamos API 
URL_BASE <- "https://totoro.banrep.gov.co/nsi-jax-ws/rest/data/ESTAT,"
NAMESPACES <- c(generic = "http://www.sdmx.org/resources/sdmxml/schemas/v2_1/data/generic")
SERIE_IBR <- "DF_IBR_DAILY_HIST,1.0/"

PARAMS <- list(
  dimensionAtObservation = "TIME_PERIOD",
  detail = "full"
)

# Rango de fechas que analizaremos:desde  el 2020 al 31 de octubre de 2025
start_date <- as.Date("2020-01-01")
end_date <- as.Date("2025-10-31")

# obtenemos los datos del IBR desde el Banco de la Republica
get_ibr_data <- function() {
  
  url_completa <- paste0(URL_BASE, SERIE_IBR)
  message("Fetching IBR data from Banco de la Republica...")
  message("URL: ", url_completa)
  
  resp <- tryCatch({
    GET(url_completa, query = PARAMS)
  }, error = function(e) {
    stop("HTTP Error: ", e$message)
  })
  
  if (status_code(resp) != 200) {
    stop("Request failed. Status code: ", status_code(resp))
  }
  
  xml_content <- content(resp, as = "text", encoding = "UTF-8")
  doc <- read_xml(xml_content)
  
  data_list <- list()
  series_nodes <- xml_find_all(doc, ".//generic:Series", ns = NAMESPACES)
  
  for (serie in series_nodes) {
    series_key <- list()
    key_nodes <- xml_find_all(serie, ".//generic:SeriesKey/generic:Value", ns = NAMESPACES)
    
    for (node in key_nodes) {
      series_key[[xml_attr(node, "id")]] <- xml_attr(node, "value")
    }
    
    obs_nodes <- xml_find_all(serie, ".//generic:Obs", ns = NAMESPACES)
    
    for (obs in obs_nodes) {
      fecha <- xml_attr(xml_find_first(obs, "./generic:ObsDimension", ns = NAMESPACES), "value")
      valor <- xml_attr(xml_find_first(obs, "./generic:ObsValue", ns = NAMESPACES), "value")
      
      registro <- c(series_key, list(fecha = fecha, valor = valor))
      data_list <- append(data_list, list(registro))
    }
  }
  
  if (length(data_list) == 0) {
    stop("No data retrieved from API")
  }
  
  df <- bind_rows(data_list)
  
  df$fecha <- suppressWarnings(as.Date(df$fecha, format = "%Y%m%d"))
  if (any(is.na(df$fecha))) {
    df$fecha[is.na(df$fecha)] <- suppressWarnings(as.Date(df$fecha, format = "%Y-%m-%d"))
  }
  
  df$valor <- as.numeric(df$valor)
  
  # Agregamos filtro para IBR Overnight (IRIBRM00) y tasas numericas (NR)
  df_clean <- df %>%
    filter(
      SUBJECT == "IRIBRM00",
      UNIT_MEASURE == "NR",
      fecha >= start_date,
      fecha <= end_date
    ) %>%
    select(fecha, valor) %>%
    rename(ibr_overnight = valor) %>%
    arrange(fecha) %>%
    distinct(fecha, .keep_all = TRUE)
  
  if (nrow(df_clean) == 0) {
    stop("No IBR Overnight data found in the specified date range")
  }
  
  message("Successfully fetched ", nrow(df_clean), " observations")
  message("Date range: ", min(df_clean$fecha), " to ", max(df_clean$fecha))
  
  return(df_clean)
}

# Ejecutamos la extraccion de los datos
ibr_rates <- get_ibr_data()

# Mostramos las primeras y ultimas observaciones
cat("\nFirst observations:\n")
print(head(ibr_rates, 10))

cat("\nLast observations:\n")
print(tail(ibr_rates, 10))

#Estadisticas y grafico

cat("\nSummary:\n")
cat("Total observations: ", nrow(ibr_rates), "\n")
cat("Rate range: ", round(min(ibr_rates$ibr_overnight, na.rm = TRUE), 3), "% to ",
    round(max(ibr_rates$ibr_overnight, na.rm = TRUE), 3), "%\n")
cat("Mean rate: ", round(mean(ibr_rates$ibr_overnight, na.rm = TRUE), 3), "%\n")
cat("Median rate: ", round(median(ibr_rates$ibr_overnight, na.rm = TRUE), 3), "%\n")

# Save to CSV
write.csv(ibr_rates, "ibr_overnight_rates.csv", row.names = FALSE)
cat("\nData saved to 'ibr_overnight_rates.csv'\n")

# Plot
ggplot(ibr_rates, aes(x = fecha, y = ibr_overnight)) +
  geom_line(color = "#0077b6", linewidth = 0.8) +
  scale_x_date(
    date_breaks = "6 months",
    date_labels = "%b %Y",
    expand = c(0.01, 0)
  ) +
  scale_y_continuous(
    labels = label_number(suffix = "%", accuracy = 0.1),
    expand = expansion(mult = c(0.05, 0.05))
  ) +
  labs(
    title = "Tasa IBR Overnight - Banco de la Republica",
    subtitle = "Frecuencia diaria | Enero 2020 - Octubre 2025",
    x = NULL,
    y = "Tasa (%)",
    caption = "Fuente: Banco de la Republica de Colombia - API SDMX"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16, color = "#023e8a", 
                              margin = margin(b = 5)),
    plot.subtitle = element_text(size = 11, color = "#555555", 
                                 margin = margin(b = 15)),
    plot.caption = element_text(size = 9, color = "#666666", hjust = 0,
                                margin = margin(t = 10)),
    axis.title.y = element_text(size = 11, face = "bold", color = "#333333",
                                margin = margin(r = 10)),
    axis.text = element_text(color = "#333333"),
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(color = "#e0e0e0", linewidth = 0.3),
    panel.grid.major.y = element_line(color = "#e0e0e0", linewidth = 0.3),
    plot.margin = margin(15, 15, 15, 15),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )