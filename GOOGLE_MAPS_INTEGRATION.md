# 🗺️ Integración de Google Maps - App Playa Bagdad

## 🎯 Funcionalidades Implementadas

### **Búsqueda de Lugares**
- ✅ Búsqueda por nombre (escuelas, restaurantes, hospitales, etc.)
- ✅ Filtrado por tipo de lugar
- ✅ Configuración de radio de búsqueda
- ✅ Resultados en tiempo real

### **Visualización en Mapa**
- ✅ Marcadores interactivos con información detallada
- ✅ Ventanas de información con ratings, horarios, dirección
- ✅ Lista de resultados clickeable
- ✅ Centrado automático en los resultados

### **Tipos de Lugares Disponibles**
- 🏫 **Educación**: Escuelas, bibliotecas
- 🏥 **Salud**: Hospitales, farmacias, veterinarias
- 🍽️ **Alimentación**: Restaurantes, tiendas
- ⛽ **Servicios**: Gasolineras, bancos, oficinas de correos
- 🏨 **Hospedaje**: Hoteles, alojamientos
- 🏛️ **Gobierno**: Oficinas gubernamentales, policía, bomberos
- 🎭 **Entretenimiento**: Parques, museos, teatros, gimnasios
- ⛪ **Religión**: Iglesias

## 🚀 Configuración Inicial

### **Paso 1: Obtener API Key de Google Maps**

1. **Ve a Google Cloud Console**:
   ```
   https://console.cloud.google.com/
   ```

2. **Crea un nuevo proyecto** o selecciona uno existente

3. **Habilita las APIs necesarias**:
   - Maps JavaScript API
   - Places API
   - Geocoding API

4. **Crea una API Key**:
   - Ve a "Credentials" → "Create Credentials" → "API Key"
   - Copia la clave generada

5. **Configura restricciones** (recomendado):
   - Restringe por dominio HTTP
   - Restringe por IP si es necesario

### **Paso 2: Configurar la Aplicación**

1. **Edita el archivo `google_maps_config.R`**:
   ```r
   # Reemplaza esta línea:
   api_key = "YOUR_GOOGLE_API_KEY_HERE"
   
   # Con tu clave real:
   api_key = "AIzaSyC_tu_clave_real_aqui"
   ```

2. **O usa variables de entorno** (más seguro):
   ```r
   # En google_maps_config.R
   api_key = Sys.getenv("GOOGLE_MAPS_API_KEY")
   ```

### **Paso 3: Probar la Integración**

1. **Ejecuta la aplicación**:
   ```r
   shiny::runApp()
   ```

2. **Ve a la pestaña "Google Maps - Lugares"**

3. **Prueba la búsqueda**:
   - Busca "escuelas" en Playa Bagdad
   - Selecciona "Restaurantes" como tipo
   - Ajusta el radio de búsqueda

## 💡 Ejemplos de Uso

### **Búsqueda de Escuelas**
```
Término: "escuela"
Tipo: school
Radio: 3 km
```

### **Búsqueda de Servicios Médicos**
```
Término: "hospital"
Tipo: hospital
Radio: 10 km
```

### **Búsqueda de Restaurantes**
```
Término: "mariscos"
Tipo: restaurant
Radio: 5 km
```

## 🔧 Personalización Avanzada

### **Agregar Nuevos Tipos de Lugares**

Edita `google_maps_config.R`:
```r
place_types = list(
  # ... tipos existentes ...
  "Nuevo tipo" = "nuevo_tipo_google"
)
```

### **Cambiar el Centro del Mapa**

```r
map_center = list(
  lat = 25.9167,  # Nueva latitud
  lng = -97.1500  # Nueva longitud
)
```

### **Personalizar el Estilo del Mapa**

Edita `www/google_maps.js`:
```javascript
map = new google.maps.Map(document.getElementById("google_map"), {
  center: playaBagdad,
  zoom: 12,
  styles: [
    // Agrega estilos personalizados aquí
  ]
});
```

## ⚠️ Consideraciones Importantes

### **Costos de la API**
- **Gratis**: $200 de crédito mensual
- **Después**: $0.017 por 1000 solicitudes de Places API
- **Monitoreo**: Revisa el uso en Google Cloud Console

### **Límites de Uso**
- **Places API**: 100,000 solicitudes por día
- **Maps JavaScript API**: Sin límite de carga
- **Geocoding API**: 2,500 solicitudes por día

### **Seguridad**
- ✅ **Nunca** subas tu API key a repositorios públicos
- ✅ Usa restricciones de dominio/IP
- ✅ Considera usar variables de entorno
- ✅ Monitorea el uso regularmente

## 🐛 Solución de Problemas

### **Error: "Google Maps API error"**
- Verifica que la API key sea correcta
- Confirma que las APIs estén habilitadas
- Revisa las restricciones de la API key

### **No aparecen resultados**
- Verifica que el término de búsqueda sea válido
- Aumenta el radio de búsqueda
- Prueba con diferentes tipos de lugares

### **El mapa no se carga**
- Verifica la conexión a internet
- Revisa la consola del navegador para errores
- Confirma que el archivo `google_maps.js` esté incluido

### **Límites de cuota excedidos**
- Revisa el uso en Google Cloud Console
- Considera implementar caché de resultados
- Optimiza las consultas para reducir llamadas

## 📊 Monitoreo y Optimización

### **Monitorear Uso**
```r
# Agregar en server.R para debugging
observe({
  cat("Google Maps API calls:", api_call_count, "\n")
})
```

### **Implementar Caché**
```r
# Usar memoise para cachear resultados
library(memoise)
cached_places_search <- memoise(places_search, cache = cache_memory())
```

### **Optimizar Consultas**
- Usar radio de búsqueda apropiado
- Agrupar búsquedas similares
- Implementar búsqueda incremental

## 🔗 Recursos Adicionales

- **Google Maps API Documentation**: https://developers.google.com/maps/documentation/javascript/
- **Places API Reference**: https://developers.google.com/maps/documentation/javascript/places
- **Google Cloud Console**: https://console.cloud.google.com/
- **Pricing Calculator**: https://cloud.google.com/maps-platform/pricing

---

**¡Listo!** Tu aplicación ahora tiene integración completa con Google Maps para buscar y visualizar lugares en Playa Bagdad. 🎉 