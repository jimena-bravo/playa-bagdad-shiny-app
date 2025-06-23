# Configuración para Google Maps API
# Este archivo contiene la configuración para integrar Google Maps en la aplicación

# Configuración de la API de Google Maps
GOOGLE_MAPS_CONFIG <- list(
  api_key = "AIzaSyAIRgGl8v3tT73-smAh5FwUEGSqZlGCmls",
  
  # Configuración del mapa
  map_center = list(
    lat = 25.9167,  # Latitud de Playa Bagdad
    lng = -97.1500  # Longitud de Playa Bagdad
  ),
  
  # Zoom inicial del mapa
  default_zoom = 12,
  
  # Tipos de lugares disponibles
  place_types = list(
    "Todos los tipos" = "all",
    "Escuelas" = "school",
    "Restaurantes" = "restaurant", 
    "Hospitales" = "hospital",
    "Gasolineras" = "gas_station",
    "Bancos" = "bank",
    "Farmacias" = "pharmacy",
    "Hoteles" = "lodging",
    "Tiendas" = "store",
    "Parques" = "park",
    "Iglesias" = "church",
    "Oficinas de gobierno" = "local_government_office",
    "Estaciones de policía" = "police",
    "Bomberos" = "fire_station",
    "Oficinas de correos" = "post_office",
    "Bibliotecas" = "library",
    "Museos" = "museum",
    "Teatros" = "movie_theater",
    "Gimnasios" = "gym",
    "Veterinarias" = "veterinary_care"
  ),
  
  # Radio de búsqueda por defecto (en km)
  default_search_radius = 5,
  
  # Límites de búsqueda
  search_limits = list(
    min_radius = 1,
    max_radius = 50
  )
)

# Función para obtener la URL de la API con la clave
get_google_maps_api_url <- function() {
  if (GOOGLE_MAPS_CONFIG$api_key == "YOUR_GOOGLE_API_KEY_HERE") {
    warning("⚠️  No se ha configurado la API key de Google Maps. 
            La funcionalidad de Google Maps no funcionará correctamente.")
    return("https://maps.googleapis.com/maps/api/js?key=DEMO_KEY&libraries=places&callback=initMap")
  }
  
  paste0("https://maps.googleapis.com/maps/api/js?key=", 
         GOOGLE_MAPS_CONFIG$api_key, 
         "&libraries=places&callback=initMap")
}

# Función para verificar si la API key está configurada
is_google_maps_configured <- function() {
  GOOGLE_MAPS_CONFIG$api_key != "YOUR_GOOGLE_API_KEY_HERE"
}

# Función para obtener la configuración del mapa
get_map_config <- function() {
  list(
    center = GOOGLE_MAPS_CONFIG$map_center,
    zoom = GOOGLE_MAPS_CONFIG$default_zoom,
    place_types = GOOGLE_MAPS_CONFIG$place_types,
    default_radius = GOOGLE_MAPS_CONFIG$default_search_radius,
    limits = GOOGLE_MAPS_CONFIG$search_limits
  )
}