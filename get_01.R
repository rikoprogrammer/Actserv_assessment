
# GET/flight/:id
#
#  - Returns details of the flight specified by that id
  
#############################################

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


# GET endpoint to return flight details by ID
app$get("/flight/:id", \(req, res) {
  
  id <- as.integer(req$params$id)
  
  # Ensure database is connected/error handing
  
  if (!dbIsValid(con)) {
    res$status(500)$json(list(status = "error", message = "Database connection error"))
    return()
  }
  
  # Query the database to retrieve flight details
  query <- "SELECT *
            FROM flightsDT WHERE id = ?"
  
  stmt <- dbSendQuery(con, query)
  dbBind(stmt, list(id))
  flight_details <- dbFetch(stmt)
  dbClearResult(stmt) 
  
  if (nrow(flight_details) == 0) {
    res$json(list(message = "Flight not found"))
  } else {
    res$json(list(status = "success", data = flight_details))
  }
  
})

# Start the server on port 8000
app$start(host = '127.0.0.1', port = PORT)

on.exit(dbDisconnect(con))
