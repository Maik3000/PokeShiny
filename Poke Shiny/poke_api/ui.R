# ui.R

library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(DT)
library(shinycssloaders)

# Definición de la UI
ui <- dashboardPage(
  dashboardHeader(title = "Poke Shiny", titleWidth = 250),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inicio", tabName = "inicio", icon = icon("home")),
      menuItem("Pokédex", tabName = "analisis_avanzado", icon = icon("chart-line")),
      menuItem("Gráficos", tabName = "graficos", icon = icon("chart-bar")),
      menuItem("Comparación", tabName = "comparacion", icon = icon("balance-scale")),
      menuItem("Datos", tabName = "datos", icon = icon("table"))
    ),
    textInput('pokemon', 'Ingresa el nombre de un Pokémon', value = 'pikachu'),
    actionButton('fetch', 'Consultar Pokémon')
  ),
  dashboardBody(
    tags$head(tags$style(HTML("
      
      .skin-blue .main-header .navbar .sidebar-toggle {
        color: white;  /* Icono de toggle blanco */
      }
      .skin-blue .main-header .navbar .sidebar-toggle:hover {
        background-color: #8A1010;
        color: white;
      }
      .skin-blue .main-header .navbar .sidebar-toggle:focus {
        outline: none;
      }
      /* Estilo del encabezado */
      .skin-blue .main-header .navbar {
        background-color: #B71C1C;  /* Rojo oscuro */
      }
      .skin-blue .main-header .logo {
        background-color: #B71C1C;  /* Rojo oscuro */
        color: white;               /* Texto blanco */
      }
      .skin-blue .main-header .logo:hover {
        background-color: #8A1010;  /* Rojo más oscuro */
        color: white;
      }

      /* Estilo del sidebar: color de fondo */
      .skin-blue .main-sidebar {
        background-color: #2E2E2E;  /* Fondo gris oscuro */
      }

      /* Quitar franja azul del sidebar y cambiarla a rojo oscuro */
      .skin-blue .sidebar-menu > li.active > a,
      .skin-blue .sidebar-menu > li:hover > a {
        border-left: 5px solid #B71C1C;  /* Rojo oscuro */
        background-color: #424242;       /* Fondo gris más oscuro */
        color: white;                    /* Texto blanco */
      }

      /* Cambiar color de texto en hover */
      .skin-blue .sidebar-menu > li > a:hover {
        color: white;
        background-color: #5C5C5C;  /* Fondo gris intermedio */
      }

      /* Cambiar color del texto en el item seleccionado */
      .skin-blue .sidebar-menu > li.active > a {
        color: white;
        background-color: #5C5C5C;  /* Fondo gris intermedio */
      }

      /* Quitar borde azul en foco del input de texto */
      input:focus, textarea:focus, select:focus {
        outline: none;
        border-color: #B71C1C;  /* Rojo oscuro */
        box-shadow: 0 0 5px #B71C1C;
      }
    "))),
    
    tabItems(
      # Pestaña de Inicio
      tabItem(tabName = "inicio",
              h2("Bienvenido a la Poke Shiny"),
              p("Utiliza esta aplicación para explorar y comparar estadísticas de distintos Pokémon."),
              img(src = "https://images.unsplash.com/photo-1703023689216-8cdc0dbe419e?q=80&w=2062&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", height = "200px", style = "display: block; margin-left: auto; margin-right: auto;")),
      
      # Pestaña de Análisis Avanzado
      tabItem(tabName = "analisis_avanzado",
              h2("Pokédex"),
              DTOutput('allPokemonTable'),
              br(),
              
              h3("Análisis por poder"),
              uiOutput('variableSelectors'),
              actionButton('updatePlot', 'Actualizar Gráfico'),
              plotlyOutput('scatterPlot')
      ),
      
      # Pestaña de Gráficos
      tabItem(tabName = "graficos",
              h2("Gráficos Interactivos"),
              textInput('pokemon', 'Ingresa el nombre de un Pokémon', value = 'metapod'),
              checkboxGroupInput('selected_stats', 'Selecciona las estadísticas a mostrar:',
                                 choices = c("hp", "attack", "defense", "special_attack", "special_defense", "speed"),
                                 selected = c("hp", "attack", "defense", "special_attack", "special_defense", "speed"),
                                 inline = TRUE),
              actionButton("updatePlot", "Actualizar Grafica"),  
              plotlyOutput('pokemonPlot', height = 400)  
      ),
      
      # Pestaña de Comparación
      tabItem(tabName = "comparacion",
              h2("Comparación de Pokémon"),
              fluidRow(
                column(6, textInput('pokemon1', 'Pokémon 1', value = 'bulbasaur')),
                column(6, textInput('pokemon2', 'Pokémon 2', value = 'charmander'))
              ),
              actionButton('compare', 'Comparar'),
              checkboxGroupInput('selected_stats_compare', 'Selecciona las estadísticas a comparar:',
                                 choices = c("hp", "attack", "defense", "special_attack", "special_defense", "speed"),
                                 selected = c("hp", "attack", "defense", "special_attack", "special_defense", "speed"),
                                 inline = TRUE),
              plotlyOutput('comparisonPlot') 
      ),
      
      # Pestaña de Datos Interactivos
      tabItem(tabName = "Datos",
              h2("Explorador de Datos Pokémon"),
              p("Utiliza los filtros para explorar los datos de los Pokémon y generar gráficos dinámicos."),
              hr(),
              
              # Filtros interactivos
              h3("Filtros"),
              fluidRow(
                column(4, 
                       selectInput("type1_filter", "Filtrar por Tipo Primario:",
                                   choices = c("Todos"), selected = "Todos")), # Inicialmente vacío
                column(4, 
                       sliderInput("hp_filter", "Filtrar por HP:",
                                   min = 0, max = 255, value = c(0, 255),
                                   step = 5, pre = "HP: ")),
                column(4, 
                       sliderInput("attack_filter", "Filtrar por Ataque:",
                                   min = 0, max = 200, value = c(0, 200),
                                   step = 5, pre = "Ataque: "))
              ),
              hr(),
              
              # Tabla interactiva
              h3("Tabla de Datos Filtrados"),
              p("La tabla muestra los Pokémon que cumplen con los criterios seleccionados."),
              DTOutput("filteredTable") %>% withSpinner(color = "#B71C1C"),  # Agrega un spinner de carga
              
              hr(),
              
              # Gráfico dinámico
              h3("Gráfico Dinámico"),
              p("Selecciona las variables para los ejes X e Y y genera un gráfico interactivo."),
              fluidRow(
                column(6, selectInput("x_axis", "Eje X:", 
                                      choices = c("hp", "attack", "defense", "special_attack", "special_defense", "speed"),
                                      selected = "attack")),
                column(6, selectInput("y_axis", "Eje Y:", 
                                      choices = c("hp", "attack", "defense", "special_attack", "special_defense", "speed"),
                                      selected = "defense"))
              ),
              plotlyOutput("dynamicPlot") %>% withSpinner(color = "#B71C1C"),  # Agrega un spinner de carga
              
              hr(),
              
              # Botón para descargar datos
              h3("Descargar Datos"),
              p("Descarga los datos filtrados en formato CSV para analizarlos fuera de la aplicación."),
              downloadButton("downloadData", "Descargar Datos Filtrados", class = "btn-primary")
      )
      
      
    )  
  )
)
