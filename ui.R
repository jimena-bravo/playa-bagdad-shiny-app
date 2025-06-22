library(shiny)
library(shinyWidgets)
library(leaflet)
library(shinythemes)
library(shinyjs)
library(shinydashboard)



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
            includeScript("infractores.js")
          ),
          
          # Contenido de la primera pestaña ----
          # La primera de las pestañas de la app será el mapa de la distribución de las sanciones
          # Cada uno de los tabPanels define cada una de las pestañas
          tabPanel(
            "Residuos Starship",
            sidebarLayout(
              sidebarPanel(
                width = 3,
                
                
                checkboxInput("puntos", label = "Puntos de interés", value = T),
                checkboxInput("playa_bagdad", label = "Playa Bagdad", value = T),
                checkboxInput("lag_madre", label = "Área Natural Protegida (Laguna Madre)", value = F),
                checkboxInput("municipios", label = "Municipios", value = F),
                checkboxInput("ageb_rural", label = "AGEB rural", value = F),
                checkboxInput("ageb_urbano", label = "AGEB urbano", value = F),
                checkboxInput("localidad_amanzanada", label = "Localidades amanzanadas", value = F),
                checkboxInput("localidad_puntual", label = "Localidades rurales (puntuales)", value = F),
                checkboxInput("manzana", label = "Manzanas", value = F),
                checkboxInput("vialidad", label = "Vialidades", value = F),
                
              ),
              
              mainPanel(
                leafletOutput("mapa", width = "100%", height = "calc(100vh - 70px)")
              )
            )
          )
        )
    )
  # )
)

ui <- secure_app(
  ui_app,
  language = "es",
  background  = "url('Jaguar.jpg');",
  head_auth = tags$head(
    includeCSS("www/estilo_auth.css")), 
  tags_top = 
    tags$div(
      tags$img(
        src = "LOGO_PROFEPA.png", width = 100
      )
    )
)

