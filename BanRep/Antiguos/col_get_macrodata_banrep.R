#######################################################
################ RECOLECCIÓN DE DATOS IPC #############
################      CON DATOS DE BANREP #############
#######################################################

cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global

library(openxlsx)
library(httr)
library(dplyr)
library(lubridate)
library(readxl)
library(rvest)

dest_folder <- "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/Temporales"


# Este es el IPC general
get_ipc <- function(){
  
  #link del excel del ipc del banrep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&NQUser=publico&NQPassword=publico123&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.5.IPC_Serie_variaciones"
  
  #se hace un print de que inicio el proceso
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
  year <- as.numeric(substr(d[,1],start=1,stop=4))
  ####se extrae el mes
  month <- as.numeric(substr(d[,1],start=5,stop=nchar(d[,1])))
  
  ###se construye la fecha
  dates_temp <- as.Date(paste(year,month,1,sep="/"),format="%Y/%m/%d")
  
  #se arreglan los nombres de las columnas
  names(d) <- c("date", "IPC")
  #se intercambia la columna de fecha por las fechas construidas
  d$date <- dates_temp
  #se ordena
  d <- d[order(d$date),]
  #se quitan los nombres de las filas
  rownames(d) <- NULL
  #se vuelven numeros las tasas
  d[,2] <- as.numeric(d[,2])
  #se anuncia cuantos datos se consiguieron
  message(paste0("Se obtuvo datos para el IPC desde ", d$date[1], " hasta ", d$date[nrow(d)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d)
  
}
macro_ipc_general <- get_ipc()

# Esta es la serie por doce ciudades
get_ipc_ciudades <- function(dest_folder){
  
  # Link del excel del IPC del BanRep
  link= "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.4.IPC_Por%20ciudad_IQY"
  #password = "&NQUser=publico&NQPassword=publico123"
  # Insertar la contraseña en la URL
  #link <- sub("&path", paste0(password, "&path"), link)
  
  # Mensaje de inicio del proceso
  message("Extrayendo datos, puede tomar unos minutos")
  
  # Crear un archivo temporal
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
  d3 <- d
  #se pasa la primera columna a numerico
  d3[,1] <- suppressWarnings(as.numeric(d3[,1]))
  ##se deja de una vez solo lo que no sea NA en ninguna de las dos columnas
  ##asi se borra tanto lo que era texto antes como lo que no tiene dato
  first_number <- function(columna) {
    return(which(!is.na(columna))[1])
  }
  
  # Mirar cual es la fila que comienza
  first_number_df <- as.numeric(first_number(d3[,1]))
  
  # Obtenemos el nombre de las columnas
  position_colnames <- first_number(d3[,1])-1
  
  names_df <-d3[position_colnames,]
  # Fijar la primera celda como date, es clave
  names_df[1,1]="date"
  names_df  <- as.character(names_df[1,])
  colnames(d3) <- c(names_df)
  
  # Hacer el primer filtro y quitar los NAs de arriba
  d3 <- d3[first_number_df:nrow(d3),]
  # El segundo filtro es detectando el primer NA a partir de la base
  
  first_na <- function(columna) {
    return(which(is.na(columna))[1])
  }
  
  limit_row <- as.numeric(first_na(d3[,1]))-1
  
  d3 <- d3[1:limit_row,]
  
  # pasar al formato excel
  if (is.numeric(d3[,1])) {
    # SI EL FORMATO ESTA EN EL FORMATO EXCEL 45170, 45173, ETC
    d3[,1] <- as.Date(d3[,1], origin = "1899-12-30")
  } else {
    # SI YA ESTA EN FORMATO DTTM, RELAX, ESTA OK. SOLO CONVERTIRLO A DATE PARA LUEGO USAR GGPLOT2
    d3[,1] <- as.Date(d3[,1])
  }
  # CONFIRMAMOS QUE SE HAYA CAMBIADO
  glimpse(d3)
  
  d3 <- d3 %>%
    mutate(date = lubridate::make_date(lubridate::year(d3[,1]), lubridate::month(d3[,1]), 1))
  # Cambia todas las columnas a numéricos
  glimpse(d3)
  
  d3[,2:ncol(d3)] <- data.frame(lapply(d3[,2:ncol(d3)], function(x) as.numeric(as.character(x))))
  glimpse(d3)
  
  #se ordena
  d3 <- d3[order(d3$date),]
  #se quitan los nombres de las filas
  rownames(d3) <- NULL
  #se vuelven numeros las tasas
  dplyr::glimpse(d3)
  
  #se anuncia cuantos datos se consiguieron
  message(paste0("Se obtuvo datos para el IPC desde ", d3$date[1], " hasta ", d3$date[nrow(d3)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d3)
  

}
macro_ipc_ciudades <- get_ipc_ciudades()
glimpse(macro_ipc_ciudades)

# Esta es la serie con las 12 principales clasificaciones
get_ipc_divisiones <- function(dest_folder){
  
  link= "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20IPC%20base%202018%2F1.2.%20Por%20a%C3%B1o%2F1.2.3.IPC_Por%20grupo%20de%20gasto_IQY"
  password = "&NQUser=publico&NQPassword=publico123"
  # Insertar la contraseña en la URL
  link <- sub("&path", paste0(password, "&path"), link)
  
  # Mensaje de inicio del proceso
  message("Extrayendo datos, puede tomar unos minutos")
  
  # Crear un archivo temporal
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
  d3 <- d
  #se pasa la primera columna a numerico
  d3[,1] <- suppressWarnings(as.numeric(d3[,1]))
  ##se deja de una vez solo lo que no sea NA en ninguna de las dos columnas
  ##asi se borra tanto lo que era texto antes como lo que no tiene dato
  first_number <- function(columna) {
    return(which(!is.na(columna))[1])
  }
  
  # Mirar cual es la fila que comienza
  first_number_df <- as.numeric(first_number(d3[,2]))+1
  
  # Obtenemos el nombre de las columnas
  position_colnames <- first_number(d3[,2])*1
  
  names_df <-d3[position_colnames,]
  # Fijar la primera celda como date, es clave
  names_df[1,1]="date"
  names_df  <- as.character(names_df[1,])
  colnames(d3) <- c(names_df)
  
  # Hacer el primer filtro y quitar los NAs de arriba
  d3 <- d3[first_number_df:nrow(d3),]
  # El segundo filtro es detectando el primer NA a partir de la base
  
  first_na <- function(columna) {
    return(which(is.na(columna))[1])
  }
  
  limit_row <- as.numeric(first_na(d3[,2]))-1
  
  d3 <- d3[1:limit_row,]
  
  start_date <- as.Date("2018-12-01")
  end_date <- start_date + months(nrow(d3) - 1)
  date_vector <- seq.Date(from = start_date, to = end_date, by = "month")
  
  d3$date <- date_vector
  
  
  # pasar al formato excel
  if (is.numeric(d3[,1])) {
    # SI EL FORMATO ESTA EN EL FORMATO EXCEL 45170, 45173, ETC
    d3[,1] <- as.Date(d3[,1], origin = "1899-12-30")
  } else {
    # SI YA ESTA EN FORMATO DTTM, RELAX, ESTA OK. SOLO CONVERTIRLO A DATE PARA LUEGO USAR GGPLOT2
    d3[,1] <- as.Date(d3[,1])
  }
  # CONFIRMAMOS QUE SE HAYA CAMBIADO
  glimpse(d3)
  
  d3 <- d3 %>%
    mutate(date = lubridate::make_date(lubridate::year(d3[,1]), lubridate::month(d3[,1]), 1))
  # Cambia todas las columnas a numéricos
  glimpse(d3)
  
  d3[,2:ncol(d3)] <- data.frame(lapply(d3[,2:ncol(d3)], function(x) as.numeric(as.character(x))))
  glimpse(d3)
  
  #se ordena
  d3 <- d3[order(d3$date),]
  #se quitan los nombres de las filas
  rownames(d3) <- NULL
  #se vuelven numeros las tasas
  dplyr::glimpse(d3)
  
  #se anuncia cuantos datos se consiguieron
  message(paste0("Se obtuvo datos para el IPC desde ", d3$date[1], " hasta ", d3$date[nrow(d3)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d3)
  
  
}
macro_ipc_divisiones <- get_ipc_divisiones()
glimpse(macro_ipc_divisiones)

# Este es en base en la nueva clasificacion de BanRep
get_ipc_principales <- function(dest_folder){
  
  # Link del excel del IPC del BanRep
  link= "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&lang=es&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F2.%20Nuevos%20indicadores%20IPC%2F2.3.%20Por%20rango%20de%20fechas%2F2.3.1.%20Nuevas%20medidas%20de%20inflacion%20clasificacion%20BANREP%20de%20la%20canasta%20del%20IPC%20-%20IQY"
  #password = "&NQUser=publico&NQPassword=publico123"
  # Insertar la contraseña en la URL
  #link <- sub("&path", paste0(password, "&path"), link)
  
  # Mensaje de inicio del proceso
  message("Extrayendo datos, puede tomar unos minutos")
  
  # Crear un archivo temporal
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
  d3 <- d
  #se pasa la primera columna a numerico
  d3[,1] <- suppressWarnings(as.numeric(d3[,1]))
  
  #Crear una función para detectar si alguna celda contiene los patrones deseados
  detectar_patrones <- function(columna) {
    return(any(grepl("Variación|Anual|%", columna)))
  }
  
  #Aplicar la función a cada columna
  columnas_a_eliminar <- sapply(d3, detectar_patrones)
  
  # Eliminar las columnas que contienen los patrones
  d3 <- d3[, !columnas_a_eliminar] 
  ##se deja de una vez solo lo que no sea NA en ninguna de las dos columnas
  ##asi se borra tanto lo que era texto antes como lo que no tiene dato
  first_number <- function(columna) {
    return(which(!is.na(columna))[1])
  }
  
  # Mirar cual es la fila que comienza
  first_number_df <- as.numeric(first_number(d3[,1]))
  
  # Obtenemos el nombre de las columnas
  position_colnames <- first_number(d3[,1])-2 # aca es menos dos porque abaja hay columna indice
  
  names_df <-d3[position_colnames,]
  # Fijar la primera celda como date, es clave
  names_df[1,1]="date"
  names_df  <- as.character(names_df[1,])
  colnames(d3) <- c(names_df)
  
  # Hacer el primer filtro y quitar los NAs de arriba
  d3 <- d3[first_number_df:nrow(d3),]
  # El segundo filtro es detectando el primer NA a partir de la base
  
  first_na <- function(columna) {
    return(which(is.na(columna))[1])
  }
  
  limit_row <- as.numeric(first_na(d3[,1]))-1
  
  d3 <- d3[1:limit_row,]
  
  # pasar al formato excel
  if (is.numeric(d3[,1])) {
    # SI EL FORMATO ESTA EN EL FORMATO EXCEL 45170, 45173, ETC
    d3[,1] <- as.Date(d3[,1], origin = "1899-12-30")
  } else {
    # SI YA ESTA EN FORMATO DTTM, RELAX, ESTA OK. SOLO CONVERTIRLO A DATE PARA LUEGO USAR GGPLOT2
    d3[,1] <- as.Date(d3[,1])
  }
  # CONFIRMAMOS QUE SE HAYA CAMBIADO
  glimpse(d3)
  
  d3 <- d3 %>%
    mutate(date = lubridate::make_date(lubridate::year(d3[,1]), lubridate::month(d3[,1]), 1))
  # Cambia todas las columnas a numéricos
  glimpse(d3)
  
  d3[,2:ncol(d3)] <- data.frame(lapply(d3[,2:ncol(d3)], function(x) as.numeric(as.character(x))))
  glimpse(d3)
  
  #se ordena
  d3 <- d3[order(d3$date),]
  #se quitan los nombres de las filas
  rownames(d3) <- NULL
  #se vuelven numeros las tasas
  dplyr::glimpse(d3)
  
  #se anuncia cuantos datos se consiguieron
  message(paste0("Se obtuvo datos para el IPC desde ", d3$date[1], " hasta ", d3$date[nrow(d3)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d3)
  
  
}
macro_ipc_principales <- get_ipc_principales()

library(purrr)
library(dplyr)
library(stringr)

# Paso 1: Obtener todos los nombres de objetos que comienzan con "macro_"
macro_objects <- ls(pattern = "^macro_ipc")

# Paso 2: Crear una lista de estos dataframes
macro_list <- mget(macro_objects)

# Paso 3: Realizar el left join
result <- macro_list %>%
  reduce(function(x, y) left_join(x, y, by = "date"))

# Si necesitas renombrar las columnas para evitar duplicados, puedes agregar:
# result <- result %>%
#   rename_with(~str_c(., "_", names(macro_list)[which(map_lgl(macro_list, ~"date" %in% names(.)))]),
#               .cols = -date)


#########################################
############### PIB ####################
########################################

# Este es el IPC general
get_pib <- function(){
  
  #link del excel del ipc del banrep
  link <- "https://totoro.banrep.gov.co/analytics/saw.dll?Download&Format=excel2007&Extension=.xls&BypassCache=true&path=%2Fshared%2FSeries%20Estad%C3%ADsticas_T%2F1.%20PIB%2F1.%202015%2F1.1%20PIB_Precios%20corrientes%20grandes%20ramas%20de%20actividades%20economicas_IQY&SyncOperation=1&lang=es"
  
  #se hace un print de que inicio el proceso
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
  year <- as.numeric(substr(d[,1],start=1,stop=4))
  ####se extrae el mes
  month <- as.numeric(substr(d[,1],start=5,stop=nchar(d[,1])))
  
  ###se construye la fecha
  dates_temp <- as.Date(paste(year,month,1,sep="/"),format="%Y/%m/%d")
  
  #se arreglan los nombres de las columnas
  names(d) <- c("date", "IPC")
  #se intercambia la columna de fecha por las fechas construidas
  d$date <- dates_temp
  #se ordena
  d <- d[order(d$date),]
  #se quitan los nombres de las filas
  rownames(d) <- NULL
  #se vuelven numeros las tasas
  d[,2] <- as.numeric(d[,2])
  #se anuncia cuantos datos se consiguieron
  message(paste0("Se obtuvo datos para el IPC desde ", d$date[1], " hasta ", d$date[nrow(d)] ))
  message("Fuente: Banco de la Republica de Colombia")
  #se returna el data frame
  return(d)
  
}
macro_ipc_general <- get_ipc()


