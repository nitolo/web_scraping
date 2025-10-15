#################################################
######## RECOLECCION ISE COLOMBIA #########
#################################################
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global

# Definir paquetes necesarios para el análisis
required_packages <- c("rvest", "httr", "readxl", "tidyverse")

# Función personalizada para instalar paquetes faltantes
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
  if (length(new_packages)) install.packages(new_packages)
}

# Instalar paquetes faltantes y cargar librerías
install_if_missing(required_packages)
lapply(required_packages, library, character.only = TRUE)


####### IPP NORMAL
dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"

# URL de la página del DANE donde se publica el archivo
page_url <- "https://www.dane.gov.co/index.php/estadisticas-por-tema/cuentas-nacionales/indicador-de-seguimiento-a-la-economia-ise"

# Función para descargar archivos de DANE
download_dane_files <- function(page_url, dest_folder, file_pattern, file_prefix) {
  # Función interna para descargar el archivo con manejo de errores y agente de usuario
  download_dane_file <- function(link, dest_file) {
    tryCatch({
      if (!grepl("^http", link)) {
        link <- paste0("https://www.dane.gov.co", link)
      }
      
      r <- httr::GET(link, httr::user_agent("Mozilla/5.0"))
      
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

#### ISE DE 9 SIN ESTACIONALIDAD

cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
# Definir paquetes necesarios para el análisis
required_packages <- c("openxlsx", "readxl", "tidyverse")

# Función personalizada para instalar paquetes faltantes
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
  if (length(new_packages)) install.packages(new_packages)
}

# Instalar paquetes faltantes y cargar librerías
install_if_missing(required_packages)
lapply(required_packages, library, character.only = TRUE)

input_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales/"

output_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/1. Actividad económica/"

# Función general para procesar y guardar datos de Excel
process_excel_data <- function(input_folder, input_file, input_sheet, start_row
                               , start_col, output_folder, output_file, output_sheet
                               , start_cell, start_date, include_dates = T) {
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
  
  # Transponer los datos
  data_transposed <- t(data)
  
  # Convertir la matriz a un dataframe
  data_dataframe <- as.data.frame(data_transposed)
  
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

input_file   <- "DANE_anex_ISE_9actividades.xlsx"

#### ISE AJUSTE ESTACIONAL
process_excel_data(
  input_folder = input_folder,
  input_file = input_file,
  input_sheet = "Cuadro 2",
  start_col = 2,
  start_row = 14,
  output_folder = output_folder,
  output_file = "1.3 ISE Index.xlsx",
  output_sheet = "ISE_9",
  start_cell = c(1, 3), # Seria celda A3 en excel
  start_date = as.Date("2005-01-01"),
  include_dates = T
)

#### ISE SIN AJUSTE ESTACIONAL
process_excel_data(
  input_folder = input_folder,
  input_file = input_file,
  input_sheet = "Cuadro 1",
  start_col = 2,
  start_row = 14,
  output_folder = output_folder,
  output_file = "1.3 ISE Index.xlsx",
  output_sheet = "ISE_9_SAE",
  start_cell = c(1, 3), # Seria celda A3 en excel
  start_date = as.Date("2005-01-01"),
  include_dates = T
)

#### ISE TENDENCIA-CICLO
process_excel_data(
  input_folder = input_folder,
  input_file = input_file,
  input_sheet = "Cuadro 3",
  start_col = 2,
  start_row = 14,
  output_folder = output_folder,
  output_file = "1.3 ISE Index.xlsx",
  output_sheet = "ISE_9_TEND",
  start_cell = c(1, 3), # Seria celda A3 en excel
  start_date = as.Date("2005-01-01"),
  include_dates = T
)



# ### INFORME ISE 9
# 
# cat("\014") # Limpiar la consola
# while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
# rm(list = ls()) # Limpiar el entorno global
# library(openxlsx)
# library(readxl)
# library(tidyverse)
# library(janitor)
# 
# ruta_excel <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/1. Actividad económica/"
# 
# libro = "1.3 ISE Index.xlsx"
# hoja = "ISE_9_SAE"
# hoja_1 = "ISE_9"
# 
# # ISE con estacionalidad
# df <- read_excel(paste0(ruta_excel, libro),sheet = hoja) 
# glimpse(df)
# df <- df[,-c(3,5)]
# 
# # ISE sin estacionalidad
# df_1 <- read_excel(paste0(ruta_excel, libro),sheet = hoja_1) 
# 
# df_1 <- df_1[,-c(3,5)]
# glimpse(df_1)
# #df <- df[-nrow(df),]
# 
# df$date <- as.Date(df$date)
# df_1$date <- as.Date(df_1$date)
# 
# 
# ruta_excel = "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/2. Dashboard/Mensual/"
# 
# libro = "2. ISE_informe_mensual.xlsx"
# hoja = "Datos_CE"
# hoja_1 = "Datos"
# 
# # Lee el archivo de Excel existente
# wb <- loadWorkbook(paste0(ruta_excel,libro))
# 
# # Escribe los datos en la hoja especificada a partir de la celda a2
# writeData(wb, sheet = hoja, df, startCol = 1, startRow = 2, colNames = T)
# writeData(wb, sheet = hoja_1, df_1, startCol = 1, startRow = 2, colNames = T)
# # Guarda los cambios en el archivo de Excel
# saveWorkbook(wb, paste0(ruta_excel,libro), overwrite = TRUE)
# 
# 
# 
