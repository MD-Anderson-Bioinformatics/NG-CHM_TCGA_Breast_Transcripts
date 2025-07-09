library(NGCHM)
library(jsonlite)

##
## R script to create NG-CHM from data downloaded from `get_data.sh`
##

## read in the map configuration file. This contains the SHA IDs and other map information.
map_config <- jsonlite::fromJSON("48a854d220343348b732e30061aa9a00d2e2ba28/chm.json")

map_name <- "TCGA_Breast_Transcripts"

# Iterate over map data layers, read in the matrix data, and create a new data layer for each.
chm_layers <- list()
for (i in 1:nrow(map_config$layers)) {
  layer_shaid <- map_config$layers[i, "data"][["value"]]
  layer_name <- map_config$layers[i, "name"]
  matrix_data_file <- file.path("data_layers", layer_shaid, "matrix.tsv")
  message(paste("Processing layer:", layer_name, ", from file:", matrix_data_file))
  matrix_data <- as.matrix(read.csv(matrix_data_file, sep="\t", header = TRUE,
                                    row.names = 1, check.names = FALSE, stringsAsFactors = FALSE))
  colors <- map_config$renderers["points"][[1]][[i]]$color
  breakpoints <- map_config$renderers["points"][[1]][[i]]$value
  color_map <- chmNewColorMap(breakpoints, colors=colors)
  chm_layers[[i]] <- chmNewDataLayer(layer_name, matrix_data, color_map)
}

## Create a new NG-CHM object with the name and the data layers.
hm <- chmNew(map_name, chm_layers[[1]], chm_layers[[2]], chm_layers[[3]])

##
## Add covariate bars for rows and columns
##
for (row_or_col in c("row", "col")) {
  covariate_metadata <- map_config[[paste0(row_or_col, "_data")]]$covariates # <-- a data.frame
  for (i in 1:nrow(covariate_metadata)) {
    covariate_shaid <- covariate_metadata[i, "data"]["value"][1,1]
    data_file <- file.path(paste0(row_or_col, "_covariates"), covariate_shaid, "matrix.tsv")
    covariate_data <- read.csv(data_file, sep = "\t", row.names = 1, check.names = FALSE, stringsAsFactors = FALSE) # read.csv returns a data.frame
    covariate_vector <- covariate_data[[1]]
    names(covariate_vector) <- rownames(covariate_data)
    covariate_name <- covariate_metadata[i, "label"]
    covariate <- chmNewCovariate(covariate_name, covariate_vector)
    visible_or_hidden <- covariate_metadata[i, "display"]
    thickness <- covariate_metadata[i, "thickness"]
    covariateBar <- chmNewCovariateBar(covariate, display = visible_or_hidden, thickness = thickness)
    message(paste("Adding covariate bar:", covariate_name, "for", row_or_col))
    hm <- chmAddCovariateBar(hm, row_or_col, covariateBar)
  }
}


#
# Add axis types.
#
axis_type <- map_config$axisTypes[1, "type"]
hm <- chmAddAxisType(hm, "column", axis_type)
axis_type <- map_config$axisTypes[2, "type"]
hm <- chmAddAxisType(hm, "row", axis_type)

##
## Save as HTML
##
message("Saving NG-CHM to HTML file")
chmExportToHTML(hm, paste0(map_name, ".html"), overwrite = TRUE)
message(paste("Saved NG-CHM to", paste0(map_name, ".html")))
