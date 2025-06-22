library(dplyr)
library(ggplot2)
library(tidyr)
library(magrittr)
library(janitor)
library(shinythemes)
library(scales)
library(leaflet)

options(digits=10)
  
server <- function(input, output, session) {

  # Elementos del mapa interactivo de órdenes de inspección ------

  ## Filtrado de datos para el mapa ----
  datos_filtrados <- reactive({
    req(input$filtro_fecha)
    req(input$rango_fechas)
    
    if(input$filtro_fecha == "Rango de fechas"){
      datos_filtrados <- sanciones %>%
        filter(
          fecha_orden >= input$rango_fechas[1] & 
            fecha_orden <= input$rango_fechas[2]
          )  
    } else {
      datos_filtrados <- sanciones %>%
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
  
  ## Capas reactivas del mapa -------
  
  
  observe({
    
    if(!is.null(input$playa_bagdad))         n_playa <- ifelse(input$playa_bagdad,nrow(playa_bagdad),0)
    if(!is.null(input$lag_madre))            n_lagm  <- ifelse(input$lag_madre,nrow(lag_madre),0)
    if(!is.null(input$municipios))           n_muns  <- ifelse(input$municipios,nrow(municipios),0)
    if(!is.null(input$ageb_rural))           n_agebr <- ifelse(input$ageb_rural,nrow(ageb_rural),0)
    if(!is.null(input$ageb_urbano))          n_agebu <- ifelse(input$ageb_urbano,nrow(ageb_urbano),0)
    if(!is.null(input$localidad_amanzanada)) n_lmnz  <- ifelse(input$localidad_amanzanada,nrow(localidad_amanzanada),0)
    if(!is.null(input$localidad_puntual))    n_lpunt <- ifelse(input$localidad_puntual,nrow(localidad_puntual),0)
    if(!is.null(input$manzana))              n_mnz   <- ifelse(input$manzana,nrow(manzana),0)
    if(!is.null(input$vialidad))             n_vial  <- ifelse(input$vialidad,nrow(vialidad),0)
    
    if(!is.null(input$puntos))             n_puntos  <- ifelse(input$puntos,nrow(puntos),0)
    
    leafletProxy("mapa") %>%
            clearShapes() %>%
            addPolygons(data = playa_bagdad[0:n_playa,], 
                        weight = 1, 
                        color = "black",  
                        opacity = 1,
                        group = "Playa Bagdad") %>%
      addPolygons(data = lag_madre[0:n_lagm,], 
                  weight = 1, 
                  color = "black",  
                  opacity = 1,
                  group = "Laguna madre") %>%
      addPolygons(data = municipios[0:n_muns,], 
                  weight = 1, 
                  color = "black",  
                  opacity = 1,
                  group = "Municipios") %>%
      addPolygons(data = ageb_rural[0:n_agebr,], 
                  weight = 1, 
                  color = "black",  
                  opacity = 1,
                  group = "AGEBS rural") %>%
      addPolygons(data = ageb_urbano[0:n_agebu,], 
                  weight = 1, 
                  color = "black",  
                  opacity = 1,
                  group = "AGEBS urbano") %>%
      addPolygons(data = localidad_amanzanada[0:n_lmnz,], 
                  weight = 1, 
                  color = "black",  
                  opacity = 1,
                  group = "Localidades amanzanadas") %>%
      addCircleMarkers(data = localidad_puntual[0:n_lpunt,],
                  stroke = FALSE, fillOpacity = 0.5,
                  group = "Localidades puntuales")  %>%
      addPolygons(data = manzana[0:n_mnz,], 
                  weight = 1, 
                  color = "black",  
                  opacity = 1,
                  group = "Manzanas") %>%
      addPolygons(data = vialidad[0:n_vial,], 
                  weight = 1, 
                  color = "black",  
                  opacity = 1,
                  group = "Vialidad") %>%
      addCircleMarkers(data = puntos[0:n_puntos,],
                       stroke = FALSE, fillOpacity = 0.5,
                  group = "Puntos")
    
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