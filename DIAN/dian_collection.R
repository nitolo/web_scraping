#################################################
########## RECOLECCION DATOS DIAN ############### 
#################################################
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(rvest)
library(httr)
library(readxl)
library(dplyr)
####### TASA DE DESEMPLEO NORMAL

dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales/DIAN"
# URL de la página del DANE donde se publica el archivo
page_url <- "https://www.dian.gov.co/dian/cifras/Paginas/EstadisticasRecaudo.aspx"

# Leer el contenido de la página
page <- read_html(page_url)

# Extraer el enlace del archivo Excel
links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("(?i)estadistica.*\\.xlsx$", .)]
links

# Comprobar si se encontraron enlaces
if (length(links) == 0) {
  stop("No se encontró el archivo.")
}

links

# Función para descargar el archivo
download_dane_file <- function(link, dest_file) {
  # Completar la URL si es relativa
  if (!grepl("^http", link)) {
    link <- paste0("https://www.dian.gov.co", link)
  }
  
  # Descargar el archivo
  download.file(link, dest_file, mode = "wb")
}


file_names <- sub(".*/([^/]*)\\.(xlsx|zip)$", "\\1", links)
file_names <- gsub("-", "_", file_names)
file_names

# Bucle para descargar cada archivo
for (i in seq_along(file_names)) {
  link <- links[i]
  dest_file <- paste0(dest_folder, "/", "DIAN_",file_names[i], ".xlsx")
  download_dane_file(link, dest_file)
}

### PARA LOS ARCHIVOS .ZIP. AHI ESTA EL QUE MAS IMPORTA
dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"

links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  #.[grepl(".xlsx|.zip", .)] %>% 
  .[grepl("(?i)impuesto.*\\.zip$", .)]
links


file_names <- sub(".*/([^0-9/]*)[^/]*(\\.xlsx|\\.zip)$", "\\1", links)
file_names <- gsub("-", "_", file_names)
file_names

# Bucle para descargar cada archivo
for (i in seq_along(file_names)) {
  link <- links[i]
  file_extension <- tools::file_ext(link)
  
  if (file_extension == "zip") {
    # Descargar y descomprimir el archivo .zip
    #temp_file <- tempfile()
    temp_file <- paste0(dest_folder, "/", "DIAN_", file_names[i], ".xlsx")
    download_dane_file(link, temp_file)
    unzip(temp_file, exdir = dest_folder)
    
    # Mover todos los archivos .xlsx en el archivo .zip a la carpeta de destino
    #xlsx_files <- list.files(dest_folder, pattern = "\\.xlsx$")

  } else if (file_extension == "xlsx") {
    # Descargar el archivo .xlsx
    dest_file <- paste0(dest_folder, "/", "DIAN_", file_names[i], ".xlsx")
    download_dane_file(link, dest_file)
  }
}



