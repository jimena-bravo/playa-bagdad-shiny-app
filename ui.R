library(shiny)
library(shinyWidgets)
library(leaflet)
library(shinythemes)
library(shinyjs)
library(shinydashboard)
library(shinycssloaders)


ui_app <- fluidPage(
  # Modal de autenticación
  useShinyjs(),
  # uiOutput("auth_modal"),

  # La función hidden oculta el contenido de la app hasta que se introduzca la contraseña
  # hidden(
    div(id = "app_content",

        # navbarpage indica que el ui será una app con pestañas de navegación en la parte superior
        navbarPage(
          # En title se inserta el logo de la profepa y el títutlo de la app
          title = div(
            img(src = "LOGO_PROFEPA.png", height = "40px", style = "margin-right:10px;"),
            ""
          ),
          id = "nav",

          # Con header se inserta el archivo css y el código de javascript que se usa únicamente para la tabla de infractores
          header = tags$head(
            tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/admin-lte/2.4.18/css/AdminLTE.min.css"),
            tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/admin-lte/2.4.18/js/adminlte.min.js"),
            includeCSS("www/styles.css"),
            includeScript("infractores.js"),
            includeScript("www/google_maps.js"),
            # Agregar indicador de carga
            tags$style("
              .loading-indicator {
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: rgba(255, 255, 255, 0.9);
                padding: 20px;
                border-radius: 10px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                z-index: 9999;
                display: none;
              }
              .google-maps-container {
                height: 600px;
                width: 100%;
                border-radius: 10px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
              }
              .search-container {
                background: white;
                padding: 15px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 15px;
              }
            "),
            # Google Maps API - Se carga de forma asíncrona usando la configuración
            tags$script(src = get_google_maps_api_url(), async = NA, defer = NA),
            # Datos GeoJSON para la capa de Laguna Madre
            tags$script(id = "lag_madre_geojson", type = "application/json", lag_madre_geojson),
            # Datos GeoJSON para la capa de Playa Bagdad
            tags$script(id = "playa_bagdad_geojson", type = "application/json", playa_bagdad_geojson),
            # Datos GeoJSON para la capa Dv
            tags$script(id = "dv_layer_geojson", type = "application/json", dv_layer_geojson)
          ),

          # Contenido de la primera pestaña ----
          # La primera de las pestañas de la app será el mapa de la distribución de las sanciones
          # Cada uno de los tabPanels define cada una de las pestañas
          tabPanel(
            "Residuos Starship",
            sidebarLayout(
              sidebarPanel(
                width = 3,

                # Agregar indicador de progreso
                div(id = "loading_indicator", class = "loading-indicator",
                    h4("Cargando datos...", style = "text-align: center;"),
                    div(style = "text-align: center;", "Por favor espera")
                ),

                # Agrupar controles por categoría para mejor organización
                h4("Capas del Mapa", style = "color: #2c3e50; margin-bottom: 15px;"),

                # Capas principales (siempre visibles)
                h5("Capas Principales", style = "color: #34495e; font-size: 14px; margin-bottom: 10px;"),
                checkboxInput("puntos", label = "Puntos de interés", value = T),
                checkboxInput("playa_bagdad", label = "Playa Bagdad", value = T),
                checkboxInput("lag_madre", label = "Área Natural Protegida (Laguna Madre)", value = F),

                # Capas administrativas
                h5("División Administrativa", style = "color: #34495e; font-size: 14px; margin-bottom: 10px; margin-top: 20px;"),
                checkboxInput("municipios", label = "Municipios", value = F),
                checkboxInput("ageb_rural", label = "AGEB rural", value = F),
                checkboxInput("ageb_urbano", label = "AGEB urbano", value = F),

                # Capas de localidades
                h5("Localidades", style = "color: #34495e; font-size: 14px; margin-bottom: 10px; margin-top: 20px;"),
                checkboxInput("localidad_amanzanada", label = "Localidades amanzanadas", value = F),
                checkboxInput("localidad_puntual", label = "Localidades rurales (puntuales)", value = F),

                # Capas detalladas
                h5("Detalle Urbano", style = "color: #34495e; font-size: 14px; margin-bottom: 10px; margin-top: 20px;"),
                checkboxInput("manzana", label = "Manzanas", value = F),
                checkboxInput("vialidad", label = "Vialidades", value = F),

                # Información sobre rendimiento
                hr(),
                div(style = "font-size: 12px; color: #7f8c8d;",
                    p("💡 Tip: Las capas más pesadas (manzanas, vialidades) pueden tardar más en cargar."),
                    p("✅ Los datos se cargan automáticamente cuando los necesitas.")
                )

              ),

              mainPanel(
                # Agregar indicador de carga para el mapa
                div(id = "map_loading", style = "position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 1000; display: none;",
                    div(class = "spinner-border text-primary", role = "status",
                        span(class = "sr-only", "Cargando...")
                    )
                ),
                leafletOutput("mapa", width = "100%", height = "calc(100vh - 70px)")
              )
            )
          ),
          
          # Nueva pestaña para Google Maps
          tabPanel(
            "Google Maps - Lugares",
            if (!is_google_maps_configured()) {
              div(class = "container-fluid", style = "padding-top: 20px;",
                  div(class = "alert alert-danger",
                      h3("⚠️ Configuración de API Requerida"),
                      p("Para activar el mapa de Google, necesitas una clave de API."),
                      hr(),
                      p("Sigue estos pasos para obtenerla y configurarla:"),
                      tags$pre(GOOGLE_MAPS_SETUP_INSTRUCTIONS)
                  )
              )
            } else {
              tagList(
                fluidRow(
                  column(12,
                    div(class = "search-container",
                      fluidRow(
                        column(3,
                          textInput("search_place", "Buscar lugar:",
                                   placeholder = "Ej: escuelas, restaurantes, hospitales...")
                        ),
                        column(2,
                          selectInput("place_type", "Tipo de lugar:",
                                     choices = GOOGLE_MAPS_CONFIG$place_types)
                        ),
                        column(2,
                          numericInput("search_radius", "Radio (km):",
                                      value = GOOGLE_MAPS_CONFIG$default_search_radius,
                                      min = GOOGLE_MAPS_CONFIG$search_limits$min_radius,
                                      max = GOOGLE_MAPS_CONFIG$search_limits$max_radius,
                                      step = 1)
                        ),
                        column(1,
                          actionButton("search_btn", "Buscar",
                                      class = "btn btn-primary", style = "margin-top: 25px;")
                        ),
                        column(2,
                               checkboxInput("show_lag_madre_gmap", "ANP Laguna Madre y Delta del Río Bravo", value = FALSE)
                        ),
                        column(2,
                               checkboxInput("show_playa_bagdad_gmap", "Playa Bagdad", value = FALSE)
                        ),
                        column(2,
                               checkboxInput("show_dv_layer_gmap", "Recorrido CONANP (fotos)", value = FALSE)
                        )
                      )
                    )
                  )
                ),
                fluidRow(
                  column(12,
                    div(id = "google_map", class = "google-maps-container")
                  )
                ),
                fluidRow(
                  column(12,
                    div(style = "margin-top: 15px;",
                      h4("Lugares Encontrados"),
                      div(id = "places_results",
                          style = "max-height: 300px; overflow-y: auto; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);")
                    )
                  )
                )
              )
            }
          )
        )
    )
  # )
)

ui <- secure_app(
  ui_app,
  language = "es",
  background  = "url('bagdad.jpeg');",
  head_auth = tags$head(
    includeCSS("www/estilo_auth.css")),
  tags_top =
    tags$div(
      tags$img(
        src = "LOGO_PROFEPA.png", width = 100
      )
    )
)

