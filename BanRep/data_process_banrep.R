library(readxl)
library(openxlsx)
library(tidyverse)

path_excel = "C:/Users/ntorreslo/OneDrive - Telefonica/Research/Data collection/Colombia/Originals/BanRep_IPC_basico.xlsx"
# Leer las primeras filas del archivo para encontrar dónde comienzan los datos
preview <- read_excel(path_excel, n_max = 100)

first_row <- which(grepl("Año", preview[[1]]) | grepl("Año", preview[[2]]))[1]
# Leer los datos a partir de esa fila
data <- read_excel(path_excel, skip = first_row - 1)
# Eliminar las columnas que contienen "Variación anual"
cols_to_remove <- colnames(data)[sapply(data, function(x) any(grepl("Variación|Variacion", x)))]
data <- data %>% select(-all_of(cols_to_remove))
