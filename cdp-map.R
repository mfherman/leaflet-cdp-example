library(tidyverse)
library(tidycensus)
library(leaflet)
library(leaflet.extras)
library(sf)
library(htmltools)
library(scales)
library(rmapshaper)
library(htmlwidgets)

places <- get_decennial(
  geography = "place",
  variables = "P3_001N",
  year = 2020,
  geometry = TRUE
  ) %>%
  st_transform(4326) %>%
  ms_simplify() %>%
  mutate(
    label = paste0(
      "<b>", NAME, "</b><br>",
      "GEOID: ", GEOID, "<br>",
      "18+ population: ", comma(value, 1)
    ),
    label = map(label, HTML)
  )

m <- places %>%
  leaflet() %>%
  addPolygons(
    group = "Places",
    weight = 1.5,
    color = "white",
    fillColor = "purple",
    fillOpacity = 0.7,
    label = ~NAME,
    popup = ~label,
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

saveWidget(m, "docs/leaflet-cdp-ex.html", selfcontained = FALSE)
