#######################################################
################ RECOLECCIÓN DE DATOS IPC #############
################      CON DATOS DE BANREP #############
#######################################################

cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global

if (!require(openxlsx))install.packages("openxlsx");library(openxlsx)
if (!require(httr))install.packages("httr");library(httr)
if (!require(lubridate))install.packages("lubridate");library(lubridate)
if (!require(readxl))install.packages("readxl");library(readxl)
if (!require(utils))install.packages("utils");library(utils)
if (!require(stats))install.packages("stats");library(stats)
library(rvest)

dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"

# URL de la página del DANE donde se publica el archivo
page_url <- "https://uba.banrep.gov.co/htmlcommons/SeriesHistoricas/agregados-monetarios-crediticios.html"

# Leer el contenido de la página
page <- read_html(page_url)

prueba <- page %>%
  html_nodes("iframe") %>% 
  html_table()

prueba

prueba2 <s- page%>%
  html_nodes("iframe") 

prueba2[2]
# Extraer el enlace del archivo Excel
links <- page %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  .[grepl("(?i)anex.*\\.xlsx$|gasto.*\\.xlsx$|enfoque.*\\.xlsx$", .)]

# IPC por ciudades de Colombia base 2018
get.IPC_ciudades <- function(dest_folder){
  
  # Link del excel del IPC del BanRep
  link= "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.4.IPC_Por%20ciudad_IQY"
  password = "&NQUser=publico&NQPassword=publico123"
  # Insertar la contraseña en la URL
  link <- sub("&path", paste0(password, "&path"), link)
  
  # Mensaje de inicio del proceso
  message("Extrayendo datos, puede tomar unos minutos")
  
  # Crear un archivo temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  # Extraer los datos de la descarga
  r <- httr::GET(link,
                 httr::add_headers(
                   Host="totoro.banrep.gov.co",
                   `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                   Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                   `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                   `Accept-Encoding` = "gzip, deflate",
                   Connection = "keep-alive"
                 ))
  
  # Pasar a formato Excel
  bin <- httr::content(r, "raw")
  writeBin(bin, path_excel)
  
  # Mover el archivo a la carpeta de destino
  
  dest_file <- paste0(dest_folder, "/BanRep_IPC_ciudades.xlsx")
  file.rename(path_excel, dest_file)
  
  # Mensaje de finalización del proceso
  message(paste0("Archivo descargado y guardado en ", dest_file))
}