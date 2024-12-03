# server.R

library(shiny)
library(dplyr)
library(plotly)
library(DT)

# Definición del Servidor
server <- function(input, output, session) {
  
  # Cargar los datos desde el archivo CSV
  pokemon_data <- reactive({
    tryCatch({
      data <- read.csv("datos/pokemon_data.csv", stringsAsFactors = FALSE)
      num_cols <- c("hp", "attack", "defense", "special_attack", "special_defense", "speed")
      data[num_cols] <- lapply(data[num_cols], as.numeric)
      print("Datos cargados correctamente")
      return(data)
    }, error = function(e) {
      showNotification("Error al cargar los datos: Verifica el archivo CSV.", type = "error")
      return(NULL)
    })
  })
  
  # Mostrar la tabla de todos los Pokémon
  output$allPokemonTable <- renderDT({
    data <- pokemon_data()
    req(data)  # Asegura que los datos no sean NULL
    
    # Eliminar la columna 'sprite'
    data <- data %>% select(-sprite)
    datatable(data, selection = 'multiple', options = list(pageLength = 10))
  })
  
  # Generar selectores de variables para el gráfico
  output$variableSelectors <- renderUI({
    req(pokemon_data())
    num_vars <- c("hp", "attack", "defense", "special_attack", "special_defense", "speed")
    fluidRow(
      column(6, selectInput('xVariable', 'Variable en el eje X', choices = num_vars, selected = 'attack')),
      column(6, selectInput('yVariable', 'Variable en el eje Y', choices = num_vars, selected = 'defense'))
    )
  })
  
  # Generar el gráfico de dispersión
  observeEvent(input$updatePlot, {
    req(input$allPokemonTable_rows_selected)
    req(input$xVariable)
    req(input$yVariable)
    data <- pokemon_data()
    selected_data <- data[input$allPokemonTable_rows_selected, ]
    
    # Preparar los datos para el gráfico
    selected_data$type1 <- as.factor(selected_data$type1)
    
    output$scatterPlot <- renderPlotly({
      plot_ly(selected_data, x = as.formula(paste0("~", input$xVariable)), y = as.formula(paste0("~", input$yVariable)),
              type = 'scatter', mode = 'markers', color = ~type1, colors = "Set1",
              text = ~paste("Nombre:", name, "<br>Tipo:", type1, ifelse(!is.na(type2), paste("/", type2), ""))) %>%
        layout(title = "Gráfico de Dispersión de Pokémon",
               xaxis = list(title = input$xVariable),
               yaxis = list(title = input$yVariable))
    })
  })
  
  # Función para obtener datos de un Pokémon específico desde el archivo CSV
  getPokemonData <- function(pokemonName) {
    data <- pokemon_data()
    pokemon <- data %>% filter(tolower(name) == tolower(pokemonName))
    if (nrow(pokemon) > 0) {
      stats <- data.frame(
        Estadística = c("hp", "attack", "defense", "special_attack", "special_defense", "speed"),
        Valor = c(pokemon$hp, pokemon$attack, pokemon$defense, pokemon$special_attack, pokemon$special_defense, pokemon$speed),
        stringsAsFactors = FALSE
      )
      return(list(stats = stats, data = pokemon))
    } else {
      return(NULL)
    }
  }
  
  # Mostrar las estadísticas de un Pokémon específico
  observeEvent(input$fetch, {
    pokemon_name <- input$pokemon
    stats_result <- getPokemonData(pokemon_name)
    if (!is.null(stats_result)) {
      stats <- stats_result$stats
      showModal(modalDialog(
        title = paste("Estadísticas de", pokemon_name),
        renderPlotly({
          plot_ly(stats, x = ~Estadística, y = ~Valor, type = 'bar',
                  marker = list(color = 'rgba(55, 128, 191, 0.6)')) %>%
            layout(title = paste("Estadísticas de", pokemon_name))
        }),
        easyClose = TRUE,
        size = "l"
      ))
    } else {
      showNotification("No se encontraron datos para el Pokémon ingresado.", type = "error")
    }
  })
  
  # Comparación de Pokémon
  observeEvent(input$compare, {
    req(input$pokemon1, input$pokemon2)
    data <- pokemon_data()
    
    # Filtrar los datos de los Pokémon seleccionados
    pokemon1 <- data %>% filter(tolower(name) == tolower(input$pokemon1))
    pokemon2 <- data %>% filter(tolower(name) == tolower(input$pokemon2))
    
    # Verificar que ambos Pokémon existan en los datos
    if (nrow(pokemon1) > 0 && nrow(pokemon2) > 0) {
      # Estadísticas seleccionadas para la comparación
      selected_stats <- input$selected_stats_compare
      
      # Verificar que las estadísticas seleccionadas existan en los datos
      valid_stats <- c("hp", "attack", "defense", "special_attack", "special_defense", "speed")
      selected_stats <- intersect(selected_stats, valid_stats)
      
      if (length(selected_stats) == 0) {
        showNotification("No se seleccionaron estadísticas válidas para la comparación.", type = "error")
        return()
      }
      
      # Crear un data frame para la comparación
      comparison_data <- data.frame(
        Estadística = selected_stats,
        Pokémon1 = as.numeric(pokemon1[1, selected_stats]),
        Pokémon2 = as.numeric(pokemon2[1, selected_stats]),
        stringsAsFactors = FALSE
      )
      
      # Renderizar el gráfico de comparación
      output$comparisonPlot <- renderPlotly({
        plot_ly(comparison_data, x = ~Estadística, y = ~Pokémon1, type = 'bar', name = input$pokemon1,
                marker = list(color = 'rgba(55, 128, 191, 0.6)')) %>%
          add_trace(y = ~Pokémon2, name = input$pokemon2,
                    marker = list(color = 'rgba(219, 64, 82, 0.6)')) %>%
          layout(title = "Comparación de Pokémon",
                 barmode = 'group',
                 xaxis = list(title = "Estadísticas"),
                 yaxis = list(title = "Valores"))
      })
    } else {
      showNotification("No se encontraron datos para uno o ambos Pokémon ingresados.", type = "error")
    }
  })
  # Pestaña de Gráficos Interactivos
  observeEvent(input$pokemon, {
    req(input$pokemon)  # Asegura que el usuario haya ingresado un Pokémon
    data <- pokemon_data()
    
    # Filtrar el Pokémon ingresado por el usuario
    selected_pokemon <- data %>% filter(tolower(name) == tolower(input$pokemon))
    
    if (nrow(selected_pokemon) > 0) {
      # Estadísticas seleccionadas por el usuario
      selected_stats <- input$selected_stats
      
      # Verificar que las estadísticas seleccionadas existan
      valid_stats <- c("hp", "attack", "defense", "special_attack", "special_defense", "speed")
      selected_stats <- intersect(selected_stats, valid_stats)
      
      if (length(selected_stats) == 0) {
        showNotification("No se seleccionaron estadísticas válidas para graficar.", type = "error")
        return()
      }
      
      # Crear un data frame con las estadísticas seleccionadas
      stats_data <- data.frame(
        Estadística = selected_stats,
        Valor = as.numeric(selected_pokemon[1, selected_stats]),
        stringsAsFactors = FALSE
      )
      
      # Renderizar el gráfico de barras
      output$pokemonPlot <- renderPlotly({
        plot_ly(stats_data, x = ~Estadística, y = ~Valor, type = 'bar',
                marker = list(color = 'rgba(55, 128, 191, 0.6)')) %>%
          layout(title = paste("Estadísticas de", input$pokemon),
                 xaxis = list(title = "Estadísticas"),
                 yaxis = list(title = "Valores"))
      })
    } else {
      showNotification("No se encontraron datos para el Pokémon ingresado.", type = "error")
    }
  })
  # Generar el gráfico interactivo basado en las estadísticas seleccionadas
  observeEvent(input$updatePlot, {
    req(input$pokemon)  # Asegura que el usuario haya ingresado un Pokémon
    req(input$selected_stats)  # Asegura que haya estadísticas seleccionadas
    
    data <- pokemon_data()
    
    # Filtrar el Pokémon ingresado por el usuario
    selected_pokemon <- data %>% filter(tolower(name) == tolower(input$pokemon))
    
    if (nrow(selected_pokemon) > 0) {
      # Estadísticas seleccionadas por el usuario
      selected_stats <- input$selected_stats
      
      # Verificar que las estadísticas seleccionadas existan
      valid_stats <- c("hp", "attack", "defense", "special_attack", "special_defense", "speed")
      selected_stats <- intersect(selected_stats, valid_stats)
      
      if (length(selected_stats) == 0) {
        showNotification("No se seleccionaron estadísticas válidas para graficar.", type = "error")
        return()
      }
      
      # Crear un data frame con las estadísticas seleccionadas
      stats_data <- data.frame(
        Estadística = selected_stats,
        Valor = as.numeric(selected_pokemon[1, selected_stats]),
        stringsAsFactors = FALSE
      )
      
      # Verificar si hay valores NA y reemplazarlos por 0 (opcional)
      stats_data$Valor[is.na(stats_data$Valor)] <- 0
      
      # Renderizar el gráfico de barras
      output$pokemonPlot <- renderPlotly({
        plot_ly(stats_data, x = ~Estadística, y = ~Valor, type = 'bar',
                marker = list(color = 'rgba(55, 128, 191, 0.6)')) %>%
          layout(title = paste("Estadísticas de", input$pokemon),
                 xaxis = list(title = "Estadísticas"),
                 yaxis = list(title = "Valores"))
      })
    } else {
      showNotification("No se encontraron datos para el Pokémon ingresado.", type = "error")
    }
  })
  
  # Pestaña de Datos Interactivos
  
    
    # Actualizar las opciones del filtro de tipo primario
    observe({
      data <- pokemon_data()
      req(data)  # Asegúrate de que los datos no sean NULL
      updateSelectInput(session, "type1_filter", 
                        choices = c("Todos", unique(data$type1)), 
                        selected = "Todos")
    })
    
    # Renderizar la tabla filtrada
    output$filteredTable <- renderDT({
      data <- pokemon_data()
      req(data)  # Asegúrate de que los datos no sean NULL
      
      # Aplicar filtros
      if (input$type1_filter != "Todos") {
        data <- data %>% filter(type1 == input$type1_filter)
      }
      data <- data %>% 
        filter(hp >= input$hp_filter[1], hp <= input$hp_filter[2]) %>%
        filter(attack >= input$attack_filter[1], attack <= input$attack_filter[2])
      
      datatable(data, options = list(pageLength = 10))
    })
    
    # Renderizar el gráfico dinámico
    output$dynamicPlot <- renderPlotly({
      data <- pokemon_data()
      req(data)  # Asegúrate de que los datos no sean NULL
      
      # Aplicar filtros
      if (input$type1_filter != "Todos") {
        data <- data %>% filter(type1 == input$type1_filter)
      }
      data <- data %>% 
        filter(hp >= input$hp_filter[1], hp <= input$hp_filter[2]) %>%
        filter(attack >= input$attack_filter[1], attack <= input$attack_filter[2])
      
      # Crear gráfico
      plot_ly(data, x = as.formula(paste0("~", input$x_axis)), 
              y = as.formula(paste0("~", input$y_axis)), 
              type = "scatter", mode = "markers", color = ~type1,
              text = ~paste("Nombre:", name, "<br>Tipo:", type1, ifelse(!is.na(type2), paste("/", type2), ""))) %>%
        layout(title = "Gráfico Dinámico de Pokémon",
               xaxis = list(title = input$x_axis),
               yaxis = list(title = input$y_axis))
    })
    
    # Descargar datos filtrados
    output$downloadData <- downloadHandler(
      filename = function() {
        paste("pokemon_data_filtrado-", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        data <- pokemon_data()
        req(data)  # Asegúrate de que los datos no sean NULL
        
        # Aplicar filtros
        if (input$type1_filter != "Todos") {
          data <- data %>% filter(type1 == input$type1_filter)
        }
        data <- data %>% 
          filter(hp >= input$hp_filter[1], hp <= input$hp_filter[2]) %>%
          filter(attack >= input$attack_filter[1], attack <= input$attack_filter[2])
        
        write.csv(data, file, row.names = FALSE)
      }
    )
  }
