#################################################
########## INFORME TRIMESTRAL PIB COLOMBIA ######
#################################################
cat("\014") # Limpiar la consola
while(dev.cur() > 1) dev.off() # Limpiar todos los gráficos
rm(list = ls()) # Limpiar el entorno global

library(tidyverse) # Data operators functions
library(readxl) # Create a Excel Worksheets
library(janitor) # Clean columns' names
library(openxlsx) # Export 2Excel
library(camcorder) # Record the ggplot evolution
library(lubridate)
library(ggimage) 
library(scales)
library(extrafont) # New fonts
library(mFilter)
# Cargar las fuentes en el dispositivo gráfico
loadfonts(device = "win")

ruta_excel = "Z:/03_Investigaciones_Economicas/2. Monitores/Colombia/2. Dashboard/Trimestral/"

libro = "1. GDP_informe_trimestral.xlsx"
hoja = "Datos_CE"
hoja_1 = "Datos"
hoja_2 = "Dashboard"

# ISE con estacionalidad
df <- read_excel(paste0(ruta_excel, libro),sheet = hoja) %>% clean_names() 
df <- df[,1:10]
glimpse(df)
# ISE sin estacionalidad
df_1 <- read_excel(paste0(ruta_excel, libro),sheet = hoja_1) %>% clean_names() 
df_1 <- df[,1:10]
glimpse(df_1)
#df <- df[-nrow(df),]

df$date <- as.Date(df$date)
df_1$date <- as.Date(df_1$date)

# Obtener el año y el mes actual
actual_year <- year(max(df$date))
actual_month <- month(max(df$date))

# Función para calcular los promedios y las variaciones
calculos <- function(df, df_1, periodo) {
  # Obtener el año y el mes actual
  actual_year <- year(max(df$date))
  actual_month <- month(max(df$date))
  
  # Obtener el año y el mes pasado
  last_year <- actual_year - 1
  last_month <- actual_month - 1
  
  # Obtenemos la última fecha
  max_date = max(df$date)
  
  if (periodo == "YTD") {
    df_actual <- df %>% 
      filter(year(date) == actual_year) 
    df_last <- df %>% 
      filter(year(date) == last_year & month(date) <= actual_month) 
  } else if (periodo == "YoY") {
    df_actual <- df %>% 
      filter(year(date) == actual_year & month(date) == actual_month) 
    df_last <- df %>% 
      filter(year(date) == last_year & month(date) == actual_month) 
  } else if (periodo == "QoQ") {
    df_pop <- df %>%
      mutate(across(-date, ~ (. - lag(.)) / lag(.))) %>% 
      filter(date==max_date)
  }
  if (periodo == "YTD" | periodo =="YoY"){
    # Calcular el promedio de todas las columnas
    avg_actual <- colMeans(df_actual[,-1], na.rm = TRUE)
    avg_last <- colMeans(df_last[,-1], na.rm = TRUE)
    
    # Calcular la variación
    df_variacion <- avg_actual / avg_last - 1
  } else if (periodo == "QoQ"){
    df_variacion <- colMeans(df_pop[,-1], na.rm = TRUE)
  }
  
  # Convertir a dataframe
  df_variacion <- as.data.frame(df_variacion)
  
  # Asignar nombres a las columnas
  names(df_variacion) <- periodo
  
  return(df_variacion)
}

# Llamar a la función para calcular YTD, YoY y MoM
df_ytd_1 <- calculos(df, df, "YTD")
df_yoy_1 <- calculos(df, df, "YoY")
df_qoq_1 <- calculos(df, df, "QoQ")

# Unir los dataframes
df_final <- cbind(df_qoq_1, df_yoy_1, df_ytd_1)
# Lee el archivo de Excel existente
wb <- loadWorkbook(paste0(ruta_excel,libro))
# Escribe los datos en la hoja especificada a partir de la celda a2
writeData(wb, sheet = hoja_2, df_final, startCol = 3, startRow = 5, colNames = F, rowNames = F)
# Guarda los cambios en el archivo de Excel
saveWorkbook(wb, paste0(ruta_excel,libro), overwrite = TRUE)
##############################################
############## PLOTS #########################
##############################################
df_2 <- df_1 %>% 
  select(date, pib = pib)

# Cálculo de filtro H&P 
hp_filter_general <- function(df, variable, lambda) {
  # Estimación del filtro H&P
  hp_result <- hpfilter(df[[variable]], type="lambda", freq=lambda)
  # Creación del data frame del filtro H&P
  df_hp <- data.frame(
    date = df$date,
    trend = hp_result$trend,
    value = hp_result$x,
    cycle = hp_result$cycle,
    gap = hp_result$x / hp_result$trend - 1
  )
  # Convertir la fecha a formato de fecha solo si lambda no es 100
  if (lambda != 100) {
    df_hp$date <- as.Date(df_hp$date)
  }
  return(df_hp)
}

df_2 <- hp_filter_general(df= df_2, variable = "pib", lambda= 1600)

# Obtén la última fecha
last_date <- max(df_2$date)

# Crea un vector para almacenar los últimos valores
last_values <- lapply(df_2[, -which(names(df_2) == "date")], function(x) x[df_2$date == last_date])

# Convierte el vector en un dataframe
last_values_df <- as.data.frame(last_values)

dates_x_axis = df_2$date

# Primero, necesitarás calcular el promedio por año
df_2$year <- year(df_2$date)  # Añade una columna con el año
df_2$avg <- ave(df_2$value, df_2$year, FUN = mean)  # Calcula el promedio por año
df_2 <- df_2 %>% 
  mutate(ytd = avg/lag(avg)-1)
glimpse(df_2)

# Obtenemos el mes de la fecha máxima
max_month = month(max(dates_x_axis))

# Filtramos el dataframe para obtener solo las filas que corresponden al mes máximo
filtered_dates = dates_x_axis[month(dates_x_axis) == max_month]

# We plot

uno <- last_values_df$value
dos <- last_values_df$trend
tres <- NA
cuatro <- NA
cinco <- NA

col_uno <- "#52C4CC"
col_dos <- "#99E5FF"
col_tres <- "#003FFF"
col_cuatro <- "#836FFF"

f1 = "Arial Narrow"

# Calcula la fecha de hace diez años
ten_years <- as.Date(paste0(year(max(df_2$date)) - 10, "-", format(max(df_2$date), "%m"), "-01"))

df_2 <- df_2 %>%
  filter(date >= ten_years)

glimpse(df_2)

df_enero <- df_2 %>% filter(format(date, "%m") == "01")

df_2$tasa_crecimiento_texto <- paste0(round(df_2$ytd * 100, 1), "%")

# Crea la gráfica
gg_1 <- df_2 %>%
  ggplot(aes(x=date)) +
  geom_vline(aes(xintercept=(as.Date("2020-03-31"))), color ="#D2BFAB", linetype="dashed", linewidth = 0.9)+
  geom_line(aes(y=value, color="PIB"), linewidth = .9) +
  geom_line(aes(y=trend, color="Tendencia"), linewidth = .9) +
  scale_color_manual(values=c("PIB"=col_uno, "Tendencia"=col_dos))+
  labs(color=" ", y=" ", x= " "
       , title="PIB Potencial"
       , subtitle = "(sin estacionalidad en términos de 2015)"
  ) +
  theme_minimal(base_family = f1) +
  theme(plot.title = element_text(hjust = 0.5, face="bold", size = 15, colour = "#0E2841")
        , plot.subtitle = element_text(hjust = 0.5, face = "italic", size=12, colour = "#7F7F7F")
        , axis.line.x = element_line(colour = "black")
        , axis.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5)
        , axis.text = element_text(size = 10)
        , axis.ticks.x = element_line(color = "#212121", size = 0.3)
        , panel.grid.minor.y = element_blank()
        , panel.grid.minor.x = element_blank()
        , panel.grid.major.x = element_blank()
        #, panel.grid.major.y = element_blank()
        , plot.margin = margin(t = 2, r= 32, l=-5.5, b=0)
        , legend.margin = margin(-4)
        , legend.position="top"
        , legend.text = element_text(size = 11)
  )+ 
  annotate("text", x=last_date, y=uno, label=round(uno,0), hjust=0, vjust=0.5, col=col_uno, size=4, family = f1, fontface = "bold")+
  annotate("text", x=last_date, y=dos, label=round(dos,0), hjust=0, vjust=-0.5, col=col_dos, size=4, family = f1, fontface = "bold")+
  annotate("text", x=as.Date("2019-05-31"), y=Inf, vjust = 1, label="Pandemia", col = "#D2BFAB", size=4, family = f1)+
  annotate("curve", x = as.Date("2019-05-31"), xend = as.Date("2020-03-31"), y= 255000, yend = 240000, arrow = arrow(length = unit(0.1, "inch"), ), size = 0.9, color = "#D2BFAB") +
  coord_cartesian(clip = "off", expand = F) +
  scale_x_date(breaks = c(as.Date(filtered_dates)), date_labels =  "%b%Y")+
  scale_y_continuous(labels = comma
    , breaks = seq(180000,260000,16000)
    , limits = c(180000, 260000)
    )


gg_1

# Guarda la gráfica como un archivo JPEG
plot_name = "1. PIB_trimestral"

height <- 5.5
width <- 8

ggsave(filename = paste0(ruta_excel, plot_name, ".png"), plot = gg_1, dpi = 320, width=width, height=height)
ggsave(filename = paste0(ruta_excel, plot_name, ".svg"), plot = gg_1, dpi = 320, width=width, height=height)
ggsave(filename = paste0(ruta_excel, plot_name, ".pdf"), plot = gg_1, dpi = 320, width=width, height=height)




# # Primero, necesitarás crear un dataframe con tus datos
# df <- data.frame(
#   categoria = c("Oferta", "Oferta", "Oferta", "Demanda", "Demanda", "Demanda", "Demanda"),
#   subcategoria = c("Importaciones", "PBI", "Exportaciones", "Consumo de los Hogares", "Gasto del Gobierno", "Inversión", "Inversión"),
#   valor = c(-5.3, 0.4, 0.8, 0.6, 1.4, -8.2, -8.2)
# )
# 
# # Ahora puedes crear el gráfico de barras con ggplot2
# ggplot(df, aes(x = subcategoria, y = valor, fill = categoria)) +
#   geom_bar(stat = "identity", position = position_dodge()) +
#   geom_vline(xintercept = 3.5, linetype = "dashed", color = "red") +  # Línea vertical roja punteada
#   labs(title = "PBI Var % YTD 1S24", x = "", y = "") +
#   theme_minimal() +
#   theme(legend.position = "none") 
