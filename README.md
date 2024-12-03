# Pokémon Shiny Dashboard

## Descripción del Proyecto
El **Pokémon Shiny Dashboard** es una aplicación interactiva desarrollada en R utilizando el paquete **shiny**. Esta aplicación permite a los usuarios explorar, analizar y comparar estadísticas de Pokémon de manera visual e intuitiva. Con una interfaz amigable y múltiples funcionalidades, los usuarios pueden realizar análisis avanzados, generar gráficos personalizados, comparar Pokémon y explorar datos interactivos.

<div style="text-align: center;">
  <img src="https://cdn.prod.website-files.com/622733c59bf20d8a074764f6/627a7569f1389244d2938298_pokemon-banner.png" alt="Pokémon Shiny" width="500">
</div>

## Características Principales

### Inicio:
- Bienvenida al usuario con una breve descripción del propósito de la aplicación.
- Imagen temática de Pokémon para una experiencia visual atractiva.

### Pokédex:
- Tabla interactiva con todos los Pokémon disponibles.
- Análisis avanzado con gráficos de dispersión basados en estadísticas seleccionadas.

### Gráficos Interactivos:
- Generación de gráficos personalizados para un Pokémon específico.
- Selección de estadísticas para visualizar en gráficos de barras.

### Comparación de Pokémon:
- Comparación lado a lado de dos Pokémon seleccionados.
- Visualización de estadísticas seleccionadas en gráficos comparativos.

### Explorador de Datos:
- Filtros interactivos para explorar datos de Pokémon según tipo, HP y ataque.
- Tabla interactiva con los resultados filtrados.
- Gráfico dinámico basado en las variables seleccionadas.
- Descarga de los datos filtrados en formato CSV.

  <img src="Poke%20Shiny/poke_api/www/demo.png" alt="Pokémon Shiny" width="500">

## Requisitos del Sistema

### Software
- **R** (versión 4.0 o superior)
- **RStudio** (opcional, pero recomendado)

### Paquetes de R
Asegúrate de tener instalados los siguientes paquetes antes de ejecutar la aplicación:

- `shiny`
- `shinydashboard`
- `shinythemes`
- `plotly`
- `DT`
- `shinycssloaders`
- `dplyr` 

Puedes instalarlos ejecutando el siguiente comando en R:

```R
install.packages(c("shiny", "shinydashboard", "shinythemes", "plotly", "DT", "shinycssloaders", "dplyr"))
```

## Estructura del Proyecto

El proyecto está organizado de la siguiente manera:

```bash
poke-shiny/
├── ui.R                # Definición de la interfaz de usuario
├── server.R            # Lógica del servidor
├── datos/              # Carpeta para almacenar el archivo CSV con los datos de Pokémon
│   └── pokemon_data.csv # Archivo con las estadísticas de los Pokémon
├── www/                # Carpeta para recursos estáticos (imágenes, CSS, etc.)
│   └── pokemon_image.jpg # Imagen utilizada en la pestaña de Inicio
└── README.md           # Documentación del proyecto
```

## Cómo Ejecutar la Aplicación

1. Clona el repositorio o descarga los archivos del proyecto:

    ```bash
    git clone https://github.com/Maik3000/PokeShiny.git
    cd Poke Shiny
    ```

2. Asegúrate de que el archivo `pokemon_data.csv` esté en la carpeta `datos/`:

   Este archivo debe contener las estadísticas de los Pokémon, con columnas como `name`, `type1`, `type2`, `hp`, `attack`, `defense`, `special_attack`, `special_defense`, y `speed`.

3. Ejecuta la aplicación en R o RStudio:

    - Abre RStudio y carga el archivo `ui.R` o `server.R`.
    - Ejecuta el siguiente comando en la consola de R:

      ```r
      shiny::runApp()
      ```

4. Accede a la aplicación:

   La aplicación se abrirá automáticamente en tu navegador predeterminado.

## Contribuciones

Si deseas contribuir a este proyecto, sigue estos pasos:

1. Haz un fork del repositorio.
2. Crea una nueva rama para tus cambios:

    ```bash
    git checkout -b feature/nueva-funcionalidad
    ```

3. Realiza tus cambios y haz un commit:

    ```bash
    git commit -m "Agregada nueva funcionalidad"
    ```

4. Envía un pull request para revisión.

## Licencia

Este proyecto está bajo la licencia MIT. Puedes usarlo, modificarlo y distribuirlo libremente, siempre y cuando se incluya la atribución correspondiente.
```

