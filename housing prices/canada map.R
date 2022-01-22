library(geojsonio)
library(rmapshaper)
library(rgdal)
library(tidyverse)
library(spdplyr)
library(sf)
library(socviz)

theme_map <- function(base_size=9, base_family="") {
  require(grid)
  theme_bw(base_size=base_size, base_family=base_family) %+replace%
    theme(axis.line=element_blank(),
          axis.text=element_blank(),
          axis.ticks=element_blank(),
          axis.title=element_blank(),
          panel.background=element_blank(),
          panel.border=element_blank(),
          panel.grid=element_blank(),
          panel.spacing=unit(0, "lines"),
          plot.background=element_blank(),
          legend.justification = c(0,0),
          legend.position = c(0,0)
    )
}
theme_set(theme_map())


setwd("C:/Users/jeffz/Desktop/data")
canada_raw <- readOGR("C:/Users/jeffz/Desktop/data/gpr_000b11a_e.shp",
                      use_iconv=TRUE, encoding="CP1250")

#convert shp to geojson and simplify
canada_raw_json <- geojson_json(canada_raw)
canada_raw_sim <- ms_simplify(canada_raw_json)

#write json to file
geojson_write(canada_raw_sim, file = "C:/Users/jeffz/Desktop/data/canada_cd_sim.geojson")

#convert json to sf object
canada_cd <- st_read("C:/Users/jeffz/Desktop/data/canada_cd_sim.geojson", quiet = TRUE)

canada_cd

crs_string = "+proj=lcc +lat_1=49 +lat_2=77 +lon_0=-91.52 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs" # 2

# Define the maps' theme -- remove axes, ticks, borders, legends, etc.
theme_map <- function(base_size=9, base_family="") { # 3
  require(grid)
  theme_bw(base_size=base_size, base_family=base_family) %+replace%
    theme(axis.line=element_blank(),
          axis.text=element_blank(),
          axis.ticks=element_blank(),
          axis.title=element_blank(),
          panel.background=element_blank(),
          panel.border=element_blank(),
          panel.grid=element_blank(),
          panel.spacing=unit(0, "lines"),
          plot.background=element_blank(),
          legend.justification = c(0,0),
          legend.position = c(0,0)
    )
}
# Define the filling colors for each province; max allowed is 9 but good enough for the 13 provinces + territories
map_colors <- RColorBrewer::brewer.pal(9, "Pastel1") %>% rep(37) # 4

canada_cd$PRNAME<-as.factor(canada_cd$PRNAME)

# Plot the maps
map<-ggplot() +
  geom_sf(aes(fill = PRNAME), size = 0.1, data = canada_cd) + # 5
  coord_sf(crs = crs_string) + # 6
  scale_fill_manual(values = c(rep("grey",1),"red",
                               rep("grey",4),"green",
                               rep("grey",1),"blue",
                               rep("grey",4)
                               )) +
  guides(fill = FALSE) +
  theme_map() +
  theme(panel.grid.major = element_line(color = "white"),
        legend.key = element_rect(color = "gray40", size = 0.1))
map

