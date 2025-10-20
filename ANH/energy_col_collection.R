##############################################################
######## RECOLECCION PRODUCCION CRUDO Y GAS COLOMBIA #########
##############################################################
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(rvest)
library(httr)
library(tidyverse)
####### TASA DE DESEMPLEO NORMAL
dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"

# URL de la página del DANE donde se publica el archivo
page_url <- "https://www.anh.gov.co/es/operaciones-y-regal%C3%ADas/sistemas-integrados-operaciones/estad%C3%ADsticas-de-producci%C3%B3n/"

# Función para descargar archivos de DANE
download_dane_files <- function(page_url, dest_folder, file_pattern, file_prefix) {
  download_dane_file <- function(link, dest_file) {
    tryCatch({
      if (!grepl("^http", link)) {
        link <- paste0("https://www.anh.gov.co", link)
      }
      
      download.file(link, dest_file, mode = "wb", quiet = TRUE)
      cat("Archivo descargado con éxito:", dest_file, "\n")
    }, error = function(e) {
      cat("Error al descargar", link, ":", conditionMessage(e), "\n")
    })
  }
  
  page <- read_html(page_url)
  links <- page %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    .[grepl(file_pattern, .)]
  
  if (length(links) == 0) {
    stop("No se encontraron archivos para descargar.")
  }
  
  #file_names <- sub(".*/(crudo.*?)-[^-]*\\.xlsx$", "\\1", links) 
  file_names <- sub(".*(crudo|gas).*?(\\d{4})[^/]*\\.xlsx$", "\\1_\\2", links)
  file_names <- gsub("-", "_", file_names)
  
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
  file_pattern = "(?i)(crudo|gas).*\\.xlsx$",
  file_prefix = "ANH"
)
