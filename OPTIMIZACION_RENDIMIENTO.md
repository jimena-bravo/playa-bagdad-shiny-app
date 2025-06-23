# Guía de Optimización de Rendimiento - App Playa Bagdad

## 🚀 Problemas Identificados y Soluciones Implementadas

### **Problema 1: Carga Inicial Lenta**
**Causa:** Todos los datos (hasta 45MB) se cargaban al inicio de la aplicación.

**Solución Implementada:**
- ✅ **Lazy Loading**: Los datos pesados se cargan solo cuando se necesitan
- ✅ **Carga Diferida**: Solo se cargan los datos críticos al inicio (playa_bagdad, lag_madre, puntos)
- ✅ **Indicadores de Carga**: Se agregaron indicadores visuales para el usuario

### **Problema 2: Observers Ineficientes**
**Causa:** Un solo `observe` reactivo que se ejecutaba cada vez que cambiaba cualquier checkbox.

**Solución Implementada:**
- ✅ **Observers Separados**: Cada capa del mapa tiene su propio `observeEvent`
- ✅ **clearGroup() en lugar de clearShapes()**: Solo se eliminan las capas específicas
- ✅ **Carga Condicional**: Los datos pesados se cargan solo cuando se activan

### **Problema 3: Datos Espaciales No Optimizados**
**Causa:** Geometrías complejas y archivos sin compresión.

**Solución Implementada:**
- ✅ **Script de Optimización**: `optimize_data.R` para simplificar geometrías
- ✅ **Compresión de Datos**: Uso de `compress = TRUE` al guardar
- ✅ **Eliminación de Columnas Innecesarias**: Remoción de AREA, PERIMETER

## 📋 Pasos para Aplicar las Optimizaciones

### **Paso 1: Ejecutar el Script de Optimización**
```r
# En R o RStudio
source("optimize_data.R")
```

### **Paso 2: Verificar los Cambios**
Los archivos optimizados deberían ser más pequeños:
- `manzana.RData`: ~10MB → ~6-8MB
- `vialidad.RData`: ~12MB → ~8-10MB
- `shapes_mexico.RData`: ~3.5MB → ~2-3MB

### **Paso 3: Probar la Aplicación**
```r
shiny::runApp()
```

## 🎯 Mejoras de Rendimiento Esperadas

### **Tiempo de Carga Inicial:**
- **Antes:** 30-60 segundos
- **Después:** 5-10 segundos

### **Tiempo de Respuesta del Mapa:**
- **Antes:** 3-5 segundos por cambio de capa
- **Después:** 0.5-1 segundo por cambio de capa

### **Uso de Memoria:**
- **Antes:** ~200-300MB al inicio
- **Después:** ~50-80MB al inicio, incrementando según uso

## 🔧 Configuraciones Adicionales Recomendadas

### **Para Desarrollo:**
```r
# En global.R, agregar:
options(shiny.maxRequestSize = 100*1024^2)  # 100MB max
options(shiny.sanitize.errors = FALSE)      # Para debugging
```

### **Para Producción:**
```r
# En server.R, agregar:
options(shiny.maxRequestSize = 50*1024^2)   # 50MB max
options(shiny.sanitize.errors = TRUE)       # Para seguridad
```

## 📊 Monitoreo de Rendimiento

### **Verificar el Rendimiento:**
1. **Tiempo de Carga:** Usar `Sys.time()` para medir
2. **Uso de Memoria:** Monitorear con `gc()` y `memory.size()`
3. **Tiempo de Respuesta:** Usar `profvis` para profiling

### **Ejemplo de Código de Monitoreo:**
```r
# Agregar en server.R para debugging
observe({
  cat("Memoria usada:", memory.size(), "MB\n")
})
```

## 🚨 Solución de Problemas

### **Si la App sigue lenta:**
1. Verificar que `optimize_data.R` se ejecutó correctamente
2. Comprobar que los archivos .RData son más pequeños
3. Revisar la consola de R para errores de memoria

### **Si hay errores de carga:**
1. Verificar que todos los archivos están en la carpeta `datos/`
2. Comprobar permisos de lectura de archivos
3. Revisar que las librerías están instaladas

### **Si el mapa no se actualiza:**
1. Verificar que los `observeEvent` están funcionando
2. Comprobar que los datos se cargan correctamente
3. Revisar la consola del navegador para errores JavaScript

## 📈 Optimizaciones Futuras

### **Nivel Avanzado:**
- **Caché de Datos:** Implementar `memoise` para datos frecuentemente usados
- **Progressive Loading:** Cargar datos por chunks
- **Web Workers:** Usar JavaScript para procesamiento en background
- **CDN:** Servir archivos estáticos desde CDN

### **Optimización de Base de Datos:**
- **Spatial Indexing:** Crear índices espaciales en la base de datos
- **Query Optimization:** Optimizar consultas SQL
- **Connection Pooling:** Reutilizar conexiones de base de datos

## 📞 Soporte

Si tienes problemas con las optimizaciones:
1. Revisar los logs de la aplicación
2. Verificar la versión de R y las librerías
3. Comprobar el espacio en disco disponible
4. Contactar al equipo de desarrollo

---

**Nota:** Estas optimizaciones están diseñadas para mejorar significativamente el rendimiento sin cambiar la funcionalidad de la aplicación. 