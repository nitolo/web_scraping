#################################################
########## RECOLECCION IPC COLOMBIA #############
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
page_url <- "https://www.banrep.gov.co/es/estadisticas/catalogo"

# Leer el contenido de la página
page <- read_html(page_url)

# Extraer el enlace del archivo Excel
links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>% 
  .[grepl("balanza_cambia", .)]
  #.[grepl(".xlsx$|excel", .)]

links
