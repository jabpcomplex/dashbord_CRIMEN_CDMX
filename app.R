
library(readxl)
library(openxlsx)
library(sf)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(lubridate) #
library(plotly)
library(leaflet)
library(leaflet.extras)
library(shiny)
library(shinyjs)
library(shinymaterial)


rm(list = ls())



alcaldias <- read_sf("data/ALCALDIAS.gpkg") %>% sf::st_transform('+proj=longlat +datum=WGS84')


datos <- read.csv("data/victimasFGJ_2024.csv")



datos$fecha_hecho2 <- as.Date(datos$fecha_hecho)


# Eliminar datos sin coordenadas
datos<- datos%>%filter(!is.na(latitud))
# Filtrar solo 2024
datos<- datos%>%filter(fecha_hecho2 > "2024-01-01")
# Creamos id
datos$folio<-row.names(datos)

# CATEGORIAS UNICAS DE DELITOS
unique(datos$categoria_delito)






colores_personalizados <- c(
  "HECHO NO DELICTIVO" = "#9370DB" ,
  "ROBO A TRANSEUNTE EN VÍA PÚBLICA CON Y SIN VIOLENCIA" = "orange",
  "ROBO DE VEHÍCULO CON Y SIN VIOLENCIA" = "#000080",
  "ROBO A PASAJERO A BORDO DEL METRO CON Y SIN VIOLENCIA"= "darkorange",
  "ROBO A PASAJERO A BORDO DE TAXI CON VIOLENCIA"="#B2B223",
  "ROBO A CASA HABITACIÓN CON VIOLENCIA"  = "pink"  ,
  "ROBO A REPARTIDOR CON Y SIN VIOLENCIA" = "brown",
  "VIOLACIÓN" ="red"  ,
  "ROBO A CUENTAHABIENTE SALIENDO DEL CAJERO CON VIOLENCIA" = "lightblue",
  "ROBO A TRANSPORTISTA CON Y SIN VIOLENCIA" = "lightgreen",
  "ROBO A NEGOCIO CON VIOLENCIA" = "cyan",
  "DELITO DE BAJO IMPACTO" = "darkgreen",
  "HOMICIDIO DOLOSO" = "black" ,
  "ROBO A PASAJERO A BORDO DE MICROBUS CON Y SIN VIOLENCIA" = "darkorange",
  "LESIONES DOLOSAS POR DISPARO DE ARMA DE FUEGO" = "purple",
  "SECUESTRO" = "salmon"
)

colors = c( "#9370DB" ,"orange", "#000080","darkorange", "#B2B223", "pink" ,"brown","red","lightblue","lightgreen","cyan","darkgreen","black","darkorange","purple","salmon")
labels = c("HECHO NO DELICTIVO","ROBO A TRANSEUNTE EN VÍA PÚBLICA CON Y SIN VIOLENCIA", "ROBO DE VEHÍCULO CON Y SIN VIOLENCIA" ,"ROBO A PASAJERO A BORDO DEL METRO CON Y SIN VIOLENCIA","ROBO A PASAJERO A BORDO DE TAXI CON VIOLENCIA","ROBO A CASA HABITACIÓN CON VIOLENCIA" ,"ROBO A REPARTIDOR CON Y SIN VIOLENCIA",
           "VIOLACIÓN" ,"ROBO A CUENTAHABIENTE SALIENDO DEL CAJERO CON VIOLENCIA","ROBO A TRANSPORTISTA CON Y SIN VIOLENCIA" ,"ROBO A NEGOCIO CON VIOLENCIA" ,"DELITO DE BAJO IMPACTO","HOMICIDIO DOLOSO","ROBO A PASAJERO A BORDO DE MICROBUS CON Y SIN VIOLENCIA","LESIONES DOLOSAS POR DISPARO DE ARMA DE FUEGO","SECUESTRO" )




ui <- fluidPage(
  tags$head(includeCSS('www/css/style_app.css', package = 'myPackage')),
  

  titlePanel(div(class = "title-panel-custom","Incidentes Fiscalia General de Justicia 2024"),windowTitle = "FGJ"),
  
  fluidRow(
    column(2,
           
           tags$div(
             style = "text-align: center;",
             tags$h3("Folios en base: ", style = "display: inline-block; margin-right: 15px;"),
             tags$div(id = 'wrap_div', class = 'error', style = "display: inline-block; font-size: 22px;", textOutput('folios_unicos'))
           ),br(),
           
           div(class = "titulos_div", "Día / Periodo:"),
           dateRangeInput("rango", NULL, 
                          start = min(datos$fecha_hecho2, na.rm = TRUE),
                          end = max(datos$fecha_hecho2, na.rm = TRUE),
                          format = "dd-mm-yyyy"),br(),
           
           div(class = "titulos_div", "Delito:"),
           checkboxGroupInput("filtro_evento", NULL, choices = unique(datos$categoria_delito)%>%sort(), selected = NULL),
           
         




           
           
           actionButton("reset_filtros", "Reiniciar Filtros", class = "btn-reset"),
    ),
    
    column(10,
           fluidRow(
             column(6,
                    
                    div(class = "titulos_div", "Seleccionar Alcaldía:"),
                    selectInput("filtro_alcaldia", NULL, choices = unique(datos$alcaldia_hecho)%>%sort(), selected = NULL, multiple = T),br(),
                    
                    div(class = "titulos_div", "Mapa"),

                    div(
                      leafletOutput("mapa", height = "100%", width = "100%"))
                    






                    


                    
                    
                    
             ),
             column(6,
                    
                    


                    
                    div(class = "titulos_div", "Distribución por Alcaldía"),
                    plotOutput("gr1_origen_incidente", height = "200px"),
                    
                    div(class = "titulos_div", "Distribución de Eventos Relevantes"),
                    plotOutput("gr3_PASTEL", height = "200px"),
                    
                    div(class = "titulos_div", "Tendencia Temporal de Eventos"),
                    plotOutput("gr2_lineas", height = "200px"),
                    
                    
             ),
             
           ),
           






    )
  )
)





server <- function(input, output, session) {
  
  

  datos_filtrados <- reactive({
    base <- datos %>%
      filter(
        fecha_hecho2 >= input$rango[1],
        fecha_hecho2 <= input$rango[2]
      )
    

    if (!is.null(input$filtro_alcaldia)) {
      base <- base %>% filter(alcaldia_hecho %in% input$filtro_alcaldia)
    }
    

    if (!is.null(input$filtro_evento)) {
      base <- base %>% filter(categoria_delito %in% input$filtro_evento)
    }
    
    return(base)
  })
  





















  output$folios_unicos <- renderText({
    nrow(datos_filtrados())
  })
  



  

  output$gr1_origen_incidente <- renderPlot({
    datos_filtrados() %>%
      count(alcaldia_hecho) %>%
      arrange(desc(n)) %>%
      ggplot(aes(x = n, y = reorder(alcaldia_hecho, n), fill = alcaldia_hecho)) +
      geom_bar(stat = "identity", color = "black", show.legend = FALSE) +
      scale_fill_manual(values = rep("#9F2241", 16)) +
      theme_minimal() +
      geom_text(aes(label = n), position = position_stack(vjust = 0.5), size = 4, color = "#EEE8AA") +
      labs(x="EVentos Relevantes" ,y="Folios")+

      theme(
        axis.text = element_text(size = 11),  # Tamaño 12px para ejes
        axis.title = element_text(size = 11),
        panel.grid.minor = element_blank()  # Limpiar cuadrícula menor
      )
  })
  
  

  output$gr2_lineas <- renderPlot({
    plot_data <- datos_filtrados() %>%
      count(fecha_hecho2)
    

    max_n <- max(plot_data$n, na.rm = TRUE)
    label_offset <- max_n * 0.05  # 5% del valor máximo como margem
    
    ggplot(plot_data, aes(x = fecha_hecho2, y = n)) +
      geom_line(color = "#9F2241", size = 1) +
      geom_point(color = "#9F2241", size = 2.5) +

      geom_text(
        aes(label = n, y = n + label_offset),  # Desplaza hacia arriba
        color = "#BC955C",
        size = 3.5,
        vjust = 0,  # Ajuste vertical
        check_overlap = TRUE,  # Evita superposición
        angle = 30  # Ligera inclinación para mejor ajuste
      ) +
      theme_minimal() +
      labs(x = "Fecha", y = "Cantidad de eventos") +

      theme(
        axis.text = element_text(size = 12),  # Tamaño 12px para ejes
        axis.title = element_text(size = 12),
        panel.grid.minor = element_blank()  # Limpiar cuadrícula menor
      ) +

      scale_y_continuous(expand = expansion(mult = c(0.05, 0.15)))  # 15% más arriba
    
    
  })
  

  output$gr3_PASTEL <- renderPlot({
    datos_grafico <- datos_filtrados()%>%
      group_by(categoria_delito) %>%summarise(`Recuento de folio`=length(unique(folio)))%>% arrange(desc(`Recuento de folio`))%>%
      mutate(
        porcentaje = `Recuento de folio` / sum(`Recuento de folio`) * 100,
        angulo = cumsum(porcentaje) - 0.5 * porcentaje,
        ypos = cumsum(porcentaje) - 0.5 * porcentaje  # Posición para etiquetas
      )
    

    ggplot(datos_grafico, aes(x = "", y = porcentaje, fill = categoria_delito)) +
      geom_bar(stat = "identity", width = 1, color = "#EEE8AA") +
      coord_polar(theta = "y") +  # Convierte las barras en un gráfico de pastel
      geom_text(aes(label = paste0(round(porcentaje, 2), "%")), 
                position = position_stack(vjust = 0.5),color="#EEE8AA", size = 5) +
      scale_fill_manual(
        name = "Eventos Relevantes",
        values = colores_personalizados,

        breaks = labels,
        drop = FALSE  # Mantiene todos los niveles en la leyenda
      ) +
      theme_void() +
      theme(
        legend.position = "right",
        legend.title = element_text(face = "bold", size = 12),
        legend.text = element_text(size = 10))
  })
  
  




































































































  
  
  
  
  
  
  
  




























  observe({
    proxy <- leafletProxy("mapa", data = datos_filtrados())
    

    proxy %>% clearControls()
    

    colores_eventos <- colores_personalizados








    if (!is.null(input$filtro_evento)) {
      

      eventos_visibles <- intersect(input$filtro_evento, names(colores_eventos))
      colores_visibles <- colores_eventos[eventos_visibles]
      
      proxy %>% addLegend(
        "bottomright",
        colors = colores_visibles,
        labels = names(colores_visibles),
        title = "Tipo Delito",
        opacity = 1
      )






      
      
    }else{
      proxy%>% addLegend("bottomright", 
                         colors = colors,
                         labels = labels,
                         title = "Tipo Delito",
                         opacity = 1)







    }
  })
  
  
  mapa1<- reactive({
    base_mapa<- datos_filtrados()


    

    if (!is.null(input$filtro_alcaldia) & !is.null(input$filtro_evento) | !is.null(input$filtro_alcaldia) & is.null(input$filtro_evento) | is.null(input$filtro_alcaldia) & !is.null(input$filtro_evento)){
      
      mapa_<-leaflet() %>%
        addResetMapButton()%>% #agrega botones de zoom
        clearBounds()%>%
        addMapPane("polygons",zIndex = 500)%>%
        addMapPane("ce",zIndex = 510)%>%
        addMapPane("li",zIndex=570)%>%
        addMapPane("lo",zIndex = 580)%>%
        addMapPane("lu",zIndex = 595)%>%
        addProviderTiles(providers$CartoDB.Positron)%>%
        setView(
          lng = mean(base_mapa$longitud, na.rm = TRUE),
          lat = mean(base_mapa$latitud, na.rm = TRUE),
          zoom = 11) %>%
        

        addCircles(data = base_mapa ,lng = as.numeric(base_mapa$longitud), 
                   lat = as.numeric(base_mapa$latitud), label = as.character(base_mapa$folio),
                   popup = paste(sep = "" ,
                                 "<b>Folio:</b> ", as.character(base_mapa$folio),"<br>",
                                 "<b>Alcaldía inicio:</b> ", as.character(base_mapa$alcaldia_hecho),"<br>",
                                 "<b>Colonia:</b> ", as.character(base_mapa$colonia_hecho),"<br>",
                                 "<b>Delito:</b> ", as.character(base_mapa$delito),"<br>",
                                 "<b>Calidad Juridica</b> ", as.character(base_mapa$calidad_juridica),"<br>" ),
                   color = ~case_when(
                                      categoria_delito == "HECHO NO DELICTIVO" ~ "#9370DB" ,
                                      categoria_delito == "ROBO A TRANSEUNTE EN VÍA PÚBLICA CON Y SIN VIOLENCIA" ~ "orange",
                                      categoria_delito == "ROBO DE VEHÍCULO CON Y SIN VIOLENCIA" ~ "#000080",
                                      categoria_delito == "ROBO A PASAJERO A BORDO DEL METRO CON Y SIN VIOLENCIA"~ "darkorange",
                                      categoria_delito == "ROBO A PASAJERO A BORDO DE TAXI CON VIOLENCIA"~"#B2B223",
                                      categoria_delito == "ROBO A CASA HABITACIÓN CON VIOLENCIA"  ~ "pink"  ,
                                      categoria_delito == "ROBO A REPARTIDOR CON Y SIN VIOLENCIA" ~ "brown",
                                      categoria_delito == "VIOLACIÓN" ~"red"  ,
                                      categoria_delito == "ROBO A CUENTAHABIENTE SALIENDO DEL CAJERO CON VIOLENCIA" ~ "lightblue",
                                      categoria_delito == "ROBO A TRANSPORTISTA CON Y SIN VIOLENCIA" ~ "lightgreen",
                                      categoria_delito == "ROBO A NEGOCIO CON VIOLENCIA" ~ "cyan",
                                      categoria_delito == "DELITO DE BAJO IMPACTO" ~ "darkgreen",
                                      categoria_delito == "HOMICIDIO DOLOSO" ~ "black" ,
                                      categoria_delito == "ROBO A PASAJERO A BORDO DE MICROBUS CON Y SIN VIOLENCIA" ~ "darkorange",
                                      categoria_delito == "LESIONES DOLOSAS POR DISPARO DE ARMA DE FUEGO" ~ "purple",
                                      categoria_delito == "SECUESTRO" ~ "salmon",
                     TRUE ~ "gray"
                   ),
                   radius = 8,options = pathOptions(pane="lu"),group="INCIDENTES") %>% 
        addPolygons(data = alcaldias, options = pathOptions(pane="polygons"),color = "black",fillColor = "transparent",fillOpacity =1,dashArray = 5,weight = 2.5,popup = alcaldias$sector,
                    highlightOptions = highlightOptions(color = "cyan", weight = 5,fillOpacity = 0.7) , group="ALCALDIAS")%>%







        



















        
        































        
        addLayersControl(overlayGroups = c( "&nbsp; <b>Capas</b> &nbsp; ",
                                            "ALCALDIAS"

                                            ),options = layersControlOptions(collapsed = T))%>% 
        
        
        htmlwidgets::onRender(jsCode = htmlwidgets::JS("function(btn,map){ 
                                                 var lc=document.getElementsByClassName('leaflet-control-layers-overlays')[0]
                                                 lc.getElementsByTagName('input')[0].style.display='none';
                                           
                                                 lc.getElementsByTagName('div')[0].style.fontSize='100%';
                                                 lc.getElementsByTagName('div')[0].style.textAlign='center';
                                                 lc.getElementsByTagName('div')[0].style.color='white';
                                                 lc.getElementsByTagName('div')[0].style.backgroundColor='#9F2241';
                                                 ; } "))%>%
        
        hideGroup( c(  "&nbsp; <b>CAPAS</b> &nbsp; ",
                       
                       "ALCALDIAS"

                       ))
      
      return(mapa_)
      
    } else{
      

      mapa_<-leaflet() %>%
        addResetMapButton()%>% #agrega botones de zoom
        clearBounds()%>%
        addMapPane("polygons",zIndex = 500)%>%
        addMapPane("ce",zIndex = 510)%>%
        addMapPane("li",zIndex=570)%>%
        addMapPane("lo",zIndex = 580)%>%
        addMapPane("lu",zIndex = 595)%>%
        addProviderTiles(providers$CartoDB.Positron)%>%
        setView(
          lng = mean(base_mapa$longitud, na.rm = TRUE),
          lat = mean(base_mapa$latitud, na.rm = TRUE),
          zoom = 11) %>%
        
        addCircles(data = base_mapa ,lng = as.numeric(base_mapa$longitud), 
                   lat = as.numeric(base_mapa$latitud), label = as.character(base_mapa$folio),
                   popup = paste(sep = "" ,
                                 "<b>Folio:</b> ", as.character(base_mapa$folio),"<br>",
                                 "<b>Alcaldía inicio:</b> ", as.character(base_mapa$alcaldia_hecho),"<br>",
                                 "<b>Sector inicio:</b> ", as.character(base_mapa$sector_inicio),"<br>",
                                 "<b>Colinia:</b> ", as.character(base_mapa$colonia_hecho),"<br>",
                                 "<b>Delito:</b> ", as.character(base_mapa$delito),"<br>",
                                 "<b>Calidad Juridica</b> ", as.character(base_mapa$calidad_juridica),"<br>" ),
                   color = ~case_when(
                     categoria_delito == "HECHO NO DELICTIVO" ~ "#9370DB" ,
                     categoria_delito == "ROBO A TRANSEUNTE EN VÍA PÚBLICA CON Y SIN VIOLENCIA" ~ "orange",
                     categoria_delito == "ROBO DE VEHÍCULO CON Y SIN VIOLENCIA" ~ "#000080",
                     categoria_delito == "ROBO A PASAJERO A BORDO DEL METRO CON Y SIN VIOLENCIA"~ "darkorange",
                     categoria_delito == "ROBO A PASAJERO A BORDO DE TAXI CON VIOLENCIA"~"#B2B223",
                     categoria_delito == "ROBO A CASA HABITACIÓN CON VIOLENCIA"  ~ "pink"  ,
                     categoria_delito == "ROBO A REPARTIDOR CON Y SIN VIOLENCIA" ~ "brown",
                     categoria_delito == "VIOLACIÓN" ~"red"  ,
                     categoria_delito == "ROBO A CUENTAHABIENTE SALIENDO DEL CAJERO CON VIOLENCIA" ~ "lightblue",
                     categoria_delito == "ROBO A TRANSPORTISTA CON Y SIN VIOLENCIA" ~ "lightgreen",
                     categoria_delito == "ROBO A NEGOCIO CON VIOLENCIA" ~ "cyan",
                     categoria_delito == "DELITO DE BAJO IMPACTO" ~ "darkgreen",
                     categoria_delito == "HOMICIDIO DOLOSO" ~ "black" ,
                     categoria_delito == "ROBO A PASAJERO A BORDO DE MICROBUS CON Y SIN VIOLENCIA" ~ "darkorange",
                     categoria_delito == "LESIONES DOLOSAS POR DISPARO DE ARMA DE FUEGO" ~ "purple",
                     categoria_delito == "SECUESTRO" ~ "salmon",
                     TRUE ~ "gray"),
                   radius = 8,options = pathOptions(pane="lu")) %>% 
        
        addPolygons(data = alcaldias, options = pathOptions(pane="polygons"),color = "black",fillColor = "transparent",fillOpacity =1,dashArray = 5,weight = 2.5,popup = alcaldias$sector,
                    highlightOptions = highlightOptions(color = "cyan", weight = 5,fillOpacity = 0.7) , group="ALCALDIAS")%>%







        



















        
        addLayersControl(overlayGroups = c( "&nbsp; <b>Capas</b> &nbsp; ",
                                            "ALCALDIAS"

                                            ),options = layersControlOptions(collapsed = T))%>% 
        
        
        htmlwidgets::onRender(jsCode = htmlwidgets::JS("function(btn,map){ 
                                                 var lc=document.getElementsByClassName('leaflet-control-layers-overlays')[0]
                                                 lc.getElementsByTagName('input')[0].style.display='none';
                                           
                                                 lc.getElementsByTagName('div')[0].style.fontSize='100%';
                                                 lc.getElementsByTagName('div')[0].style.textAlign='center';
                                                 lc.getElementsByTagName('div')[0].style.color='white';
                                                 lc.getElementsByTagName('div')[0].style.backgroundColor='#9F2241';
                                                 ; } "))%>%
        addLegend("bottomright", 
                  colors = colors,
                  labels = labels,
                  title = "Tipo Delito",
                  opacity = 1)%>%





        hideGroup( c(  "&nbsp; <b>CAPAS</b> &nbsp; ",
                       
                       "ALCALDIAS","SECTORES","CUADRANTES","COLONIAS","COBERTURA"))
      
      return(mapa_)
    }
  })
  
  
  output$mapa <- renderLeaflet({
    mapa1()
  })
  
  

  observeEvent(input$reset_filtros, {
    
    updateDateRangeInput(session, "rango", start = min(datos$fecha_hecho2, na.rm = TRUE), end = max(datos$fecha_hecho2, na.rm = TRUE))
    
    selectInput(session, "filtro_alcaldia",choices = unique(datos$alcaldia_hecho)%>%sort(), selected = NULL)
    

    
    updateCheckboxGroupInput(session, "filtro_evento",choices = unique(datos$categoria_delito)%>%sort(), selected = NULL)
  })
  
  



















}







shinyApp(ui, server)