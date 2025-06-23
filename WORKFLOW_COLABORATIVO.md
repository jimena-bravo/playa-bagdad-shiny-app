# Workflow Colaborativo - Playa Bagdad Shiny App

## 🎯 Objetivo
Trabajar en paralelo con 3 personas en diferentes módulos sin conflictos de código.

## 📋 Módulos de Trabajo

### Persona 1: SpaceX Instalaciones
- **Archivos a modificar**: `ui.R`, `server.R`, `www/google_maps.js`
- **Funcionalidad**: Agregar puntos de instalaciones SpaceX + radio 5km
- **Pestaña**: "Google Maps - Lugares"

### Persona 2: Capas Ambientales  
- **Archivos a modificar**: `ui.R`, `server.R`, `www/google_maps.js`, `global.R`
- **Funcionalidad**: Mantos acuíferos, nidos tortugas, corrientes, centros conservación
- **Pestaña**: "Google Maps - Lugares"

### Persona 3: Dashboard Estadísticas
- **Archivos a modificar**: `ui.R`, `server.R`, crear nuevos archivos
- **Funcionalidad**: Tablas, gráficas y estadísticas rápidas
- **Pestaña**: Nueva pestaña "Dashboard"

## 🔄 Flujo de Trabajo

### 1. Configuración Inicial (Solo una vez)
```bash
# Clonar el repositorio
git clone https://github.com/jimena-bravo/playa-bagdad-shiny-app.git
cd playa-bagdad-shiny-app

# Crear tu rama de feature
git checkout develop
git pull origin develop
git checkout -b feature/tu-modulo
```

### 2. Trabajo Diario
```bash
# Al inicio del día
git checkout develop
git pull origin develop
git checkout feature/tu-modulo
git merge develop

# Durante el trabajo
git add .
git commit -m "Descripción clara del cambio"
git push origin feature/tu-modulo
```

### 3. Finalización de Feature
```bash
# Crear Pull Request en GitHub
# Merge a develop
# Eliminar rama local
git checkout develop
git pull origin develop
git branch -d feature/tu-modulo
```

## 📁 Estructura de Archivos por Módulo

### Módulo 1: SpaceX
```
ui.R                    # Agregar controles para SpaceX
server.R               # Lógica de SpaceX
www/google_maps.js     # Funciones de mapa SpaceX
datos/spacex_data.RData # Datos de instalaciones (nuevo)
```

### Módulo 2: Capas Ambientales
```
ui.R                    # Controles para capas ambientales
server.R               # Lógica de capas ambientales  
www/google_maps.js     # Funciones de mapa ambientales
global.R               # Carga de datos ambientales
datos/ambiental/       # Carpeta con datos ambientales (nueva)
```

### Módulo 3: Dashboard
```
ui.R                    # Nueva pestaña dashboard
server.R               # Lógica de dashboard
www/dashboard.js       # JavaScript para dashboard (nuevo)
www/dashboard.css      # Estilos para dashboard (nuevo)
```

## ⚠️ Reglas Importantes

### 1. Evitar Conflictos
- **NO modificar** archivos que no correspondan a tu módulo
- **Comunicar** cambios que afecten otros módulos
- **Usar** comentarios claros en el código

### 2. Convenciones de Naming
- **Variables**: `spacex_instalaciones`, `ambiental_acuiferos`, `dashboard_stats`
- **Funciones**: `load_spacex_data()`, `render_ambiental_layer()`, `update_dashboard()`
- **IDs**: `spacex_controls`, `ambiental_layers`, `dashboard_tab`

### 3. Comunicación
- **Daily standup** para reportar progreso
- **Pull Request** con descripción detallada
- **Review** de código entre pares

## 🚀 Comandos Útiles

### Ver estado actual
```bash
git status
git branch -a
```

### Ver diferencias
```bash
git diff
git diff develop
```

### Resolver conflictos
```bash
git merge develop
# Resolver conflictos manualmente
git add .
git commit -m "Resolve merge conflicts"
```

## 📞 Contacto
- **Coordinador**: [Tu nombre]
- **Canal de comunicación**: [Slack/Discord/Teams]
- **Reuniones**: [Horario y frecuencia]

## ✅ Checklist de Finalización

### Antes de crear Pull Request:
- [ ] Código funciona localmente
- [ ] No hay conflictos con develop
- [ ] Documentación actualizada
- [ ] Tests pasan (si existen)
- [ ] Código revisado por pares

### Antes de merge a main:
- [ ] Todos los módulos integrados
- [ ] Testing completo
- [ ] Documentación final
- [ ] Deploy exitoso 