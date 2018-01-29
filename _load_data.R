"LOADING DATA" %>% print
# Read PAD
padRaw <- read_csv('data/bobaadr.txt',
                   col_types = cols(
                     bin = col_character()
                   ))

# Read BBL data for condos to improve BBL key later
bbl <- read_csv('data/bobabbl.txt') %>%
  select(boro, block, lot, billboro, billblock, billlot)

# Read Street Names Database to join in alternates 
snd <- read_fwf(
  'data/snd17Dcow.txt', 
  fwf_widths(
    c(1, 1, 32, 1, 1, 1, 5, 2, 3, 2, 1, 1, 2, 32, 2, 20, 1, 92),
    col_names = c('rectype', 'boro', 'stname', 'primary_flag', 'principal_flag', 'boro2', 'sc5', 'lgc', 'spv', 'filler2', 'numeric_ind', 'GFT', 'len_full_name', 'full_stname', 'min_SNL', 'stn20', 'ht_name_type_code', 'filler')
  ),
  skip = 1) %>%
  select(boro, sc5, lgc, alt_st_name = stname, full_stname, primary_flag, principal_flag)

# Read BBL centroids data, make them distinct on the BBL key
bblcentroids <- read_csv(
  'data/bblcentroids.csv',
  col_types = cols(
    bbl = col_character()
  )
)  %>%
  distinct(bbl, .keep_all=TRUE)

# Read BIN centroids data, make them distinct on the BIN key
bincentroids <- read_csv(
  'data/bincentroids.csv',
  col_types = cols(
    bin = col_character()
  )
) %>%
  distinct(bin, .keep_all=TRUE) %>%
  filter(!grepl('^[1-5]0{6}$', bin))

# Read suffix lookup table to join on position-separated suffix code
suffix_lookup <- read_csv(
  'suffix_lookup.csv'
)
