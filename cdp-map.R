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
  state = c("ME", "MA", "NH", "VT", "CT", "RI"),
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

m <- leaflet(places) %>%
  addPolygons(
    group = "Places",
    weight = 1.5,
    color = "white",
    fillColor = "purple",
    fillOpacity = 0.7,
    label = ~label,
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
  )

saveWidget(m, "docs/leaflet-cdp-ex.html", selfcontained = FALSE)
