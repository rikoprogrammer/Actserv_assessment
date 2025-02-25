

library(ambiorix)
library(jsonlite)
library(data.table)

# Initialize a flights data.table 

flightsDT <- data.table(
  id = integer(),
  carrier = character(),
  origin = character(),
  dest = character(),
  dep_time = character(),
  dep_delay = numeric(),
  indicator = character()
)

# Create an Ambiorix app
app <- ambiorix::Ambiorix$new()

# Define a POST endpoint to add a new flight entry
app$post("/flight", function(req, res) {
  
  # Set response type to JSON
  res$headers("Content-Type", "application/json")
  
  # Parse JSON body from request
  flight_data <- fromJSON(req$body)
  
  # Generate a new flight ID
  new_id <- ifelse(nrow(flightsDT) == 0, 1, max(flightsDT$id) + 1)
  
  # Create a new row as a data.table
  new_flight <- data.table(
    id = new_id,
    carrier = flight_data$carrier,
    origin = flight_data$origin,
    dest = flight_data$dest,
    dep_time = flight_data$dep_time,
    dep_delay = as.numeric(flight_data$dep_delay),
    indicator = flight_data$indicator
  )
  
  # Append the new flight entry to the flights_dt table
  flightsDT <<- rbind(flightsDT, new_flight, fill = TRUE)
  
  # Return a success response
  res$send(list(status = "success", message = "Flight added successfully!",
                flight = new_flight))
})

# Start the server on port 80000
app$start(host = '127.0.0.1', port = 8000L)

