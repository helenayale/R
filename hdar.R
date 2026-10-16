if(!require("hdar")){install.packages("hdar")}
library(hdar)

# devtools::install_github("eea/hdar@develop")

#username <- "your_username"
#password <-"your_password"
#client <- Client$new(username, password)

username <- "your_username"
password <-"your_password"
client <- Client$new(username, password, save_credentials = TRUE)

client <- Client$new()
#client$get_token() 
#client$show_terms()
#client$terms_and_conditions()
#client$terms_and_conditions(term_id = 'all')

all_datasets <- client$datasets()

filtered_datasets <- client$datasets("Seasonal Trajectories")

# To list the dataset IDs from the filtered results:
sapply(filtered_datasets,FUN = function(x){x$dataset_id})

filtered_datasets <- client$datasets("Baltic")

# To list the dataset IDs from the filtered results:
sapply(filtered_datasets, FUN = function(x) { x$dataset_id })

client$datasets("EO:ECMWF:DAT:DERIVED_NEAR_SURFACE_METEOROLOGICAL_VARIABLES")

query <- '{
  "dataset_id": "EO:ECMWF:DAT:CEMS_GLOFAS_HISTORICAL",
  "system_version": [
    "version_4_0"
  ],
  "hydrological_model": [
    "lisflood"
  ],
  "product_type": [
    "consolidated"
  ],
  "variable": [
    "river_discharge_in_the_last_24_hours"
  ],
  "hyear": [
    "2024"
  ],
  "hmonth": [
    "june"
  ],
  "hday": [
    "01"
  ],
  "format": "grib",
  "bbox": [
    11.77115199576009,
    44.56907885098417,
    13.0263737724595,
    45.40384015467251
  ],
  "itemsPerPage": 200,
  "startIndex": 0
}'

