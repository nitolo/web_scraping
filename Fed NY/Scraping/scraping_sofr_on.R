# Carga las librerías necesarias. Si no las tienes instaladas, usa install.packages(c("httr", "jsonlite", "dplyr", "purrr", "tidyr")).
library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(tidyr)
library(lubridate) # Para funciones de manejo de fechas

get_sofr_data <- function(fecha_inicio = as.Date("2018-04-02"), fecha_fin = Sys.Date() - 1) {
  #' Obtiene datos diarios de la tasa SOFR (Secured Overnight Financing Rate) desde la NY Fed.
  #'
  #' Construye la URL de la API de la NY Fed usando el rango de fechas proporcionado,
  #' descarga el JSON, parsea la estructura anidada y limpia el data frame.
  #'
  #' @param fecha_inicio La fecha de inicio (objeto Date).
  #' @param fecha_fin La fecha de fin (objeto Date).
  #' @return Un data frame con las columnas `fecha` y `sofr`, ordenado por fecha.
  #' @export
  
  # --- VALIDACIÓN DE FECHAS ---
  fecha_actual <- Sys.Date()
  if (fecha_fin >= fecha_actual) {
    fecha_fin <- fecha_actual - 1
    message(paste("Advertencia: La fecha de fin fue ajustada a", format(fecha_fin, "%Y-%m-%d"), 
                  "porque no se puede solicitar datos para hoy o el futuro. El dato más reciente es el de ayer"))
  }
  
  if (fecha_inicio >= fecha_fin) {
    stop("Error: La fecha de inicio debe ser anterior a la fecha de fin")
  }
  
  # --- 1. Configuración y Construcción de la URL de la API de la NY Fed ---
  base_url <- "https://markets.newyorkfed.org/read"
  
  # Parámetros de la consulta:
  query_params <- list(
    productCode = 50,
    eventCodes = 520,
    startDt = format(fecha_inicio, "%Y-%m-%d"), # Formato 'YYYY-MM-DD'
    endDt = format(fecha_fin, "%Y-%m-%d"),
    fields = "dailyRate,refRateDt",
    sort = "postDt:1"
  )
  
  parsed_url <- httr::parse_url(base_url)
  parsed_url$query <- query_params
  url_completa <- httr::build_url(parsed_url)
  
  message(paste("URL completa generad", url_completa)) 
  
  message(paste("Obteniendo datos SOFR de la Fed  de NY desde", 
                format(fecha_inicio, "%Y-%m-%d"), "hasta", format(fecha_fin, "%Y-%m-%d"), "..."))
  
  # --- 2. Petición HTTP ---
  respuesta <- tryCatch({
    # La petición ahora utiliza la url 1A
    httr::GET(url_completa, timeout(30))
  }, error = function(e) {
    stop(paste("Error en la solicitud HTTP a la NY Fed:", e$message))
  })
  
  # Verifica que la respuesta exista y el código de estado sea 200
  if (httr::status_code(respuesta) != 200) {
    # Mensaje de error más detallado
    stop(paste("Fallo al obtener los datos. Código de estado:", httr::status_code(respuesta), 
               ". Revise los parámetros de fecha, el rango, o la URL completa:", url_completa))
  }
  
  # Extrae el contenido JSON como texto
  json_contenido <- httr::content(respuesta, as = "text", encoding = "UTF-8")
  
  # --- 3. Parseo del JSON  ---
  
  # 3a. Parseo del nivel superior. la respuesta contiene un objeto con la clave data
  datos_base <- tryCatch(
    jsonlite::fromJSON(json_contenido)$data,
    error = function(e) {
      stop(paste("Error al parsear el JSON de nivel superior:", e$message))
    }
  )
  
  # Verifica si hay datos
  if (is.null(datos_base) || !is.data.frame(datos_base) || nrow(datos_base) == 0) {
    message("La API devolvió una respuesta válida, pero no se encontraron registros")
    return(data.frame(fecha = as.Date(character()), sofr = numeric()))
  }
  
  # 3b. Parseo del JSON anidado dentro de la columna data
  # La columna data es un string json que debe ser parseado individualmente.
  df_parsed <- datos_base %>%
    # Usamos purrr::map para aplicar jsonlite::fromJSON a cada string en la columna data
    # ademas purrr es un mago para procesamiento paralelo
    # y luego usamos tidyr::unnest_wider para expandir la lista resultante en nuevas columnas
    mutate(parsed_data = purrr::map(data, ~jsonlite::fromJSON(.x, simplifyVector = TRUE))) %>%
    tidyr::unnest_wider(parsed_data)
  
  # --- 4. Limpieza ---
  
  df_limpio <- df_parsed %>%
    # Renombra y convierte los tipos de datos como lo solicitaste
    mutate(
      fecha = as.Date(refRateDt),     # Son las columnas que tienen la fecha
      sofr = as.numeric(dailyRate)    # Es la columna que tiene el dato de la fed
    ) %>%
    select(fecha, sofr) %>%
    arrange(fecha) %>%
    filter(fecha >= fecha_inicio & fecha <= fecha_fin) %>%
    distinct(fecha, sofr, .keep_all = TRUE) %>% # Elimina posibles duplicados
    filter(!is.na(sofr))# Elimina filas donde el valor SOFR sea NA o NaN
  
  # Verifica si hay datos después del filtrado
  if (nrow(df_limpio) == 0) {
    message("No se encontraron datos después de la limpieza")
  } else {
    message("Se obtuvieron exitosamente ", nrow(df_limpio), " observaciones.")
    message(paste("Rango de fechas final:", min(df_limpio$fecha), "a", max(df_limpio$fecha)))
  }
  
  return(df_limpio)
}

fecha_inicio <- as.Date("2020-01-01")
fecha_fin <- as.Date("2025-10-31") 


sofr_rates <- get_sofr_data(fecha_inicio = fecha_inicio, fecha_fin = fecha_fin)
