
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

app$get("/airline/delay", \(req, res){
  
  airline <- req$query$airline_name  # Get airline from query string
  
  if (is.null(airline)) {
    query <- "SELECT airline_name, AVG(dep_delay) as avg_delay FROM flightsDT GROUP BY airline_name"
    airline_data <- dbGetQuery(db, query)
    res$json(list(status = "success", data = airline_data))
  } else {
    query <- "SELECT AVG(dep_delay) as avg_delay FROM flightsDT WHERE airline_name = ?"
    stmt <- dbSendQuery(con, query)
    dbBind(stmt, list(airline))
    airline_data <- dbFetch(stmt)
    dbClearResult(stmt)  # Clear the result
    
    if (nrow(airline_data) == 0) {
      res$status(404)$json(list(error = "Airline not found"))
    } else {
      res$json(list(status = "success", airline = airline, avg_delay = airline_data$avg_delay[1]))
    }
  }
})

app$start(host = '127.0.0.1', port = PORT)

on.exit(dbDisconnect(con))