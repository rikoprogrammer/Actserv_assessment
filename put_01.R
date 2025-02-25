
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

app$put("/flight/:id", \(req, res){
  
  id <- as.integer(req$params$id)
  flight_details <- fromJSON(req$body)
  
  query <- "UPDATE flightsDT SET airline_name = ?, dest = ?, dep_time = ?, dep_delay = ? WHERE id = ?"
  stmt <- dbSendQuery(db, query)
  dbBind(stmt, list(flight_details$airline_name, flight_details$dest, flight_details$dep_time, flight_details$dep_delay, id))
  dbClearResult(stmt)  # Clear the result
  
  res$json(list(status = "success", message = "Flight details updated successfully"))
})

app$start(host = '127.0.0.1', port = PORT)

on.exit(dbDisconnect(con))
