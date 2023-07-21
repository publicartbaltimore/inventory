## code to prepare `works` dataset goes here
library(dplyr)
# works <- mapbaltimore::public_art

url <- "https://airtable.com/apprU9l3Ca60s60Pa/tblzkmvNZcqFVsRyC/viwuTHuri6z8QJ5wV?blocks=hide"

token <- rairtable::get_airtable_pat(
  default = "PUBLICART_BALTIMORE"
)

works_df <- rairtable::list_records(
  url = url,
  cell_format = "string",
  token = token
)

works_sf <- works_df |>
  janitor::clean_names() |>
  dplyr::filter(!is.na(longitude)) |>
  sf::st_as_sf(
  crs = 4326,
  na.fail = FALSE,
  coords = c("longitude", "latitude")
)

works <-
  works_sf %>%
  janitor::clean_names() |>
  dplyr::select(
    id,
    osm_id,
    title = work_title,
    location = location_name,
    type,
    medium,
    status = current_status,
    year,
    # year_accuracy,
    creation_dedication_date,
    primary_artist,
    primary_artist_gender,
    street_address,
    city,
    state,
    zipcode,
    dimensions,
    program,
    funding = funding_source,
    artist_assistants,
    architect,
    fabricator,
    location_desc = location_description,
    indoor_outdoor_access = indoor_outdoor_accessible,
    subject_person,
    related_property,
    property_ownership,
    agency_or_insitution,
    wikipedia_url,
    geometry
  )

works <-
  works %>%
  mutate(
    work_type = stringr::str_extract(type, ".+(?=,)|(?<!,).+$"),
    work_type = forcats::fct_infreq(work_type),
    work_type = forcats::fct_lump_n(work_type, 6),
    work_type = forcats::fct_na_value_to_level(work_type)
    # work_type = forcats::fct_explicit_na(work_type)
  )

works <- works %>%
  sf::st_transform(2804) %>%
  sf::st_join(
    dplyr::select(mapbaltimore::csas, csa = name)
  ) %>%
  sf::st_join(
    dplyr::select(mapbaltimore::legislative_districts, legislative_district = name)
  ) %>%
  sf::st_join(
    dplyr::select(mapbaltimore::neighborhoods, neighborhood = name)
  ) %>%
  sf::st_join(
    dplyr::select(mapbaltimore::council_districts, council_district = name)
  ) %>%
  dplyr::relocate(
    neighborhood, csa, council_district, legislative_district,
    .before = location_desc
  ) %>%
  sf::st_transform(4326)

readr::write_rds(works, "data/works.rda")

works_df <- sf::st_drop_geometry(works)

readr::write_rds(works_df, "data/works_df.rda")

baltimore_city <- mapbaltimore::baltimore_city %>%
  sf::st_transform(4326)

readr::write_rds(baltimore_city, "data/baltimore_city.rda")

