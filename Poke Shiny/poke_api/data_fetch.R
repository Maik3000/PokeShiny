# data_fetch.R

library(httr)
library(jsonlite)
library(dplyr)

# Obtener la lista de los primeros 150 Pokémon
response <- GET("https://pokeapi.co/api/v2/pokemon?limit=150&offset=0")
if (status_code(response) == 200) {
  data <- content(response, as = "parsed", type = "application/json")
  pokemon_urls <- sapply(data$results, function(p) p$url)
  
  # Obtener detalles de cada Pokémon
  pokemon_list <- lapply(pokemon_urls, function(url) {
    response <- GET(url)
    if (status_code(response) == 200) {
      data <- content(response, as = "parsed", type = "application/json")
      types <- sapply(data$types, function(t) t$type$name)
      stats <- sapply(data$stats, function(stat) stat$base_stat)
      id <- data$id
      sprite <- data$sprites$front_default
      c(id = id, name = data$name, type1 = types[1], type2 = ifelse(length(types) > 1, types[2], NA),
        hp = stats[1], attack = stats[2], defense = stats[3],
        special_attack = stats[4], special_defense = stats[5], speed = stats[6],
        sprite = sprite)
    } else {
      NULL
    }
  })
  
  # Convertir a data frame
  pokemon_df <- do.call(rbind, pokemon_list)
  pokemon_df <- as.data.frame(pokemon_df, stringsAsFactors = FALSE)
  
  # Convertir las columnas numéricas
  num_cols <- c("id", "hp", "attack", "defense", "special_attack", "special_defense", "speed")
  pokemon_df[num_cols] <- lapply(pokemon_df[num_cols], as.numeric)
  
  # Guardar en un archivo CSV
  if (!dir.exists("datos")) dir.create("datos")
  write.csv(pokemon_df, "datos/pokemon_data.csv", row.names = FALSE)
  
  cat("Datos de Pokémon guardados en 'datos/pokemon_data.csv'\n")
  
} else {
  stop("No se pudo obtener la lista de Pokémon.")
}

# Generar datos de ubicaciones ficticias
set.seed(123)
locations_df <- data.frame(
  area = paste0("area-", 1:50),
  lat = runif(50, min = -90, max = 90),
  lon = runif(50, min = -180, max = 180),
  stringsAsFactors = FALSE
)
write.csv(locations_df, "datos/locations.csv", row.names = FALSE)
cat("Datos de ubicaciones guardados en 'datos/locations.csv'\n")

# Asignar Pokémon aleatorios a las áreas
area_pokemon_df <- data.frame(
  area = sample(locations_df$area, 300, replace = TRUE),
  Pokemon = sample(pokemon_df$name, 300, replace = TRUE),
  stringsAsFactors = FALSE
)
write.csv(area_pokemon_df, "datos/area_pokemon.csv", row.names = FALSE)
cat("Datos de Pokémon por área guardados en 'datos/area_pokemon.csv'\n")

