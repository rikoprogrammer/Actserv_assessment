

# Load necessary libraries
library(ambiorix)
library(DBI)
library(RSQLite)
library(jsonlite)

PORT = 8000L

# Connect to the SQLite database
db_path <- "Data/nycflights.db"  
con <- dbConnect(RSQLite::SQLite(), db_path)


# Create an Ambiorix app
app <- ambiorix::Ambiorix$new(port = PORT)


# GET endpoint to returns whether the flight is classified as 'delayed'

app$get("/delayed/:id", \(req, res){
  id <- as.integer(req$params$id)  # Ensure it's an integer
  
  query <- "SELECT indicator FROM flightsDT WHERE id = ?"
  stmt <- dbSendQuery(con, query)
  dbBind(stmt, list(id))
  flight_data <- dbFetch(stmt)
  dbClearResult(stmt)  # Clear the result
  
  if (nrow(flight_data) == 0) {
    res$json(list(message = "Flight not found"))
  } else {
    
    indicator = flight_data$indicator
    res$json(list(status = "success", delayed = indicator))
  }
})

app$start(host = '127.0.0.1', port = PORT)

on.exit(dbDisconnect(con))
