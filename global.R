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

# === MÓDULO AMBIENTAL - INICIO ===
# Carga de datos ambientales
load("datos/Ambiental/aicas.RData")
load("datos/Ambiental/sistema_arrecifal_tamaulipas.RData")
load("datos/Ambiental/rtp.RData")
load("datos/Ambiental/rmp.RData")
load("datos/Ambiental/lm_ramsar.RData")
load("datos/Ambiental/rn_ramsar.RData")
load("datos/Ambiental/hidro_tam_nl_coa.RData")
# === MÓDULO AMBIENTAL - FIN ===


# === MÓDULO BUFFERS RIESGO ===
# Carga de datos de temperatura
load("datos/Buffers/buff1_300F_50m.RData")
load("datos/Buffers/buff1_212F_482m.RData")
load("datos/Buffers/buff1_90F_965m.RData")

#Carga de datos de ruido
load("datos/Buffers/buff2_140db_804m.RData")
load("datos/Buffers/buff2_130db_5471m.RData")
load("datos/Buffers/buff2_120db_15288m.RData")
load("datos/Buffers/buff2_111db_36210m.RData")

#Carga de datos de sonic boom
load("datos/Buffers/buff3_6psf_16093m.RData")
load("datos/Buffers/buff3_4psf_24140m.RData")
load("datos/Buffers/buff3_2psf_43452m.RData")
load("datos/Buffers/buff3_1psf_45061m.RData")
# === MÓDULO BUFFERS RIESGO - FIN ===


# Crear el objeto GeoJSON para la capa de Laguna Madre
lag_madre_geojson <- geojsonio::geojson_json(lag_madre)

# Crear el objeto GeoJSON para la capa de Playa Bagdad
playa_bagdad_geojson <- geojsonio::geojson_json(playa_bagdad)

# Crear el objeto GeoJSON para la capa de Dv
dv_layer_geojson <- geojsonio::geojson_json(dv_layer)


# === MÓDULO AMBIENTAL - INICIO ===

# Crear el objeto GeoJSON para la capa de Aicas
aicas_layer_geojson <- geojsonio::geojson_json(aicas)

# Crear el objeto GeoJSON para la capa de Sistema Arrecifal Artificial
sistema_arrecifal_tamaulipas_layer_geojson <- geojsonio::geojson_json(sistema_arrecifal_tamaulipas)

# Crear el objeto GeoJSON para la capa de Regiones Terrestres Prioritarias
rtp_layer_geojson <- geojsonio::geojson_json(rtp)

# Crear el objeto GeoJSON para la capa de Regiones Marinas Prioritarias
rmp_layer_geojson <- geojsonio::geojson_json(rmp)

# Crear el objeto GeoJSON para la capa de lm_ramsar
lm_ramsar_layer_geojson <- geojsonio::geojson_json(lm_ramsar)

# Crear el objeto GeoJSON para la capa de rn_ramsar
rn_ramsar_layer_geojson <- geojsonio::geojson_json(rn_ramsar)

# Crear el objeto GeoJSON para la capa de hidro_tam_nl_coa
hidro_tam_nl_coa_layer_geojson <- geojsonio::geojson_json(hidro_tam_nl_coa)

# === MÓDULO AMBIENTAL - FIN ===


# === MÓDULO BUFFERS RIESGO - INICIO ===


### Temperatura
# Crear el objeto GeoJSON para la capa de buff1_300F_50m
buff1_300F_50m_layer_geojson <- geojsonio::geojson_json(buff1_300F_50m)

# Crear el objeto GeoJSON para la capa de buff1_212F_482m
buff1_212F_482m_layer_geojson <- geojsonio::geojson_json(buff1_212F_482m)

# Crear el objeto GeoJSON para la capa de buff1_90F_965m
buff1_90F_965m_layer_geojson <- geojsonio::geojson_json(buff1_90F_965m)

### Ruido
# Crear el objeto GeoJSON para la capa de buff2_140db_804m
buff2_140db_804m_layer_geojson <- geojsonio::geojson_json(buff2_140db_804m)

# Crear el objeto GeoJSON para la capa de buff2_130db_5471m
buff2_130db_5471m_layer_geojson <- geojsonio::geojson_json(buff2_130db_5471m)

# Crear el objeto GeoJSON para la capa de buff2_120db_15288m
buff2_120db_15288m_layer_geojson <- geojsonio::geojson_json(buff2_120db_15288m)

# Crear el objeto GeoJSON para la capa de buff2_111db_36210m
buff2_111db_36210m_layer_geojson <- geojsonio::geojson_json(buff2_111db_36210m)


### Sonic Boom
# Crear el objeto GeoJSON para la capa de buff3_1psff_45061m
buff3_1psff_45061m_layer_geojson <- geojsonio::geojson_json(buff3_1psf_45061m)

# Crear el objeto GeoJSON para la capa de buff3_2psf_43452m
buff3_2psf_43452m_layer_geojson <- geojsonio::geojson_json(buff3_2psf_43452m)

# Crear el objeto GeoJSON para la capa de buff3_4psf_24140m
buff3_4psf_24140m_layer_geojson <- geojsonio::geojson_json(buff3_4psf_24140m)

# Crear el objeto GeoJSON para la capa de buff3_6psf_16093m
buff3_6psf_16093m_layer_geojson <- geojsonio::geojson_json(buff3_6psf_16093m)

# === MÓDULO BUFFERS RIESGO - FIN ===


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
#AMBIENTAL
n_aicas <- 0
n_sat <- 0
n_rtp <- 0
n_rmp <- 0
n_lmramsar <- 0
n_rnramsar <- 0
n_hidro_tam_nl_coa <- 0
#BUFFERS RIESGO
n_buff1_300F_50m <- 0
n_buff1_212F_482m <- 0
n_buff1_90F_965m <- 0
n_buff2_140db_804m <- 0
n_buff2_130db_5471m <- 0
n_bbuff2_120db_15288m <- 0
n_buff2_111db_36210m <- 0
n_buff3_6psf_16093m <- 0
n_buff3_4psf_24140m <- 0
n_buff3_2psf_43452m <- 0
n_buff3_1psff_45061m <- 0


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