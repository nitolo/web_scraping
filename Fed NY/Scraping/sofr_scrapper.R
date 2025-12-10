# LITERAL B Web Scraping del SOFR Overnight ON

# Cargamos librerias

library(httr)
library(readr)
library(dplyr)
library(lubridate)

#Definimos el rango de fechas 
start_date <- as.Date("2020-01-01")
end_date <- as.Date("2025-10-31")

# Ejecutamos funcion para obtener los datos de la tasa SOFR desde FRED
get_sofr_data <- function() {
  
  fred_csv_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=SOFR"
  
  message("Fetching SOFR data from FRED...")
  
  res <- tryCatch({
    httr::GET(fred_csv_url, timeout(20))
  }, error = function(e) {
    message("Error: ", e$message)
    return(NULL)
  })
  
  if (is.null(res) || httr::status_code(res) != 200) {
    stop("Failed to fetch data. Status code: ", httr::status_code(res))
  }
  
  txt <- httr::content(res, as = "text", encoding = "UTF-8")
  df <- tryCatch(
    readr::read_csv(I(txt), guess_max = 2000, show_col_types = FALSE),
    error = function(e) {
      stop("Error parsing CSV: ", e$message)
    }
  )
  
  names(df) <- make.names(names(df))
  
  date_col <- names(df)[which(grepl("date", names(df), ignore.case = TRUE))[1]]
  val_col <- names(df)[which(grepl("sofr|value|rate", names(df), ignore.case = TRUE))[1]]
  
  if (is.na(date_col) || is.na(val_col)) {
    stop("Could not identify date or rate columns")
  }
  
  df_clean <- df %>%
    mutate(
      fecha = as.Date(.data[[date_col]]),
      sofr = as.numeric(.data[[val_col]])
    ) %>%
    select(fecha, sofr) %>%
    arrange(fecha) %>%
    filter(fecha >= start_date & fecha <= end_date) %>%
    distinct(fecha, sofr, .keep_all = TRUE)
  
  if (nrow(df_clean) == 0) {
    stop("No data found in the specified date range")
  }
  
  message("Successfully fetched ", nrow(df_clean), " observations")
  message("Date range: ", min(df_clean$fecha), " to ", max(df_clean$fecha))
  
  return(df_clean)
}

# Extraemos datos
sofr_rates <- get_sofr_data()

# mostramos primeras y  ultimas observaciones
cat("\nFirst observations:\n")
print(head(sofr_rates, 10))


cat("\nLast observations:\n")

print(tail(sofr_rates, 10))

# Estadisticas y grafico
cat("\nSummary:\n")
cat("Total observations: ", nrow(sofr_rates), "\n")
cat("Rate range: ", round(min(sofr_rates$sofr, na.rm = TRUE), 3), "% to ",
    round(max(sofr_rates$sofr, na.rm = TRUE), 3), "%\n")
cat("Mean rate: ", round(mean(sofr_rates$sofr, na.rm = TRUE), 3), "%\n")
cat("Median rate: ", round(median(sofr_rates$sofr, na.rm = TRUE), 3), "%\n")

# Guardamos en CSV
write.csv(sofr_rates, "sofr_rates.csv", row.names = FALSE)
cat("\nData saved to 'sofr_rates.csv'\n")

library(ggplot2)
library(scales)

ggplot(sofr_rates, aes(x = fecha, y = sofr)) +
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
    title = "Secured Overnight Financing Rate (SOFR)",
    subtitle = "Frecuencia diaria | Enero 2020 - Octubre 2025",
    x = NULL,
    y = "Tasa (%)",
    caption = "Fuente: Federal Reserve Economic Data (FRED)"
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

