cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global



# Enlaces
packages_download <- function(){
  if (!require(openxlsx))install.packages("openxlsx");library(openxlsx)
  if (!require(httr))install.packages("httr");library(httr)
  if (!require(lubridate))install.packages("lubridate");library(lubridate)
  if (!require(readxl))install.packages("readxl");library(readxl)
  if (!require(utils))install.packages("utils");library(utils)
  if (!require(stats))install.packages("stats");library(stats)
}    


#url <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F2.%20Nuevos%20indicadores%20IPC%2F2.3.%20Por%20rango%20de%20fechas%2F2.3.1.%20Nuevas%20medidas%20de%20inflacion%20clasificacion%20BANREP%20de%20la%20canasta%20del%20IPC%20-%20IQY"
#url <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.5.IPC_Serie_variaciones"
#url <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202008%2F1.2.%20Por%20a%C3%B1o%2F1.2.2.IPC_Total%20nacional%20-%20IQY"
#url <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.5.IPC_Serie_variaciones"
# Descarga el archivo en tu directorio de trabajo
#download.file(url, destfile = "datos.xls", mode = "wb")

# Lee el archivo de Excel
#datos <- read_excel("datos.xls")


  
get.IPC <- function(){
  
  #link del excel del ipc del banrep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.5.IPC_Serie_variaciones"
  
  #se hace un print de que inicio el proceso
  # print("Extrayendo datos, puede tomar unos minutos")
  message("Extrayendo datos, puede tomar unos minutos")
  #se crea un archov temporal
  path_excel <- tempfile(fileext = ".xlsx")
  
  #se extraen los datos de la descarga
  
  while(class(try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T))=="try-error"){
    r <- httr::GET(link,
                   httr::add_headers(
                     Host="totoro.banrep.gov.co",
                     `User-Agent`="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0",
                     Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                     `Accept-Language` = "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
                     `Accept-Encoding` = "gzip, deflate",
                     Connection = "keep-alive"
                   ))
    #se pasan a formato excel
    bin <- httr::content(r, "raw")
    writeBin(bin, path_excel)
    
    #se leen
    d <- try(openxlsx::read.xlsx(path_excel, sheet = 1, detectDates = F),silent=T)
  }
  
  #eliminando el temporal
  unlink(path_excel)
  #se arregla el formato
  ##se dejan solo las fechas y el ipc (primeras dos columnas)
  d <- d[,1:2]
  ##se pasa la primera columna a numerico
  d[,1] <- suppressWarnings(as.numeric(d[,1]))
  ##se deja de una vez solo lo que no sea NA en ninguna de las dos columnas
  ##asi se borra tanto lo que era texto antes como lo que no tiene dato
  d <- d[stats::complete.cases(d),]
  ##las fechas estan en numerico pero es un formato anho mes, se ponen todas al final
  ##del mes
  ###se extrae el anho (los primeros 4 numeros)
  ano <- as.numeric(substr(d[,1],start=1,stop=4))
  ####se extrae el mes
  mes <- as.numeric(substr(d[,1],start=5,stop=nchar(d[,1])))
  ###se suma uno al mes, para luego restarle uno a la fecha (porque no se en que dia acaba cada mes)
  mes <- mes +1
  ano <- ifelse(mes==13,ano+1,ano)
  mes <- ifelse(mes==13,1,mes)
  ###se construye la fecha
  fechasIPC <- as.Date(paste(ano,mes,1,sep="/"),format="%Y/%m/%d")-1
  
  #se arreglan los nombres de las columnas
  names(d) <- c("Fecha", "IPC")
  #se intercambia la columna de fecha por las fechas construidas
  d$Fecha <- fechasIPC
  #se ordena
  d <- d[order(d$Fecha),]
  #se quitan los nombres de las filas
  rownames(d) <- NULL
  #se vuelven numeros las tasas
  d[,2] <- as.numeric(d[,2])
  #se anuncia cuantos datos se consiguieron
  # print(paste0("Se obtuvo datos para el IPC desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  # print("Fuente: Banco de la Republica de Colombia")
  message(paste0("Se obtuvo datos para el IPC desde ", d$Fecha[1], " hasta ", d$Fecha[nrow(d)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d)
  
}  

#ipc <- get.IPC()


####
get.IPC <- function(){
  
  # Link del excel del IPC del BanRep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.5.IPC_Serie_variaciones"
  
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
  dest_folder <- "C:/Users/ntorreslo/OneDrive - Telefonica/Research/Data collection/Colombia/Originals"
  dest_file <- paste0(dest_folder, "/IPC_BanRep_2.xlsx")
  file.rename(path_excel, dest_file)
  
  # Mensaje de finalización del proceso
  message(paste0("Archivo descargado y guardado en ", dest_file))
}

get.IPC()
