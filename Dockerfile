# Use an official R runtime as a parent image
FROM r-base:latest

# Install necessary system libraries
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev

# Install R packages required for your Shiny app
RUN R -e "install.packages(c('shiny', 'dplyr', 'DT', 'shinydashboard', 'ggplot2', 'leaflet'), repos='http://cran.rstudio.com/')"

# Create a directory for your app
RUN mkdir /app

# Copy your R script and dataset to the app directory
COPY app.R /app/
COPY EvData1.csv /app/

# Set the working directory to the app directory
WORKDIR /app

# Expose the port your Shiny app will run on (default is 3838)
EXPOSE 3838

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/app/app.R', host = '0.0.0.0', port = 3838)"]
