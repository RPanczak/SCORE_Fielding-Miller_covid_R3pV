library(sf)
library(tmap)
tmap_mode("view")

nc <- read_sf(system.file("shape/nc.shp", package="sf"))

nc %>% 
  qtm()

sample <- st_sample(nc, 
                    size = round(nrow(nc)*0.05), 
                    type = "random") 
sample %>% 
  qtm()

st_join(nc, st_sf(sample), 
        join = st_intersects, 
        left = FALSE) %>% 
  qtm(borders = "purple", fill = NULL)
