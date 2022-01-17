library(tidyverse)
library(tidycensus)
library(leaflet)
library(leaflet.extras)
library(sf)
library(htmltools)
library(scales)
library(rmapshaper)
library(htmlwidgets)

# get census data and geometry
places <- get_decennial(
  geography = "place",
  variables = "P3_001N",
  year = 2020,
  geometry = TRUE
  ) %>%
  st_transform(4326) %>%  # leaflet needs wgs84
  ms_simplify()           # simplify polygons for faster render

# add popup var
to_map <- places %>%
   mutate(
    url = paste0(
      "https://data.census.gov/cedsci/table?g=1600000US",
      GEOID,
      "&y=2020&d=DEC%20Redistricting%20Data%20%28PL%2094-171%29&tid=DECENNIALPL2020.P3"
    ),
    popup = paste0(
      "<b>", NAME, "</b><br>",
      "GEOID: ", GEOID, "<br>",
      "18+ population: ", comma(value, 1), "<br>",
      "<a href = ", url, " target='_blank'>View Census data</a>"
    ),
    popup = map(popup, HTML)
  )

# make a leaflet map
m <- to_map %>%
  leaflet() %>%
  addPolygons(
    group = "Places",
    weight = 1.5,
    color = "white",
    fillColor = "purple",
    fillOpacity = 0.7,
    label = ~NAME,
    popup = ~popup,
    highlightOptions = highlightOptions(
      weight = 3,
      opacity = 1,
      color = "#666",
      fillOpacity = 0.9,
    )
  ) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addSearchFeatures(
    targetGroups = "Places",
    options = searchFeaturesOptions(
      zoom = 11,
      openPopup = TRUE,
      collapsed = FALSE,
      position = "topright",
      hideMarkerOnCollapse = TRUE,
      textPlaceholder = "Search Census-designated places"
    )
  ) %>%
  setView(
    zoom = 7,
    lat = 40.8,
    lng = -73.9
  )

# save map as an html widget
saveWidget(m, "docs/leaflet-cdp-ex.html", selfcontained = FALSE)
