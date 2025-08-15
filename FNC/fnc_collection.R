#################################################
########## RECOLECCION DATOS FEDERACIÓN ######### 
########### NACIONAL DE CAFETEROS   #############
#################################################
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(rvest)
library(httr)
library(readxl)
####### TASA DE DESEMPLEO NORMAL

dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"
# URL de la página del DANE donde se publica el archivo
page_url <- "https://federaciondecafeteros.org/wp/estadisticas-cafeteras/"

# Leer el contenido de la página
page <- read_html(page_url)

# Extraer el enlace del archivo Excel
links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl(".xlsx", .)]
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
    link <- paste0("https://federaciondecafeteros.org/wp/", link)
  }
  
  # Descargar el archivo
  download.file(link, dest_file, mode = "wb")
}


file_names <- sub(".*/([^/]*)\\.xlsx$", "\\1", links)
file_names <- gsub("-", "_", file_names)
file_names
links

# Bucle para descargar cada archivo
for (i in seq_along(file_names)) {
  link <- links[i]
  dest_file <- paste0(dest_folder, "/", "FNC_",file_names[i], ".xlsx")
  download_dane_file(link, dest_file)
}


