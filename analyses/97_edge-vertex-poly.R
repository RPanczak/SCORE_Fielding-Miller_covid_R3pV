# solution from Michael Sumner 
# https://gist.github.com/mdsumner/b727f1051209897b99321c20989ec346
# https://rpubs.com/cyclemumner/642015

nc <- sf::read_sf(system.file("shape/nc.shp", package="sf"), quiet = TRUE) # %>% mutate(rn = row_number())

library(silicate)
library(dplyr)
library(tmap)

x <- SC(nc)
objects <- sc_object(x) %>% dplyr::select(object_)  ## objects (SF calls these "features")
nobj <- nrow(objects)


## for a given object, what other objects are touching by 1) vertex 2) edge
(ith <- sample(1:nrow(nc), 1))
ith <- 43 ## there's a difference, one extra by vertex share

## objects by edge
u_edge <- dplyr::slice(objects, ith) %>%
  dplyr::inner_join(x$object_link_edge, "object_") %>%
  dplyr::inner_join(sc_edge(x), "edge_") %>%
  dplyr::select(edge_) %>%
  dplyr::inner_join(x$object_link_edge, "edge_") %>%
  dplyr::distinct(object_)

## objects by vertex
u_vertex <-
  dplyr::slice(objects, ith) %>%
  dplyr::inner_join(x$object_link_edge, "object_") %>%
  dplyr::inner_join(sc_edge(x), "edge_") %>%
  tidyr::pivot_longer( cols = c(.vx0, .vx1), names_to = "node", values_to = "vertex_") %>%
  dplyr::inner_join(sc_vertex(x), "vertex_") %>%
  dplyr::select(vertex_) %>%
  dplyr::inner_join(tidyr::pivot_longer(sc_edge(x),  cols = c(.vx0, .vx1), names_to = "node", values_to = "vertex_"), "vertex_" ) %>%
  dplyr::inner_join(x$object_link_edge, "edge_") %>%
  dplyr::distinct(object_)

e_idx <- match(u_edge$object_, objects$object_)
v_idx <- match(u_vertex$object_, objects$object_)

## only look at it if the set of neighbours is different by vertex vs. edge
par(mfrow = c(2, 1), mar = c(rep(0.75, 4)))

plot(nc[e_idx, 1]$geometry, main = "edge share", reset = F)
plot(nc[ith, ]$geometry, add = TRUE, col = "grey")
plot(nc[v_idx, 1]$geometry, main = "vertex share", reset  = F)
plot(nc[ith, ]$geometry, add = TRUE, col = "grey")

print(v_idx)
print(e_idx)

tm_shape(nc) +
  tm_polygons() +
  tm_shape(filter(nc, row_number() %in% v_idx)) +
  tm_polygons(col = "firebrick")

tm_shape(nc) +
  tm_polygons() +
  tm_shape(filter(nc, row_number() %in% e_idx)) +
  tm_polygons(col = "firebrick")
