# Script para optimizar datos espaciales y mejorar el rendimiento
# Ejecutar este script una vez para optimizar todos los datos

library(sf)
library(dplyr)

# Función para simplificar geometrías
simplify_geometries <- function(sf_object, tolerance = 0.0001) {
  if (inherits(sf_object, "sf")) {
    # Simplificar geometrías para reducir el tamaño
    sf_object$geometry <- st_simplify(sf_object$geometry, dTolerance = tolerance)
    return(sf_object)
  }
  return(sf_object)
}

# Función para optimizar datos espaciales
optimize_spatial_data <- function(file_path, output_path = NULL, tolerance = 0.0001) {
  cat("Optimizando:", file_path, "\n")
  
  # Cargar datos
  load(file_path)
  
  # Obtener el nombre del objeto cargado
  data_name <- ls()[!ls() %in% c("file_path", "output_path", "tolerance", "simplify_geometries", "optimize_spatial_data")]
  
  if (length(data_name) > 0) {
    data_obj <- get(data_name[1])
    
    # Simplificar geometrías si es un objeto espacial
    if (inherits(data_obj, "sf")) {
      cat("Simplificando geometrías...\n")
      data_obj <- simplify_geometries(data_obj, tolerance)
      
      # Remover columnas innecesarias si existen
      if ("AREA" %in% names(data_obj)) {
        data_obj$AREA <- NULL
      }
      if ("PERIMETER" %in% names(data_obj)) {
        data_obj$PERIMETER <- NULL
      }
    }
    
    # Guardar datos optimizados
    if (is.null(output_path)) {
      output_path <- file_path
    }
    
    # Usar compresión para reducir el tamaño del archivo
    save(list = data_name[1], file = output_path, compress = TRUE)
    
    cat("Optimización completada:", output_path, "\n")
  }
}

# Lista de archivos a optimizar
files_to_optimize <- c(
  "datos/Ambiental/uso_suelo_mat.RData"
)

# Optimizar cada archivo
for (file in files_to_optimize) {
  if (file.exists(file)) {
    tryCatch({
      optimize_spatial_data(file)
    }, error = function(e) {
      cat("Error optimizando", file, ":", e$message, "\n")
    })
  } else {
    cat("Archivo no encontrado:", file, "\n")
  }
}

cat("Optimización de datos completada.\n")

# Crear archivo de configuración para el rendimiento
performance_config <- list(
  lazy_loading = TRUE,
  data_compression = TRUE,
  geometry_simplification = TRUE,
  cache_enabled = TRUE,
  max_memory_usage = "2GB"
)

save(performance_config, file = "datos/performance_config.RData")
cat("Configuración de rendimiento guardada.\n") 