

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

app$delete("/flight_delete/:id", \(req, res){
  id <- as.integer(req$params$id)
  
  query <- "DELETE FROM flightsDT WHERE id = ?"
  stmt <- dbSendQuery(db, query)
  dbBind(stmt, list(id))
  dbClearResult(stmt)  # Clear the result
  
  res$json(list(status = "success", message = "Flight record deleted successfully"))
})

app$start(host = '127.0.0.1', port = PORT)

on.exit(dbDisconnect(con))

