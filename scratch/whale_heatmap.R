library(maptools)
library(sf)
library(spatstat)
library(tidyverse)

# Some random whales
set.seed(1001)
whales <- tibble(
  lat = -runif(1000, 50, 70),
  lon = runif(1000, -180, 180)
)

# Make spatially-aware
whales_ll <- st_as_sf(whales, coords = c("lon", "lat"), crs = 4326)

# Project to a SO-friendly coord sys
# https://australianantarcticdivision.github.io/SOmap/
so_crs <- "+proj=stere +lat_0=-76.5139986273002 +lon_0=-36.8427233395983 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
whales_prj <- st_transform(whales_ll, so_crs) 

# Plot
ggplot(whales_prj) + 
  geom_sf()

# Make a heat map
whales_dens <- whales_prj %>% 
  # Convert to point pattern process (PPP)
  as.ppp() %>% 
  # Estimate the denstiy
  density() %>% 
  # Convert to sf
  stars::st_as_stars() %>% 
  st_as_sf() %>% 
  st_set_crs(st_crs(whales_prj))

ggplot(whales_dens) +
  geom_sf(aes(fill = v), col = NA, alpha = 0.95)
