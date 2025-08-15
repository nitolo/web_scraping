#######################################################
################ RECOLECCIÓN DE DATOS IPC #############
################      CON DATOS DE BANREP #############
#######################################################

cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global

library(openxlsx)
library(httr)
library(lubridate)
library(readxl)
library(rvest)

dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"
# IPC por ciudades de Colombia base 2018
get.IPC_ciudades <- function(dest_folder){
  
  # Link del excel del IPC del BanRep
  link= "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.4.IPC_Por%20ciudad_IQY"
  #password = "&NQUser=publico&NQPassword=publico123"
  # Insertar la contraseña en la URL
  #link <- sub("&path", paste0(password, "&path"), link)
  
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

get.IPC_ciudades(dest_folder = dest_folder)

### METODOLOGIA 2020 del IPC BASICO BASE 2018
get.IPC_basico<- function(dest_folder){
  
  # Link del excel del IPC del BanRep
  link= "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F2.%20Nuevos%20indicadores%20IPC%2F2.3.%20Por%20rango%20de%20fechas%2F2.3.2.%20Nuevas%20medidas%20de%20inflacion%20basica%20-%20IQY"
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
  
  dest_file <- paste0(dest_folder, "/BanRep_IPC_basico.xlsx")
  file.rename(path_excel, dest_file)
  
  # Mensaje de finalización del proceso
  message(paste0("Archivo descargado y guardado en ", dest_file))
}

get.IPC_basico(dest_folder = dest_folder)

### IPC por divisiones. Base 2018
get.IPC_divisiones<- function(dest_folder){
  
  # Link del excel del IPC del BanRep
  link= "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.3.IPC_Por%20grupo%20de%20gasto_IQY"
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
  
  dest_file <- paste0(dest_folder, "/BanRep_IPC_divisiones.xlsx")
  file.rename(path_excel, dest_file)
  
  # Mensaje de finalización del proceso
  message(paste0("Archivo descargado y guardado en ", dest_file))
}

get.IPC_divisiones(dest_folder = dest_folder)

### IPC por nueva clasificacion BANREP

get.IPC_clasificacion_banrep<- function(dest_folder){
  
  # Link del excel del IPC del BanRep
  link= "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F2.%20Nuevos%20indicadores%20IPC%2F2.3.%20Por%20rango%20de%20fechas%2F2.3.1.%20Nuevas%20medidas%20de%20inflacion%20clasificacion%20BANREP%20de%20la%20canasta%20del%20IPC%20-%20IQY"
  #password = "&NQUser=publico&NQPassword=publico123"
  # Insertar la contraseña en la URL
  #link <- sub("&path", paste0(password, "&path"), link)
  
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
  
  dest_file <- paste0(dest_folder, "/BanRep_IPC_clasificacion_banrep.xlsx")
  file.rename(path_excel, dest_file)
  
  # Mensaje de finalización del proceso
  message(paste0("Archivo descargado y guardado en ", dest_file))
}

get.IPC_clasificacion_banrep(dest_folder = dest_folder)

##############################################
######### ACTUALIZATION OF DATA  #############
##############################################

### IPC BASICO
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(openxlsx)
library(readxl)
library(tidyverse)

ruta_ipc = "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales/"
# Leemos desde la 12 para evitar leer la que no nos sirven
ipc_basico <- read.xlsx(paste0(ruta_ipc, "BanRep_IPC_basico.xlsx")
                   , startRow = 29 ,sheet = 1, colNames = F)
glimpse(ipc_basico)

# Crear una función para detectar si alguna celda contiene los patrones deseados
detectar_patrones <- function(columna) {
  return(any(grepl("Variación|Anual|%", columna)))
}

# Aplicar la función a cada columna
columnas_a_eliminar <- sapply(ipc_basico, detectar_patrones)

# Eliminar las columnas que contienen los patrones
ipc_basico <- ipc_basico[, !columnas_a_eliminar] %>% 
  na.omit()

ipc_basico<- ipc_basico[2:nrow(ipc_basico), 2:6]
glimpse(ipc_basico)

# Cambia todas las columnas a numéricos
ipc_basico <- data.frame(lapply(ipc_basico, function(x) as.numeric(as.character(x))))
glimpse(ipc_basico)

# # Define la ruta al archivo de Excel existente
ruta_excel <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/1. Actividad económica/"
# Lee el archivo de Excel existente
wb <- loadWorkbook(paste0(ruta_excel,"IPC_banrep.xlsx"))

# Escribe los datos en la hoja especificada a partir de la celda B3
writeData(wb, sheet = "IPC_basico", ipc_basico, startCol = 2, startRow = 3, colNames = F)

# Guarda los cambios en el archivo de Excel
saveWorkbook(wb, paste0(ruta_excel,"IPC_banrep.xlsx"), overwrite = TRUE)

### IPC POR DIVISIONES

cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(openxlsx)
library(readxl)
library(tidyverse)

ruta_ipc = "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales/"
# Leemos desde la 12 para evitar leer la que no nos sirven
ipc_divisiones <- read.xlsx(paste0(ruta_ipc, "BanRep_IPC_divisiones.xlsx")
                        , startRow = 9 ,sheet = 1, colNames = F) 
glimpse(ipc_divisiones)

# Crear una función para detectar si alguna celda contiene los patrones deseados
# detectar_patrones <- function(columna) {
#   return(any(grepl("Variación|Anual|%", columna)))
# }

# Aplicar la función a cada columna
#columnas_a_eliminar <- sapply(ipc_divisiones, detectar_patrones)

# # Eliminar las columnas que contienen los patrones
# ipc_divisiones <- ipc_divisiones[, !columnas_a_eliminar] %>% 
#   na.omit()

# Crear una función para detectar la primera fila con NA en una columna
detectar_primer_na <- function(columna) {
  return(which(is.na(columna))[1])
}
limite_row <- detectar_primer_na(ipc_divisiones$X2)-1

ipc_divisiones<- ipc_divisiones[2:limite_row, 2:ncol(ipc_divisiones)]
glimpse(ipc_divisiones)

# Cambia todas las columnas a numéricos
ipc_divisiones <- data.frame(lapply(ipc_divisiones, function(x) as.numeric(as.character(x))))
glimpse(ipc_divisiones)

# # Define la ruta al archivo de Excel existente
ruta_excel <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/1. Actividad económica/"
# Lee el archivo de Excel existente
wb <- loadWorkbook(paste0(ruta_excel,"IPC_banrep.xlsx"))

# Escribe los datos en la hoja especificada a partir de la celda B3
writeData(wb, sheet = "IPC_divisiones", ipc_divisiones, startCol = 2, startRow = 3, colNames = F)

# Guarda los cambios en el archivo de Excel
saveWorkbook(wb, paste0(ruta_excel,"IPC_banrep.xlsx"), overwrite = TRUE)

# IPC POR CIUDADES

cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(openxlsx)
library(readxl)
library(tidyverse)

ruta_ipc = "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales/"
# Leemos desde la 12 para evitar leer la que no nos sirven
ipc_ciudades <- read.xlsx(paste0(ruta_ipc, "BanRep_IPC_ciudades.xlsx")
                            , startRow = 37 ,sheet = 1, colNames = F) 
glimpse(ipc_ciudades)

# Crear una función para detectar si alguna celda contiene los patrones deseados
# detectar_patrones <- function(columna) {
#   return(any(grepl("Variación|Anual|%", columna)))
# }

# Aplicar la función a cada columna
#columnas_a_eliminar <- sapply(ipc_ciudades, detectar_patrones)

# # Eliminar las columnas que contienen los patrones
# ipc_ciudades <- ipc_ciudades[, !columnas_a_eliminar] %>% 
#   na.omit()

# Crear una función para detectar la primera fila con NA en una columna
detectar_primer_na <- function(columna) {
  return(which(is.na(columna))[1])
}

limite_row <- detectar_primer_na(ipc_ciudades$X2)-1

ipc_ciudades<- ipc_ciudades[2:limite_row,2:ncol(ipc_ciudades)]
glimpse(ipc_ciudades)

# Cambia todas las columnas a numéricos
ipc_ciudades <- data.frame(lapply(ipc_ciudades, function(x) as.numeric(as.character(x))))
glimpse(ipc_ciudades)

# # Define la ruta al archivo de Excel existente
ruta_excel <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/1. Actividad económica/"
# Lee el archivo de Excel existente
wb <- loadWorkbook(paste0(ruta_excel,"IPC_banrep.xlsx"))

# Escribe los datos en la hoja especificada a partir de la celda B3
writeData(wb, sheet = "IPC_ciudades", ipc_ciudades, startCol = 2, startRow = 3, colNames = F)

# Guarda los cambios en el archivo de Excel
saveWorkbook(wb, paste0(ruta_excel,"IPC_banrep.xlsx"), overwrite = TRUE)

### IPC NUEVA CLASIFICACION BANREP

cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(openxlsx)
library(readxl)
library(tidyverse)

ruta_ipc = "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales/"
# Leemos desde la 12 para evitar leer la que no nos sirven
ipc_nuevo_banrep <- read.xlsx(paste0(ruta_ipc, "BanRep_IPC_clasificacion_banrep.xlsx")
                          , startRow = 22 ,sheet = 1, colNames = F) 
glimpse(ipc_nuevo_banrep)

#Crear una función para detectar si alguna celda contiene los patrones deseados
detectar_patrones <- function(columna) {
  return(any(grepl("Variación|Anual|%", columna)))
}

#Aplicar la función a cada columna
columnas_a_eliminar <- sapply(ipc_nuevo_banrep, detectar_patrones)

# Eliminar las columnas que contienen los patrones
ipc_nuevo_banrep <- ipc_nuevo_banrep[, !columnas_a_eliminar] %>% 
   na.omit()

# Crear una función para detectar la primera fila con NA en una columna
#detectar_primer_na <- function(columna) {
#  return(which(is.na(columna))[1])
#}
#limite_row <- detectar_primer_na(ipc_nuevo_banrep$X2)-1
#limite_row
ipc_nuevo_banrep<- ipc_nuevo_banrep[2:nrow(ipc_nuevo_banrep),2:ncol(ipc_nuevo_banrep)]
glimpse(ipc_nuevo_banrep)

# Cambia todas las columnas a numéricos
ipc_nuevo_banrep <- data.frame(lapply(ipc_nuevo_banrep, function(x) as.numeric(as.character(x))))
glimpse(ipc_nuevo_banrep)

# # Define la ruta al archivo de Excel existente
ruta_excel <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/1. Actividad económica/"
# Lee el archivo de Excel existente
wb <- loadWorkbook(paste0(ruta_excel,"IPC_banrep.xlsx"))

# Escribe los datos en la hoja especificada a partir de la celda B3
writeData(wb, sheet = "IPC_banrep", ipc_nuevo_banrep, startCol = 2, startRow = 3, colNames = F)

# Guarda los cambios en el archivo de Excel
saveWorkbook(wb, paste0(ruta_excel,"IPC_banrep.xlsx"), overwrite = TRUE)



