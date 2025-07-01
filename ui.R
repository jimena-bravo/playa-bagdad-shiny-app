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
            tags$script(id = "dv_layer_geojson", type = "application/json", dv_layer_geojson),
            # Datos GeoJSON para la capa complejo starbase
            tags$script(id = "complejo_starbase_geojson", type = "application/json", complejo_starbase_geojson),
             # Datos GeoJSON para las CAPAS AMBIENTALES
            # Datos GeoJSON para la capa aicas
            tags$script(id = "aicas_geojson", type = "application/json", aicas_geojson),
            # Datos GeoJSON para la capa sistema arrecifal tamaulipas
            tags$script(id = "sistema_arrecifal_tamaulipas_geojson", type = "application/json", sistema_arrecifal_tamaulipas_geojson),
            # Datos GeoJSON para la capa rtp
            tags$script(id = "rtp_geojson", type = "application/json", rtp_geojson),
            # Datos GeoJSON para la capa rmp
            tags$script(id = "rmp_geojson", type = "application/json", rmp_geojson),
            # Datos GeoJSON para la capa lm_ramsar
            tags$script(id = "lm_ramsar_geojson", type = "application/json", lm_ramsar_geojson),
            # Datos GeoJSON para la capa rn_ramsar
            tags$script(id = "rn_ramsar_geojson", type = "application/json", rn_ramsar_geojson),
            # Datos GeoJSON para la capa hidro_tam_nl_coa
            tags$script(id = "hidro_tam_nl_coa_geojson", type = "application/json", hidro_tam_nl_coa_geojson),
            # Datos GeoJSON para la capa uso_suelo_mat
            tags$script(id = "uso_suelo_mat_geojson", type = "application/json", uso_suelo_mat_geojson),
            # Datos GeoJSON para las CAPAS RIESGO
            ##### Temperatura
            # Datos GeoJSON para la capa buff1_300F_50m
            tags$script(id = "buff1_300F_50m_geojson", type = "application/json", buff1_300F_50m_geojson),      
            # Datos GeoJSON para la capa buff1_212F_482m
            tags$script(id = "buff1_212F_482m_geojson", type = "application/json", buff1_212F_482m_geojson),
            # Datos GeoJSON para la capa buff1_90F_965m
            tags$script(id = "buff1_90F_965m_geojson", type = "application/json", buff1_90F_965m_geojson),
            ##### Ruido
            # Datos GeoJSON para la capa buff2_140db_804m
            tags$script(id = "buff2_140db_804m_geojson", type = "application/json", buff2_140db_804m_geojson),
            # Datos GeoJSON para la capa buff2_130db_5471m
            tags$script(id = "buff2_130db_5471m_geojson", type = "application/json", buff2_130db_5471m_geojson),
            # Datos GeoJSON para la capa buff2_111db_36210m
            tags$script(id = "buff2_111db_36210m_geojson", type = "application/json", buff2_111db_36210m_geojson),
            # Datos GeoJSON para la capa buff2_120db_15288m
            tags$script(id = "buff2_120db_15288m_geojson", type = "application/json", buff2_120db_15288m_geojson),
            ##### Explosion sonica
            # Datos GeoJSON para la capa buff3_6psf_16093m
            tags$script(id = "buff3_6psf_16093m_geojson", type = "application/json", buff3_6psf_16093m_geojson),
            # Datos GeoJSON para la capa buff3_4psf_24140m
            tags$script(id = "buff3_4psf_24140m_geojson", type = "application/json", buff3_4psf_24140m_geojson),
            # Datos GeoJSON para la capa buff3_2psf_43452m
            tags$script(id = "buff3_2psf_43452m_geojson", type = "application/json", buff3_2psf_43452m_geojson),
            # Datos GeoJSON para la capa buff3_1psf_45061m
            tags$script(id = "buff3_1psf_45061m_geojson", type = "application/json", buff3_1psf_45061m_geojson),
          ),

        
          # Contenido de la primera pestaña ----
          # La primera de las pestañas de la app será el mapa de la distribución de las sanciones
          # Cada uno de los tabPanels define cada una de las pestañas
          tabPanel(
            "Residuos Starship",
            sidebarLayout(
              sidebarPanel(style = "position: fixed; height: 90vh; width: 25%;  overflow-y: auto;",
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
                checkboxInput("complejo_starbase", label = "Complejo Starbase", value = F),

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
                
                # Capas ambientales
                h5("Capas Ambientales", style = "color: #34495e; font-size: 14px; margin-bottom: 10px; margin-top: 20px;"),
                checkboxInput("aicas", label = "Áreas de Importancia para la Conservación de las Aves", value = F),
                checkboxInput("sistema_arrecifal_tamaulipas", label = "Sistema Arrecifal Artificial Tamaulipas", value = F),
                checkboxInput("rtp", label = "Regiones Terrestres Prioritarias", value = F),
                checkboxInput("rmp", label = "Regiones Marinas Prioritarias", value = F),
                checkboxInput("lm_ramsar", label = "Sitio Ramsar Laguna Madre", value = F),
                checkboxInput("rn_ramsar", label = "Sitio Ramsar Rancho Nuevo", value = F),
                checkboxInput("hidro_tam_nl_coa", label = "Hidrología", value = F),
                checkboxInput("uso_suelo_mat", label = "Uso de Suelo y Vegetación", value = F),
               
                # Capas riesgo
                h5("Radios de Riesgo", style = "color: #34495e; font-size: 14px; margin-bottom: 10px; margin-top: 20px;"),
                checkboxInput("buff1_300F_50m", label = "Columna de calor (150°C - 0.05 km)", value = F),
                checkboxInput("buff1_212F_482m", label = "Columna de calor (100°C - 0.482 km)", value = F),
                checkboxInput("buff1_90F_965m", label = "Columna de calor (32.22°C - 0.965 km)", value = F),
                checkboxInput("buff2_140db_804m", label = "Contorno de ruido (140 dB - 0.804 km)", value = F),
                checkboxInput("buff2_130db_5471m", label = "Contorno de ruido (130 dB - 5.47 km)", value = F),
                checkboxInput("buff2_120db_15288m", label = "Contorno de ruido (120 dB - 15.29 km)", value = F),
                checkboxInput("buff2_111db_36210m", label = "Contorno de ruido (111 dB - 36.21 km)", value = F),
                checkboxInput("buff3_6psf_16093m", label = "Explosiones sónicas (6 psf - 16.09 km)", value = F),
                checkboxInput("buff3_4psf_24140m", label = "Explosiones sónicas (4 psf - 24.14 km)", value = F),  
                checkboxInput("buff3_2psf_43452m", label = "Explosiones sónicas (2 psf - 43.45 km)", value = F),
                checkboxInput("buff3_1psf_45061m", label = "Explosiones sónicas (1 psf - 45.06 km)", value = F), 

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
          
          # Contenido de la primera pestaña ----
          # La primera de las pestañas de la app será el mapa de la distribución de las sanciones
          # Cada uno de los tabPanels define cada una de las pestañas
          tabPanel(
            "Google Maps - Lugares",
            sidebarLayout(
              sidebarPanel(style = "position: fixed; height: 90vh; width: 25%;  overflow-y: auto;",
                           width = 3,
                           
                           textInput("search_place", "Buscar lugar:",
                                     placeholder = "Ej: escuelas, restaurantes, hospitales..."),
                           selectInput("place_type", "Tipo de lugar:",
                                       choices = GOOGLE_MAPS_CONFIG$place_types),
                           numericInput("search_radius", "Radio (km):",
                                         value = GOOGLE_MAPS_CONFIG$default_search_radius,
                                         min = GOOGLE_MAPS_CONFIG$search_limits$min_radius,
                                         max = GOOGLE_MAPS_CONFIG$search_limits$max_radius,
                                         step = 1),
                           actionButton("search_btn", "Buscar",
                                        class = "btn btn-primary", style = "margin-top: 25px;"),
                           checkboxInput("show_lag_madre_gmap", "ANP Laguna Madre y Delta del Río Bravo", value = FALSE),
                           checkboxInput("show_playa_bagdad_gmap", "Playa Bagdad", value = FALSE),
                           checkboxInput("show_dv_gmap", "Recorrido CONANP (fotos)", value = FALSE),
                           checkboxInput("show_complejo_starbase_gmap", "Complejo Starbase", value = FALSE),
                           # === MÓDULO AMBIENTAL - INICIO ===
                           checkboxInput("show_aicas", "Áreas de Importancia para la Conservación de las Aves", value = FALSE),
                           checkboxInput("show_sist_arrecifal", "Sistema Arrecifal Artificial de Tamaulipas", value = FALSE),
                           checkboxInput("show_rtp", "Regiones Terrestres Prioritarias", value = FALSE),
                           checkboxInput("show_rmp", "Regiones Marinas Prioritarias", value = FALSE),
                           checkboxInput("show_sapcb", "Sitios de Atención Prioritaria para la Conservación de la Biodiversidad", value = FALSE),
                           checkboxInput("show_lm_ramsar", "Sitio RAMSAR Laguna Madre", value = FALSE),
                           checkboxInput("show_rn_ramsar", "Sitio RAMSAR Rancho Nuevo", value = FALSE),
                           checkboxInput("hidro_tam_nl_coa", "Hidrología", value = FALSE),
                           checkboxInput("uso_suelo_mat", "Uso de Suelo y Vegetación", value = FALSE),
                           # === MÓDULO AMBIENTAL - FIN ===
                           # === MÓDULO RIESGO - INICIO ===
                           checkboxInput("buff1_300F_50m", "Columna de calor (150°C - 0.05 km)", value = FALSE),
                           checkboxInput("buff1_212F_482m", "Columna de calor (100°C - 0.482 km)", value = FALSE),
                           checkboxInput("buff1_90F_965m", "Columna de calor (32.22°C - 0.965 km)", value = FALSE),
                           checkboxInput("buff2_140db_804m", "Contorno de ruido (140 dB - 0.804 km)", value = FALSE),
                           checkboxInput("buff2_130db_5471m", "Contorno de ruido (130 dB - 5.47 km)", value = FALSE),
                           checkboxInput("buff2_120db_15288m", "Contorno de ruido (120 dB - 15.29 km)", value = FALSE),
                           checkboxInput("buff2_111db_36210m", "Contorno de ruido (111 dB - 36.21 km)", value = FALSE),
                           checkboxInput("buff3_6psf_16093m", "Explosiones sónicas (6 psf - 16.09 km)", value = FALSE),
                           checkboxInput("buff3_4psf_24140m", "Explosiones sónicas (4 psf - 24.14 km)", value = FALSE),
                           checkboxInput("buff3_2psf_43452m", "Explosiones sónicas (2 psf - 43.45 km)", value = FALSE),
                           checkboxInput("buff3_1psf_45061m", "Explosiones sónicas (1 psf - 45.06 km)", value = FALSE),
                           # === MÓDULO RIESGO - FIN ===     
                           
                           # Información sobre rendimiento
                           hr(),
                           div(style = "font-size: 12px; color: #7f8c8d;",
                               p("💡 Tip: Las capas más pesadas (manzanas, vialidades) pueden tardar más en cargar."),
                               p("✅ Los datos se cargan automáticamente cuando los necesitas.")
                           )
                           
              ),
              
              mainPanel(
                div(id='map-canvas',
                    # style = "position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);",
                    style = "width: 100%; height: 90vh; margin: 0; padding: 0; position: relative;",
                div(id = "google_map", 
                    style = "width: 100%; height: 100%;",
                    class = "google-maps-container")
              )
              )
            )
          ),
          
          
          # Nueva pestaña para Google Maps
          # tabPanel(
          #   "Google Maps - Lugares",
          #   if (!is_google_maps_configured()) {
          #     div(class = "container-fluid", style = "padding-top: 20px;",
          #         div(class = "alert alert-danger",
          #             h3("⚠️ Configuración de API Requerida"),
          #             p("Para activar el mapa de Google, necesitas una clave de API."),
          #             hr(),
          #             p("Sigue estos pasos para obtenerla y configurarla:"),
          #             tags$pre(GOOGLE_MAPS_SETUP_INSTRUCTIONS)
          #         )
          #     )
          #   } else {
          #     tagList(
          #       fluidRow(
          #         column(12,
          #           div(class = "search-container",
          #             fluidRow(
          #               column(3,
          #                 textInput("search_place", "Buscar lugar:",
          #                          placeholder = "Ej: escuelas, restaurantes, hospitales...")
          #               ),
          #               column(2,
          #                 selectInput("place_type", "Tipo de lugar:",
          #                            choices = GOOGLE_MAPS_CONFIG$place_types)
          #               ),
          #               column(2,
          #                 numericInput("search_radius", "Radio (km):",
          #                             value = GOOGLE_MAPS_CONFIG$default_search_radius,
          #                             min = GOOGLE_MAPS_CONFIG$search_limits$min_radius,
          #                             max = GOOGLE_MAPS_CONFIG$search_limits$max_radius,
          #                             step = 1)
          #               ),
          #               column(1,
          #                 actionButton("search_btn", "Buscar",
          #                             class = "btn btn-primary", style = "margin-top: 25px;")
          #               ),
          #               column(2,
          #                      checkboxInput("show_lag_madre_gmap", "ANP Laguna Madre y Delta del Río Bravo", value = FALSE)
          #               ),
          #               # === MÓDULO AMBIENTAL - INICIO ===
          #               column(2,
          #                      checkboxInput("show_aicas", "Áreas de Importancia para la Conservación de las Aves", value = FALSE)
          #               ),
          #               column(2,
          #                      checkboxInput("show_sist_arrecifal", "Sistema Arrecifal Artificial de Tamaulipas", value = FALSE)
          #               ),
          #               column(2,
          #                      checkboxInput("show_rtp", "Regiones Terrestres Prioritarias", value = FALSE)
          #               ),
          #               column(2,
          #                      checkboxInput("show_rmp", "Regiones Marinas Prioritarias", value = FALSE)
          #               ),
          #               column(2,
          #                      checkboxInput("show_lm_ramsar", "Sitio RAMSAR Laguna Madre", value = FALSE)
          #               ),
          #               column(2,
          #                      checkboxInput("show_rn_ramsar", "Sitio RAMSAR Rancho Nuevo", value = FALSE)
          #               ),
          #               # === MÓDULO AMBIENTAL - FIN ===
          #               column(2,
          #                      checkboxInput("show_playa_bagdad_gmap", "Playa Bagdad", value = FALSE)
          #               ),
          #               column(2,
          #                      checkboxInput("show_dv_gmap", "Recorrido CONANP (fotos)", value = FALSE)
          #               )
          #             )
          #           )
          #         )
          #       ),
          #       fluidRow(
          #         column(12,
          #           div(id = "google_map", class = "google-maps-container")
          #         )
          #       ),
          #       fluidRow(
          #         column(12,
          #           div(style = "margin-top: 15px;",
          #             h4("Lugares Encontrados"),
          #             div(id = "places_results",
          #                 style = "max-height: 300px; overflow-y: auto; background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);")
          #           )
          #         )
          #       )
          #     )
          #   }
          # )
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

