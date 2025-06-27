library(dplyr)
library(ggplot2)
library(tidyr)
library(magrittr)
library(janitor)
library(shinythemes)
library(scales)
library(leaflet)
library(shinyjs)

options(digits=10)
  
server <- function(input, output, session) {

  # Función para cargar datos pesados solo cuando se necesiten
  load_heavy_data <- function(data_name) {
    if (is.null(get(data_name, envir = .GlobalEnv))) {
      load(paste0("datos/", data_name, ".RData"), envir = .GlobalEnv)
      
      # Procesar datos solo cuando se cargan por primera vez
      if (data_name == "sanciones") {
        sanciones <<- sanciones %>%
          mutate(
            fecha_orden_inicio_mes = floor_date(fecha_orden, "month"),
            fecha_orden_inicio_mes_txt = format(fecha_orden_inicio_mes, "%Y-%m"),
            mes_anio = format(fecha_orden, "%Y-%m")
          )
      }
      
      if (data_name == "multas") {
        multas$anio_orden <<- format(as.Date(multas$fecha_de_visita), "%Y")
      }
      
      if (data_name == "shapes_mexico") {
        # Crear los dataframe de agem y agee para hacer joins
        df_agee <<- agee %>% as.data.frame() %>% .[-4]
        df_agem <<- agem %>% as.data.frame() %>% .[-5]
        
        df_agee$NOMGEO <<- homologacion_basica(df_agee$NOMGEO)
        df_agem$NOMGEO <<- homologacion_basica(df_agem$NOMGEO)
        df_agem$cve_ent_nom_mun <<- paste0(df_agem$CVE_ENT, " - ", df_agem$NOMGEO)
      }
    }
    return(get(data_name, envir = .GlobalEnv))
  }

  # Elementos del mapa interactivo de órdenes de inspección ------

  ## Filtrado de datos para el mapa ----
  datos_filtrados <- reactive({
    req(input$filtro_fecha)
    req(input$rango_fechas)
    
    # Cargar datos de sanciones solo cuando se necesiten
    sanciones_data <- load_heavy_data("sanciones")
    
    if(input$filtro_fecha == "Rango de fechas"){
      datos_filtrados <- sanciones_data %>%
        filter(
          fecha_orden >= input$rango_fechas[1] & 
            fecha_orden <= input$rango_fechas[2]
          )  
    } else {
      datos_filtrados <- sanciones_data %>%
        filter(mes_anio == input$mes)  
    }
    if(input$materia != "Todas"){
      datos_filtrados %<>%
        filter(dsc_materia == input$materia )
    }
    datos_filtrados
  })
  
  ## Preparación de la tabla filtrada para el mapa interactivo ----
  data_graf <- reactive({
    datos <- datos_filtrados()
    req(datos)
    
    # Cargar datos de shapes solo cuando se necesiten
    shapes_data <- load_heavy_data("shapes_mexico")
    
    datagraf <- datos %>% 
      count(cve_ent_nom_mun) %>% arrange(-n)
    datagraf %<>%
      left_join(df_agem[c(1, 5)], by = "cve_ent_nom_mun")
    datagraf <- agem %>%
      inner_join(datagraf[c(2, 3)], by = "CVEGEO")
    datagraf %<>%
      left_join(agee %>% as.data.frame %>% .[2:3], by = c("CVE_ENT" = "CVE_ENT")) 
    datagraf
  })
  
  # Observer para la capa de Laguna Madre en Google Maps
  observeEvent(input$show_lag_madre_gmap, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("toggleLagMadreLayer(%s);", tolower(input$show_lag_madre_gmap)))
  }, ignoreNULL = FALSE) # ignoreNULL = FALSE para que se ejecute al inicio
  
  # Observer para la capa de Playa Bagdad en Google Maps
  observeEvent(input$show_playa_bagdad_gmap, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("togglePlayaBagdadLayer(%s);", tolower(input$show_playa_bagdad_gmap)))
  }, ignoreNULL = FALSE) # ignoreNULL = FALSE para que se ejecute al inicio
  
  # Observer para la capa Dv en Google Maps
  observeEvent(input$show_dv_layer_gmap, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("toggleDvLayer(%s);", tolower(input$show_dv_layer_gmap)))
  }, ignoreNULL = FALSE)
  
  # Observer para la capa aicas en Google Maps
  observeEvent(input$show_aicas, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("toggleaicasLayer(%s);", tolower(input$show_aicas)))
  }, ignoreNULL = FALSE)
  
  # Observer para la capa sistema arrecifal en Google Maps
  observeEvent(input$show_sist_arrecifal, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("togglesistema_arrecifal_tamaulipasLayer(%s);", tolower(input$show_sist_arrecifal)))
  }, ignoreNULL = FALSE)
  
  # Observer para la capa rtp en Google Maps
  observeEvent(input$show_rtp, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("togglertpLayer(%s);", tolower(input$show_rtp)))
  }, ignoreNULL = FALSE)
  
  
  # Observer para la capa rmp en Google Maps
  observeEvent(input$show_rmp, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("togglermpLayer(%s);", tolower(input$show_rmp)))
  }, ignoreNULL = FALSE)
 
  # # Observer para la capa sapcb en Google Maps
  # observeEvent(input$show_sapcb, {
  #   # Llama a la función de JS para mostrar/ocultar la capa
  #   shinyjs::runjs(sprintf("togglesapcbLayer(%s);", tolower(input$show_sapcb)))
  # }, ignoreNULL = FALSE) 
  
  # Observer para la capa lm ramsar en Google Maps
  observeEvent(input$show_lm_ramsar, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("togglelmramsarLayer(%s);", tolower(input$show_lm_ramsar)))
  }, ignoreNULL = FALSE) 
  
  # Observer para la capa rn ramsar en Google Maps
  observeEvent(input$show_rn_ramsar, {
    # Llama a la función de JS para mostrar/ocultar la capa
    shinyjs::runjs(sprintf("togglernramsarLayer(%s);", tolower(input$show_rn_ramsar)))
  }, ignoreNULL = FALSE) 
  

  # Observer para el clic en la capa Dv que crea la galería
  observeEvent(input$dv_layer_clicked, {
    # 1. Definir la UI de la galería de fotos
    gallery_ui <- fluidPage(
      h2("Galería de fotos del recorrido de la CONANP"),
      p("Haga clic en una imagen para verla en tamaño completo."),
      hr(),
      fluidRow(
        # Leer los archivos de la carpeta y crear la galería
        lapply(list.files("fotos_conanp", pattern = "\\.jpeg$"), function(photo_file) {
          column(3, class = "text-center", style = "margin-bottom: 20px;",
            # La ruta de la imagen usa el resource path que definimos
            tags$a(href = file.path("gallery_photos", photo_file),
                   target = "_blank", # Abrir en una nueva pestaña del navegador
                   tags$img(src = file.path("gallery_photos", photo_file),
                            class = "img-fluid img-thumbnail",
                            style = "height: 200px; object-fit: cover; cursor: pointer;")
            )
          )
        })
      )
    )

    # 2. Eliminar la pestaña si ya existe para evitar duplicados.
    # Se usa try() para que no dé error si la pestaña no existe en el primer clic.
    try(removeTab(inputId = "nav", target = "galeria_conanp"), silent = TRUE)

    # 3. Insertar la nueva pestaña y seleccionarla
    insertTab(
      inputId = "nav",
      tabPanel(
        title = "Galería de fotos del recorrido de la CONANP",
        value = "galeria_conanp",
        gallery_ui
      ),
      target = "Google Maps - Lugares", # Se insertará después de esta pestaña
      position = "after",
      select = TRUE # Cambiar a la nueva pestaña inmediatamente
    )
  }, ignoreInit = TRUE)
  
  ## Capa base para el mapa interactivo -----
  output$mapa <- leaflet::renderLeaflet(
    leaflet() %>%
      addTiles() %>%
      addProviderTiles(providers$Esri.WorldImagery) %>%
      addPolylines(  # Dibujar solo las líneas de los límites estatales
        data = playa_bagdad, 
        weight = 1, 
        color = "black",  
        opacity = 1,
        group = "Playa Bagdad"
      ) 
  )
  
  ## Observers separados para cada capa del mapa -------
  
  # Observer para Playa Bagdad
  observeEvent(input$playa_bagdad, {
    leafletProxy("mapa") %>%
      clearGroup("Playa Bagdad") %>%
      {if(input$playa_bagdad) {
        addPolylines(., data = playa_bagdad, 
                    weight = 1, color = "black", opacity = 1, group = "Playa Bagdad")
      } else .}
  })
  
  # Observer para Laguna Madre
  observeEvent(input$lag_madre, {
    leafletProxy("mapa") %>%
      clearGroup("Laguna madre") %>%
      {if(input$lag_madre) {
        addPolygons(., data = lag_madre, 
                   weight = 1, color = "black", opacity = 1, group = "Laguna madre")
      } else .}
  })
  
  # Observer para Municipios
  observeEvent(input$municipios, {
    if(input$municipios && is.null(municipios)) {
      municipios <<- load_heavy_data("municipios")
      n_muns <<- nrow(municipios)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Municipios") %>%
      {if(input$municipios) {
        addPolygons(., data = municipios, 
                   weight = 1, color = "black", opacity = 1, group = "Municipios")
      } else .}
  })
  
  # Observer para AGEB Rural
  observeEvent(input$ageb_rural, {
    if(input$ageb_rural && is.null(ageb_rural)) {
      ageb_rural <<- load_heavy_data("ageb_rural")
      n_agebr <<- nrow(ageb_rural)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("AGEBS rural") %>%
      {if(input$ageb_rural) {
        addPolygons(., data = ageb_rural, 
                   weight = 1, color = "black", opacity = 1, group = "AGEBS rural")
      } else .}
  })
  
  # Observer para AGEB Urbano
  observeEvent(input$ageb_urbano, {
    if(input$ageb_urbano && is.null(ageb_urbano)) {
      ageb_urbano <<- load_heavy_data("ageb_urbano")
      n_agebu <<- nrow(ageb_urbano)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("AGEBS urbano") %>%
      {if(input$ageb_urbano) {
        addPolygons(., data = ageb_urbano, 
                   weight = 1, color = "black", opacity = 1, group = "AGEBS urbano")
      } else .}
  })
  
  # Observer para Localidades Amanzanadas
  observeEvent(input$localidad_amanzanada, {
    if(input$localidad_amanzanada && is.null(localidad_amanzanada)) {
      localidad_amanzanada <<- load_heavy_data("localidad_amanzanada")
      n_lmnz <<- nrow(localidad_amanzanada)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Localidades amanzanadas") %>%
      {if(input$localidad_amanzanada) {
        addPolygons(., data = localidad_amanzanada, 
                   weight = 1, color = "black", opacity = 1, group = "Localidades amanzanadas")
      } else .}
  })
  
  # Observer para Localidades Puntuales
  observeEvent(input$localidad_puntual, {
    if(input$localidad_puntual && is.null(localidad_puntual)) {
      localidad_puntual <<- load_heavy_data("localidad_puntual")
      n_lpunt <<- nrow(localidad_puntual)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Localidades puntuales") %>%
      {if(input$localidad_puntual) {
        addCircleMarkers(., data = localidad_puntual,
                        stroke = FALSE, fillOpacity = 0.5, group = "Localidades puntuales")
      } else .}
  })
  
  # Observer para Manzanas
  observeEvent(input$manzana, {
    if(input$manzana && is.null(manzana)) {
      manzana <<- load_heavy_data("manzana")
      n_mnz <<- nrow(manzana)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Manzanas") %>%
      {if(input$manzana) {
        addPolygons(., data = manzana, 
                   weight = 1, color = "black", opacity = 1, group = "Manzanas")
      } else .}
  })
  
  # Observer para Vialidades
  observeEvent(input$vialidad, {
    if(input$vialidad && is.null(vialidad)) {
      vialidad <<- load_heavy_data("vialidad")
      n_vial <<- nrow(vialidad)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Vialidad") %>%
      {if(input$vialidad) {
        addPolygons(., data = vialidad, 
                   weight = 1, color = "black", opacity = 1, group = "Vialidad")
      } else .}
  })
  
  # Observer para Puntos
  observeEvent(input$puntos, {
    leafletProxy("mapa") %>%
      clearGroup("Puntos") %>%
      {if(input$puntos) {
        addCircleMarkers(., data = puntos,
                        stroke = FALSE, fillOpacity = 0.5, group = "Puntos")
      } else .}
  })
  
  # Observer para aicas
  observeEvent(input$aicas, {
    if(input$aicas && is.null(aicas)) {
      aicas <<- load_heavy_data("aicas")
      n_aicas <<- nrow(aicas)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Áreas de Importancia para la Conservación de las Aves") %>%
      {if(input$aicas) {
        addPolygons(., data = aicas, 
                    weight = 1, color = "black", opacity = 1, group = "Áreas de Importancia para la Conservación de las Aves")
      } else .}
  }) 

  # Observer para Sistema Arrecifal Artificial
  observeEvent(input$sistema_arrecifal_tamaulipas, {
    if(input$sistema_arrecifal_tamaulipas && is.null(sistema_arrecifal_tamaulipas)) {
      sistema_arrecifal_tamaulipas <<- load_heavy_data("sistema_arrecifal_tamaulipa")
      n_sat <<- nrow(sistema_arrecifal_tamaulipas)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Sistema Arrecifal Artificial") %>%
      {if(input$sistema_arrecifal_tamaulipas) {
        addPolygons(., data = sistema_arrecifal_tamaulipas, 
                    weight = 1, color = "black", opacity = 1, group = "Sistema Arrecifal Artificial")
      } else .}
  }) 
  
  # Observer para Regiones Terrestres Prioritarias
  observeEvent(input$rtp, {
    if(input$rtp && is.null(rtp)) {
      rtp <<- load_heavy_data("rtp")
      n_rtp <<- nrow(rtp)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Regiones Terrestres Prioritarias") %>%
      {if(input$rtp) {
        addPolygons(., data = rtp, 
                    weight = 1, color = "black", opacity = 1, group = "Regiones Terrestres Prioritarias")
      } else .}
  }) 
  
  # Observer para Regiones Marinas Prioritarias
  observeEvent(input$rmp, {
    if(input$rmp && is.null(rmp)) {
      rmp <<- load_heavy_data("rmp")
      n_rmp <<- nrow(rmp)
    }
    
    leafletProxy("mapa") %>%
      clearGroup("Regiones Marinas Prioritarias") %>%
      {if(input$rmp) {
        addPolygons(., data = rmp, 
                    weight = 1, color = "black", opacity = 1, group = "Regiones Marinas Prioritarias")
      } else .}
  }) 
  
  # Observer para Sitios de Atención Prioritaria para la Conservación de la Biodiversidad
  observeEvent(input$sapcb, {
    if(input$sapcb && is.null(sapcb)) {
      sapcb <<- load_heavy_data("sapcb")
      n_sapcb <<- nrow(sapcb)
    }

    leafletProxy("mapa") %>%
      clearGroup("Sitios de Atención Prioritaria para la Conservación de la Biodiversidad") %>%
      {if(input$sapcb) {
        addPolygons(., data = sapcb,
                    weight = 1, color = "black", opacity = 1, group = "Sitios de Atención Prioritaria para la Conservación de la Biodiversidad")
      } else .}
  })



  # Observer para Sitio RAMSAR Laguna Madre
  observeEvent(input$lm_ramsar, {
    if(input$lm_ramsar && is.null(lm_ramsar)) {
      lm_ramsar <<- load_heavy_data("lm_ramsar")
      n_lmramsar <<- nrow(lm_ramsar)
    }

    leafletProxy("mapa") %>%
      clearGroup("Sitio Ramsar Laguna Madre") %>%
      {if(input$lm_ramsar) {
        addPolygons(., data = lm_ramsar,
                    weight = 1, color = "black", opacity = 1, group = "Sitio Ramsar Laguna Madre")
      } else .}
  })


  # Observer para Sitio RAMSAR Rancho Nuevo
  observeEvent(input$rn_ramsar, {
    if(input$rn_ramsar && is.null(rn_ramsar)) {
      rn_ramsar <<- load_heavy_data("rn_ramsar")
      n_rnramsar <<- nrow(rn_ramsar)
    }

    leafletProxy("mapa") %>%
      clearGroup("Sitio Ramsar Rancho Nuevo") %>%
      {if(input$rn_ramsar) {
        addPolygons(., data = rn_ramsar,
                    weight = 1, color = "black", opacity = 1, group = "Sitio Ramsar Rancho Nuevo")
      } else .}
  })
  
  # observe({
  #   pal <- colorNumeric(palette = colorRampPalette(c("white", "red"))(10), 
  #                       domain = data_graf()$n)
  #   
  #   if(input$filtro_fecha == "Un solo mes"){
  #     leafletProxy("mapa", data = data_graf()) %>%
  #       clearShapes()   %>%
  #       addPolygons(
  #         fillColor = ~pal(n),
  #         weight = 0.3,
  #         opacity = 0.5,
  #         color = "transparent", 
  #         fillOpacity = 0.7,
  #         group = "Frecuencia",
  #         label = ~paste0(
  #           "<b>Nombre municipio:</b> ", NOMGEO.x, "<br>",
  #           "<b>Nombre de la entidad:</b> ", NOMGEO.y, "<br>",
  #           "<b>Frecuencia:</b> ", n
  #         ) %>% lapply(htmltools::HTML),
  #         labelOptions = labelOptions(
  #           style = list("font-weight" = "bold", "color" = "black"),
  #           textsize = "12px",
  #           direction = "auto"
  #         )
  #       ) %>%
  #       clearControls() %>%  # Elimina la leyenda anterior
  #       addLegend(
  #         pal = pal,
  #         values = data_graf()$n,
  #         title = "Frecuencia",
  #         position = "bottomright"
  #       )
  #   } else {
  #     leafletProxy("mapa", data = data_graf()) %>%
  #       clearShapes()   %>%
  #       addPolygons(
  #         fillColor = ~pal(n),
  #         weight = 0.3,
  #         opacity = 0.5,
  #         color = "transparent", 
  #         fillOpacity = 0.7,
  #         group = "Frecuencia",
  #         label = ~paste0(
  #           "<b>Nombre municipio:</b> ", NOMGEO.x, "<br>",
  #           "<b>Nombre de la entidad:</b> ", NOMGEO.y, "<br>",
  #           "<b>Frecuencia:</b> ", n
  #         ) %>% lapply(htmltools::HTML),
  #         labelOptions = labelOptions(
  #           style = list("font-weight" = "bold", "color" = "black"),
  #           textsize = "12px",
  #           direction = "auto"
  #         )
  #       ) %>%
  #       addPolylines(  # Dibujar solo las líneas de los límites estatales
  #         data = agee, 
  #         weight = 1, 
  #         color = "black",  
  #         opacity = 1,
  #         group = "Límites estatales"
  #       ) %>% 
  #       clearControls() %>%  # Elimina la leyenda anterior
  #       addLegend(
  #         pal = pal,
  #         values = data_graf()$n,
  #         title = "Frecuencia",
  #         position = "bottomright"
  #       )
  #   }
  # })
  
  ## Tabla de conteo de sanciones del mapa interactivo ----
  output$conteo_sanciones <- renderTable({
    datos_filtrados() %>% 
      count(sancion) %>%
      arrange(-n) %>% set_names(c("Tipo de sanción", "Conteo"))
    # Aquí puedes modificar los datos si es necesario
  })


  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

}