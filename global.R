# Cargar librerías necesarias  -----
library(sf)
library(dplyr)
library(magrittr)
library(ggplot2)
library(stringr)
library(lubridate)
library(highcharter)
library(shinymanager)
library(geojsonio)

# Cargar configuración de Google Maps
source("google_maps_config.R")

options(scipen = 999)

# Establecer el directorio de trabajo solo para pruebas. Al desplegarse la app esta 
# línea debe estar comentada forzosamente
# setwd("C:/Users/marco.vasquez/Documents/PROFEPA/PROFEPA/reincidencia_infracciones/RIA/")

# Funciones para homologar campos (eliminar espacios innecesarios y reemplazar caracteres especiales) ----
reemplazar_espacios <- function(texto) {
  for (i in 30:2) {
    texto <- gsub(paste0(strrep(" ", i)), " ", texto)
  }
  return(texto)
}
homologacion_basica <- function(cadena){
  cadena %<>% toupper()
  cadena %<>% 
    str_replace_all(
      c("Á" = "A", "É" = "E", "Í" = "I", "Ó" = "O", "Ú" = "U", "," = "", "C. V." = "C.V.",
        "[.]" = "", "[*]" = "", "[+]" = "", "^ " = "", " $" = "", "DE C V" = "DE CV"))
  return(cadena)
}

# Función para carga diferida de datos
load_data_lazy <- function(data_name) {
  if (!exists(data_name, envir = .GlobalEnv)) {
    load(paste0("datos/", data_name, ".RData"), envir = .GlobalEnv)
  }
  return(get(data_name, envir = .GlobalEnv))
}

# Carga de datos críticos solo al inicio (los más pequeños y necesarios)
load("datos/playa_bagdad.RData")
load("datos/lag_madre.RData")
load("datos/puntos.RData")
load("datos/dv_layer.RData")

# Crear el objeto GeoJSON para la capa de Laguna Madre
lag_madre_geojson <- geojsonio::geojson_json(lag_madre)

# Crear el objeto GeoJSON para la capa de Playa Bagdad
playa_bagdad_geojson <- geojsonio::geojson_json(playa_bagdad)

# Crear el objeto GeoJSON para la capa de Dv
dv_layer_geojson <- geojsonio::geojson_json(dv_layer)

# Registrar la carpeta de fotos para que Shiny pueda servir las imágenes
addResourcePath("gallery_photos", "fotos_conanp")

# Variables auxiliares para datos críticos
n_playa <- nrow(playa_bagdad)
n_lagm <- nrow(lag_madre)
n_puntos <- nrow(puntos)

# Carga diferida de datos pesados - se cargarán solo cuando se necesiten
# load("datos/multas_sanciones.RData")  # 14MB - se cargará cuando se necesite
# load("datos/shapes_mexico.RData")     # 3.5MB - se cargará cuando se necesite
# load("datos/municipios.RData")        # 838KB - se cargará cuando se necesite
# load("datos/ageb_rural.RData")        # 2.3MB - se cargará cuando se necesite
# load("datos/ageb_urbano.RData")       # 1.4MB - se cargará cuando se necesite
# load("datos/localidad_amanzanada.RData") # 1.6MB - se cargará cuando se necesite
# load("datos/localidad_puntual.RData") # 367KB - se cargará cuando se necesite
# load("datos/manzana.RData")           # 10MB - se cargará cuando se necesite
# load("datos/vialidad.RData")          # 12MB - se cargará cuando se necesite

# Inicializar variables para datos pesados como NULL
municipios <- NULL
ageb_rural <- NULL
ageb_urbano <- NULL
localidad_amanzanada <- NULL
localidad_puntual <- NULL
manzana <- NULL
vialidad <- NULL
sanciones <- NULL
multas <- NULL
agee <- NULL
agem <- NULL

# Variables auxiliares inicializadas como 0
n_muns <- 0
n_agebr <- 0
n_agebu <- 0
n_lmnz <- 0
n_lpunt <- 0
n_mnz <- 0
n_vial <- 0

# Crear los dataframe de agem y agee para hacer joins (solo cuando se carguen)
df_agee <- NULL
df_agem <- NULL

# Creación de varibles auxilaes (solo cuando se carguen los datos)
# sanciones <- sanciones %>%
#   mutate(fecha_orden_inicio_mes = floor_date(fecha_orden, "month"))
# sanciones <- sanciones %>%
#   mutate(fecha_orden_inicio_mes_txt = format(fecha_orden_inicio_mes, "%Y-%m"))
# sanciones$mes_anio <- format(sanciones$fecha_orden, "%Y-%m") 

# Crear variable de anio de orden para las multas
# multas$anio_orden <- format(as.Date(multas$fecha_de_visita), "%Y")

meses <- c("Todos", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", 
           "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")

# Tema usado en las gráficas de ggplot de la app
mi_tema <- theme(
  plot.title = element_text(size = 24, face = "bold", hjust = 0.5),  # Título centrado
  axis.title = element_text(size = 20, face = "bold"),  # Títulos de ejes
  axis.text.y = element_text(size = 12.5),
  plot.subtitle = element_text(size = 20, face = "bold", hjust = 0.5),  # Título centrado
  axis.text.x = element_text(size = 10, hjust = 1), 
  plot.margin = margin(10, 10, 40, 10), 
  panel.background = element_rect(fill = "transparent", color = NA),  # fondo panel transparente
  plot.background = element_rect(fill = "transparent", color = NA)   # fondo total transparente
  # legend.title = element_text(size = 14, face = "bold"),  # Título de la leyenda
  # legend.text = element_text(size = 12),  # Texto de la leyenda
  # strip.text = element_text(size = 14, face = "bold"),  # Texto en facetas
  # plot.caption = element_text(size = 12, hjust = 1)  # Pie de gráfico
)

# Definir la contraseña de acceso al RIA -----
# PASSWORD <- "1"


credentials <- data.frame(
  user = c("mariana.boy", "jimena.bravo", "leticia.quinones", "adan.martinez", "hector.huerta", "monica.toledo", "alejandra.sanchez", "alma.arrazola", "luis.ortega", "nastienka.perez"), # obligatorio
  password = c("profepa159", "profepa159", "profepa159", "profepa159", "profepa159", "profepa159", "profepa159", "profepa159", "profepa159", "profepa159"),   # obligatorio
  # start = c("2019-04-15", NA),       # opcional
  # expire = c(NA, "2019-12-31"),
  # admin = c(FALSE, TRUE),
  comment = "Autenticación segura para apps Shiny.",
  stringsAsFactors = FALSE
)