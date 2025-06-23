# Configuración de Módulos - Playa Bagdad Shiny App

## 🎯 División de Trabajo por Módulos

### Módulo 1: SpaceX Instalaciones
**Responsable**: Jime
#### Archivos a Modificar:
- `ui.R` - Líneas específicas para controles SpaceX
- `server.R` - Lógica de SpaceX
- `www/google_maps.js` - Funciones de mapa SpaceX
- `datos/spacex_data.RData` - Datos de instalaciones (nuevo)

#### Áreas de Código Específicas:
```r
# En ui.R - Agregar después de línea 172
# === MÓDULO SPACEX - INICIO ===
column(2,
  checkboxInput("show_spacex_installations", "Instalaciones SpaceX", value = FALSE)
),
column(2,
  checkboxInput("show_spacex_radius", "Radio 5km SpaceX", value = FALSE)
)
# === MÓDULO SPACEX - FIN ===
```

```r
# En server.R - Agregar después de línea 280
# === MÓDULO SPACEX - INICIO ===
# Observer para SpaceX
observeEvent(input$show_spacex_installations, {
  # Lógica de SpaceX aquí
})
# === MÓDULO SPACEX - FIN ===
```

### Módulo 2: Capas Ambientales
**Responsable**: Nas

#### Archivos a Modificar:
- `ui.R` - Controles para capas ambientales
- `server.R` - Lógica de capas ambientales
- `www/google_maps.js` - Funciones de mapa ambientales
- `global.R` - Carga de datos ambientales
- `datos/ambiental/` - Carpeta con datos ambientales (nueva)

#### Áreas de Código Específicas:
```r
# En ui.R - Agregar después de línea 172
# === MÓDULO AMBIENTAL - INICIO ===
column(2,
  checkboxInput("show_acuiferos", "Mantos Acuíferos", value = FALSE)
),
column(2,
  checkboxInput("show_tortugas", "Nidos de Tortugas", value = FALSE)
),
column(2,
  checkboxInput("show_corrientes", "Corrientes", value = FALSE)
),
column(2,
  checkboxInput("show_conservacion", "Centros Conservación", value = FALSE)
)
# === MÓDULO AMBIENTAL - FIN ===
```

```r
# En global.R - Agregar después de línea 50
# === MÓDULO AMBIENTAL - INICIO ===
# Carga de datos ambientales
load("datos/ambiental/acuiferos.RData")
load("datos/ambiental/tortugas.RData")
load("datos/ambiental/corrientes.RData")
load("datos/ambiental/conservacion.RData")
# === MÓDULO AMBIENTAL - FIN ===
```

### Módulo 3: Dashboard Estadísticas
**Responsable**: Luis

#### Archivos a Modificar:
- `ui.R` - Nueva pestaña dashboard
- `server.R` - Lógica de dashboard
- `www/dashboard.js` - JavaScript para dashboard (nuevo)
- `www/dashboard.css` - Estilos para dashboard (nuevo)

#### Áreas de Código Específicas:
```r
# En ui.R - Agregar después de línea 190 (antes del cierre de navbarPage)
# === MÓDULO DASHBOARD - INICIO ===
tabPanel(
  "Dashboard",
  fluidRow(
    column(12,
      h2("Estadísticas Rápidas"),
      # Contenido del dashboard aquí
    )
  )
)
# === MÓDULO DASHBOARD - FIN ===
```

```r
# En server.R - Agregar después de línea 300
# === MÓDULO DASHBOARD - INICIO ===
# Lógica del dashboard
output$dashboard_stats <- renderUI({
  # Código del dashboard aquí
})
# === MÓDULO DASHBOARD - FIN ===
```

## 🚫 Zonas Prohibidas (No Modificar)

### Archivos Comunes - Solo Modificar en Zonas Marcadas:
- `ui.R` - Solo en las secciones marcadas con comentarios
- `server.R` - Solo en las secciones marcadas con comentarios
- `global.R` - Solo en las secciones marcadas con comentarios

### Archivos que no hay que modificar:
- `renv.lock` - Solo modificar si hay cambios de dependencias
- `google_maps_config.R` - Solo modificar configuración de API

## 📋 Checklist de Inicio para Cada Persona

### Antes de Empezar:
- [ ] Clonar repositorio
- [ ] Crear rama de feature
- [ ] Leer documentación
- [ ] Identificar zonas de trabajo
- [ ] Comunicar inicio de trabajo

### Durante el Desarrollo:
- [ ] Trabajar solo en zonas marcadas
- [ ] Hacer commits frecuentes
- [ ] Probar cambios localmente
- [ ] Comunicar bloqueos

### Al Finalizar:
- [ ] Probar integración completa
- [ ] Crear Pull Request
- [ ] Documentar cambios
- [ ] Solicitar review

## 🔧 Comandos Específicos por Módulo

### SpaceX:
```bash
git checkout feature/spacex-instalaciones
# Trabajar en archivos específicos
git add ui.R server.R www/google_maps.js
git commit -m "Agregar funcionalidad SpaceX"
```

### Capas Ambientales:
```bash
git checkout feature/capas-ambientales
# Trabajar en archivos específicos
git add ui.R server.R global.R www/google_maps.js
git commit -m "Agregar capas ambientales"
```

### Dashboard:
```bash
git checkout feature/estadisticas-dashboard
# Trabajar en archivos específicos
git add ui.R server.R www/dashboard.js www/dashboard.css
git commit -m "Agregar dashboard estadísticas"
```
