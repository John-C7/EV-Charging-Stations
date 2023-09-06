# Load necessary libraries
library(shiny)
library(dplyr)
library(DT)
library(shinydashboard)
library(ggplot2)
library(leaflet)

# Load the dataset
charging_stations <- read.csv("EvData1.csv", stringsAsFactors = FALSE)

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "EV Charging Stations in India"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data", tabName = "data"),
      menuItem("Analysis", tabName = "analysis"),
      menuItem("Map", tabName = "map")
    )
  ),
  dashboardBody(
    tabItems(
      # Data tab
      tabItem(
        tabName = "data",
        fluidPage(
          titlePanel("Electric Vehicle Charging Stations in India"),
          sidebarLayout(
            sidebarPanel(
              # Create a selector for the state
              selectInput("state", "Select a State:", unique(charging_stations$state)),
              # Create a selector for the city
              selectInput("city", "Select a City:", NULL)
            ),
            mainPanel(
              # Display charging station details with pagination
              dataTableOutput("charging_station_table")
            )
          )
        )
      ),
      # Analysis tab
      tabItem(
        tabName = "analysis",
        fluidPage(
          titlePanel("Charging Stations Analysis"),
          mainPanel(
            # Display interactive bar chart
            plotOutput("top_states_chart")
          )
        )
      ),
      # Map tab
      tabItem(
        tabName = "map",
        fluidPage(
          titlePanel("EV Charging Stations Map"),
          sidebarLayout(
            sidebarPanel(
              # Create a selector for the city on the map
              selectInput("map_city", "Select a City:", unique(charging_stations$city))
            ),
            mainPanel(
              # Create a leaflet map
              leafletOutput("charging_station_map")
            )
          )
        )
      )
      
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Update the city selector based on the selected state
  observe({
    cities <- unique(charging_stations$city[charging_stations$state == input$state])
    updateSelectInput(session, "city", choices = cities)
  })
  
  # Filter the dataset based on the selected state and city
  filtered_data <- reactive({
    charging_stations %>%
      filter(state == input$state, city == input$city)
  })
  
  # Render the table with pagination
  output$charging_station_table <- renderDataTable({
    datatable(
      filtered_data(),
      options = list(
        pageLength = 5,  # Set the number of rows per page
        lengthMenu = c(5, 10, 25, 50),  # Customize the length menu options
        searching = FALSE  # Disable search bar
      )
    )
  })
  
  # Analysis tab: Create a bar chart of top 10 states
  output$top_states_chart <- renderPlot({
    top_states <- charging_stations %>%
      group_by(state) %>%
      summarize(Count = n()) %>%
      arrange(desc(Count)) %>%
      head(10)
    
    ggplot(top_states, aes(x = reorder(state, -Count), y = Count)) +
      geom_bar(stat = "identity", fill = "blue") +
      labs(x = "State", y = "Number of Charging Stations") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Create a leaflet map
  output$charging_station_map <- renderLeaflet({
    # Get the selected city from the map tab
    selected_city <- input$map_city
    
    # Filter the charging stations for the selected city
    filtered_stations <- charging_stations %>%
      filter(city == selected_city)
    
    # Convert latitude to numeric
    filtered_stations$lattitude <- as.numeric(filtered_stations$lattitude)
    
    # Create a leaflet map with filtered charging stations
    m <- leaflet() %>%
      addTiles() %>%
      setView(lng = 78.9629, lat = 20.5937, zoom = 5)  # Set the initial map view
    
    # Add markers for charging stations
    m <- m %>%
      addMarkers(data = filtered_stations, lng = ~longitude, lat = ~lattitude, popup = ~name)
    
    return(m)
  })
  
  
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)



