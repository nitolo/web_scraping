###############################################################
############# RECOLECCION BALANZA COMERCIAL COLOMBIA ##########
###############################################################
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(rvest)
library(httr)
library(readxl)
library(tidyverse)
####### TASA DE DESEMPLEO NORMAL
dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"
# URL de la página del DANE donde se publica el archivo
page_url <- "https://www.dane.gov.co/index.php/estadisticas-por-tema/comercio-internacional/balanza-comercial"

# Leer el contenido de la página
page <- read_html(page_url)

# Extraer el enlace del archivo Excel
links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("(?i)anex.*\\.xlsx$|bcom*\\.xlsx$|enfoque.*\\.xlsx$", .)]
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
    link <- paste0("https://www.dane.gov.co", link)
  }
  
  # Descargar el archivo
  download.file(link, dest_file, mode = "wb")
}

file_names <- sub(".*/(anex-.*?)-[^-]*\\.xlsx$", "\\1", links) 
file_names <- gsub("-", "_", file_names)
file_names

# Bucle para descargar cada archivo
for (i in seq_along(file_names)) {
  link <- links[i]
  dest_file <- paste0(dest_folder, "/", "DANE_",file_names[i], ".xlsx")
  download_dane_file(link, dest_file)
}

######################################
########### EXPORTACIONES ############
######################################

page_url <- "https://www.dane.gov.co/index.php/estadisticas-por-tema/comercio-internacional/exportaciones"

# Leer el contenido de la página
page <- read_html(page_url)

# Extraer el enlace del archivo Excel
links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("(?i)anex.*\\.xlsx$|exporta*\\.xlsx$", .)]
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
    link <- paste0("https://www.dane.gov.co", link)
  }
  
  # Descargar el archivo
  download.file(link, dest_file, mode = "wb")
}

file_names <- sub(".*/(anex-.*?)-[^-]*\\.(xlsx$|xls$)", "\\1", links) 
file_names <- gsub("-", "_", file_names)
file_names
links
# Bucle para descargar cada archivo
for (i in seq_along(file_names)) {
  link <- links[i]
  dest_file <- paste0(dest_folder, "/", "DANE_",file_names[i], ".xlsx")
  download_dane_file(link, dest_file)
}

links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("(?i)anex.*\\.xls$", .)]
links

file_names <- sub(".*/(anex-.*?)-[^-]*\\.(xlsx$|xls$)", "\\1", links) 
file_names <- gsub("-", "_", file_names)
file_names


# Bucle para descargar cada archivo
for (i in seq_along(file_names)) {
  link <- links[i]
  dest_file <- paste0(dest_folder, "/", "DANE_",file_names[i], ".xls")
  download_dane_file(link, dest_file)
}


######################################
########### IMPORTACIONES ############
######################################

page_url <- "https://www.dane.gov.co/index.php/estadisticas-por-tema/comercio-internacional/importaciones"

# Leer el contenido de la página
page <- read_html(page_url)

# Extraer el enlace del archivo Excel
links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("(?i)anex.*\\.xlsx$|imp*\\.xlsx$", .)]
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
    link <- paste0("https://www.dane.gov.co", link)
  }
  
  # Descargar el archivo
  download.file(link, dest_file, mode = "wb")
}

file_names <- sub(".*/(anex-.*?)-[^-]*\\.(xlsx$|xls$)", "\\1", links) 
file_names <- gsub("-", "_", file_names)
file_names
links
# Bucle para descargar cada archivo
for (i in seq_along(file_names)) {
  link <- links[i]
  dest_file <- paste0(dest_folder, "/", "DANE_",file_names[i], ".xlsx")
  download_dane_file(link, dest_file)
}

links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("(?i)anex.*\\.xls$", .)]
links

file_names <- sub(".*/(anex-.*?)-[^-]*\\.(xlsx$|xls$)", "\\1", links) 
file_names <- gsub("-", "_", file_names)
file_names

# Bucle para descargar cada archivo
for (i in seq_along(file_names)) {
  link <- links[i]
  dest_file <- paste0(dest_folder, "/", "DANE_",file_names[i], ".xls")
  download_dane_file(link, dest_file)
}

