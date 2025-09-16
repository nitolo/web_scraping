
#################################################
########## RECOLECCION PIB COLOMBIA BANREP ######
#################################################
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global
library(rvest)
library(httr)
library(readxl)
####### TASA DE DESEMPLEO NORMAL

dest_folder <- "C:/Users/ntorreslo/OneDrive - Telefonica/Research/Data collection/Colombia/Originals"



