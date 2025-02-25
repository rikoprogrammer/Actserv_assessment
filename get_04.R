
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

app$get("/top-destinations", \(req, res){
  
  n <- as.integer(req$query$n)
  if (is.na(n) || n <= 0) {
    n <- 10  # Default to top 10 destinations
  }
  
  query <- "SELECT dest, COUNT(*) as flight_count FROM flightsDT GROUP BY dest ORDER BY flight_count DESC LIMIT ?"
  stmt <- dbSendQuery(con, query)
  dbBind(stmt, list(n))
  destination_data <- dbFetch(stmt)
  dbClearResult(stmt)  # Clear the result
  
  res$json(list(status = "success", top_destinations = destination_data))
})

app$start(host = '127.0.0.1', port = PORT)

on.exit(dbDisconnect(con))