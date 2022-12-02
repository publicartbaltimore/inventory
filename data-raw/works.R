## code to prepare `works` dataset goes here
library(dplyr)
# works <- mapbaltimore::public_art

works <-
  getdata::get_location_data(
    data = here::here("files/data", "2022-12-02_works-public.csv"),
    from_crs = 4326,
    clean_names = TRUE
  )

works <-
  works %>%
  dplyr::select(
    id,
    osm_id,
    title = title_of_artwork,
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
    wikipedia_url
  )

works <-
  works %>%
  mutate(
    work_type = stringr::str_extract(type, ".+(?=,)|(?<!,).+$"),
    work_type = forcats::fct_infreq(work_type),
    work_type = forcats::fct_lump_n(work_type, 6),
    work_type = forcats::fct_explicit_na(work_type)
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

baltimore_city <- mapbaltimore::baltimore_city %>%
  sf::st_transform(4326)

readr::write_rds(baltimore_city, "data/baltimore_city.rda")

