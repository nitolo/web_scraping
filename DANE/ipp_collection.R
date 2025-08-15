#################################################
######## RECOLECCION ISE COLOMBIA #########
#################################################
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(rvest)
library(httr)
library(tidyverse)

####### IPP NORMAL
dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"

# URL de la página del DANE donde se publica el archivo
page_url <- "https://www.dane.gov.co/index.php/estadisticas-por-tema/precios-y-costos/indice-de-precios-del-productor-ipp"

# Función para descargar archivos de DANE
download_dane_files <- function(page_url, dest_folder, file_pattern, file_prefix) {
  # Función interna para descargar el archivo con manejo de errores y agente de usuario
  download_dane_file <- function(link, dest_file) {
    tryCatch({
      if (!grepl("^http", link)) {
        link <- paste0("https://www.dane.gov.co", link)
      }
      
      r <- httr::GET(link,
                     httr::add_headers(
                       Host = "totoro.banrep.gov.co",
                       `User-Agent` = "Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                       Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                       `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                       `Accept-Encoding` = "gzip, deflate",
                       Connection = "keep-alive"
                     ))
      
      if (httr::status_code(r) == 200) {
        writeBin(httr::content(r, "raw"), dest_file)
        cat("Archivo descargado con éxito:", dest_file, "\n")
      } else {
        stop("Error al descargar el archivo. Código de estado:", httr::status_code(r))
      }
    }, error = function(e) {
      cat("Error al descargar", link, ":", conditionMessage(e), "\n")
    })
  }
  
  # Leer el contenido de la página
  page <- read_html(page_url)
  
  # Extraer los enlaces de los archivos Excel
  links <- page %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    .[grepl(file_pattern, .)]
  
  # Comprobar si se encontraron enlaces
  if (length(links) == 0) {
    stop("No se encontraron archivos para descargar.")
  }
  
  # Procesar los nombres de los archivos
  file_names <- sub(".*/(anex-.*?)-[^-]*\\.xlsx$", "\\1", links) 
  file_names <- gsub("-", "_", file_names)
  
  # Bucle para descargar cada archivo
  for (i in seq_along(file_names)) {
    link <- links[i]
    dest_file <- paste0(dest_folder, "/", file_prefix, "_", file_names[i], ".xlsx")
    download_dane_file(link, dest_file)
  }
  
  cat("Proceso completado.\n")
}

# Ejemplo de uso de la función
download_dane_files(
  page_url = page_url,
  dest_folder = dest_folder,
  file_pattern = "(?i)anex.*\\.xlsx$",
  file_prefix = "DANE"
)



##############################################
######### ACTUALIZATION OF DATA  #############
##############################################

#### IPP

cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(openxlsx)
library(readxl)
library(tidyverse)

input_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales/"

output_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/1. Actividad económica/"

# Función general para procesar y guardar datos de Excel
process_excel_data <- function(input_folder, input_file, input_sheet, start_row
                               , start_col, output_folder, output_file, output_sheet
                               , start_cell, start_date, include_dates = T
                               , vertical = F) {
  # Leer el archivo de Excel desde la fila especificada
  start_row <- start_row
  data <- read.xlsx(paste0(input_folder, input_file)
                    , startRow = start_row
                    , sheet = input_sheet, colNames = FALSE)
  
  # Seleccionar las columnas especificadas
  data <- data[, start_col:ncol(data)]
  
  first_na <- function(column) {
    return(which(is.na(column))[1])
  }
  
  limit_row <- as.numeric(first_na(data[,2]))-1
  
  data <- data[1:limit_row,]
  
  if (vertical){
    data_dataframe <- as.data.frame(data)
  } else {
    # Transponer los datos
    data_transposed <- t(data)
    # Convertir la matriz a un dataframe
    data_dataframe <- as.data.frame(data_transposed)
  }
  
  # Seleccionar las filas y columnas necesarias
  #data_dataframe <- data_dataframe[2:nrow(data_dataframe), 2:limit_row]
  
  # Convertir todas las columnas a numéricas
  data_dataframe <- data.frame(lapply(data_dataframe, function(x) as.numeric(as.character(x))))
  
  # Incluir fechas si el parámetro include_dates es TRUE
  if (include_dates) {
    # Crear un vector de fechas trimestrales
    end_date <- start_date + months((nrow(data_dataframe) - 1))
    date_vector <- seq.Date(from = start_date, to = end_date, by = "month")
    
    # Crear un dataframe con el vector de fechas
    date_vector_df <- data.frame(date = date_vector)
    #date_vector_df <- data.frame(date = as.Date(date_vector, format = "%d/%m/%Y"))
    
    # Crear dataframes para las columnas vacías
    empty_df <- data.frame(empty_column = rep(NA, nrow(date_vector_df)))
    
    # Combinar el dataframe de fechas con el dataframe de datos
    data_dataframe <- cbind(date_vector_df, data_dataframe)
    
    # Hacer calculo YoY
    df_yoy <- data_dataframe %>%
      mutate(across(-date, list(yoy = ~ (. - lag(., 12)) / lag(., 12)))) %>% 
      select(dplyr::ends_with("yoy"))
    
    # Hacer calculo MoM
    df_mom <- data_dataframe %>%
      mutate(across(-date, list(mom = ~ (. - lag(.)) / lag(.)))) %>% 
      select(dplyr::ends_with("mom"))
    
    # Combinar el dataframe de fechas con el dataframe de los calculos yoy y mom
    data_dataframe <- cbind(data_dataframe, empty_df, df_yoy, empty_df, df_mom)
    
    
  }
  # Verificar si el archivo de Excel existe, si no, crearlo
  output_path <- paste0(output_folder, output_file)
  if (!file.exists(output_path)) {
    wb <- createWorkbook()
    addWorksheet(wb, output_sheet)  # Añadir la hoja inicial
    saveWorkbook(wb, output_path, overwrite = TRUE)
  }
  
  # Cargar el archivo de Excel existente
  wb <- loadWorkbook(output_path)
  
  # Verificar si la hoja de salida existe, si no, crearla
  if (!(output_sheet %in% names(wb))) {
    addWorksheet(wb, output_sheet)
  }
  # Escribir los datos en la hoja especificada a partir de la celda especificada
  writeData(wb, sheet = output_sheet, data_dataframe, startCol = start_cell[1]
            , startRow = start_cell[2], colNames = FALSE)
  
  # Guardar los cambios en el archivo de Excel
  saveWorkbook(wb, output_path, overwrite = TRUE)
  
  cat("Proceso completado.\n")
}

input_file   <- "DANE_anex_IPP_historicos.xlsx"

#### IPP historico
process_excel_data(
  input_folder = input_folder,
  input_file = input_file,
  input_sheet = "IPP Histórico",
  start_col = 3,
  start_row = 6,
  output_folder = output_folder,
  output_file = "2.2 IPP Index.xlsx",
  output_sheet = "IPP",
  start_cell = c(1, 5), # Seria celda A3 en excel
  start_date = as.Date("1996-06-01"), # FORMAT YYYY/MM/DD
  include_dates = T,
  vertical = T
)

#### IPP SEGUN DESTINO ECONOMICO
input_file   <- "DANE_anex_IPP_ProcSegunDestinoEconomico.xlsx"

process_excel_data(
  input_folder = input_folder,
  input_file = input_file,
  input_sheet = "BK IMPORTADOS",
  start_col = 4,
  start_row = 8,
  output_folder = output_folder,
  output_file = "2.2 IPP Index.xlsx",
  output_sheet = "IPP_SEGUN_DESTINO",
  start_cell = c(1, 5), # Seria celda A3 en excel
  start_date = as.Date("2014-12-01"), # FORMAT YYYY/MM/DD
  include_dates = T,
  vertical = F
)

