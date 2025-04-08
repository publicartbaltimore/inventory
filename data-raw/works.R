## code to prepare `works` dataset goes here
library(dplyr)
library(sf)
# works <- mapbaltimore::public_art

baltimore_tracts <- tigris::tracts("MD", c("Baltimore city", "Baltimore County"))

baltimore_tracts <- baltimore_tracts |>
  select(
    tract = NAMELSAD,
    tract_geoid = GEOID
  ) |>
  sf::st_transform(3857)

csas <- arcgislayers::arc_read(
  "https://services1.arcgis.com/mVFRs7NF4iFitgbY/arcgis/rest/services/Community_Statistical_Areas_(CSAs)__Reference_Boundaries/FeatureServer/0",
  col_select = c("Community", "CSA2020"),
  col_names = c("csa", "csa_2020")
)

csas <- csas |>
  st_transform(3857) |>
  st_make_valid(
    geos_method = "valid_linework"
  )

legislative_districts <- dplyr::select(mapbaltimore::legislative_districts, legislative_district = name) |>
  sf::st_transform(3857)


neighborhoods <- dplyr::select(mapbaltimore::neighborhoods, neighborhood = name) |>
  sf::st_transform(3857)

council_districts <- dplyr::select(mapbaltimore::council_districts, council_district = name) |>
  sf::st_transform(3857)

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
  sf::st_transform(3857) |>
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

if (FALSE) {
  works |>
    sf::st_join(
      baltimore_tracts
    ) |>
    sf::st_join(
      csas
    ) |>
    dplyr::bind_cols(
      works |>
        sf::st_transform(4326) |>
        sf::st_coordinates() |>
        as.data.frame() |>
        set_names(c("lon", "lat"))
    ) |>
    dplyr::arrange(dplyr::desc(year), title) |>
    sf::st_drop_geometry() |>
    readr::write_csv(
      "Baltimore-Public-Art-Inventory_Works_2025-04-08.csv"
    )
}


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
  sf::st_transform(3857) %>%
  sf::st_join(
    csas
  ) %>%
  sf::st_join(
    legislative_districts
  ) %>%
  sf::st_join(
    neighborhoods
  ) %>%
  sf::st_join(
    council_districts
  ) %>%
  dplyr::relocate(
    neighborhood, starts_with("csa"), council_district, legislative_district,
    .before = location_desc
  ) %>%
  sf::st_transform(4326)

readr::write_rds(works, "data/works.rda")

# works <- readr::read_rds("data/works.rda")

sf::write_sf(works, "files/data/baltimore_public_art.gpkg")

sfext::write_sf_ext(works, path = "files/data/baltimore_public_art.csv")

works_df <- works |>
  dplyr::arrange(dplyr::desc(year), title) |>
  sf::st_drop_geometry()

readr::write_rds(works_df, "data/works_df.rda")

baltimore_city <- mapbaltimore::baltimore_city %>%
  sf::st_transform(4326)

readr::write_rds(baltimore_city, "data/baltimore_city.rda")
