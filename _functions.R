characterMap <- tibble(keys = seq(1, length(LETTERS)), values = LETTERS)

singleAddress <- function(display) {
  return(display)
}

numericType <- function(from, to) {
  return(paste(seq(from, to, 2), collapse=','))
}

hyphenNoSuffix <- function(lNumeric, rNumeric, lhyphenNumeric, rhyphenNumeric) {
    houseNumSeq <- seq(lNumeric, rNumeric, 2);

    # convert numbers to strings for non-hyphenated housenums
    noHyphens <- paste(houseNumSeq)

    # add the hyphen in the original position
    hyphenated <- paste(
      str_sub(houseNumSeq, 1, nchar(parse_character(lhyphenNumeric))),
      '-',
      str_sub(houseNumSeq, nchar(parse_character(lhyphenNumeric)) + 1, -1),
      sep = ""
    );

    combined <- paste(c(hyphenated, noHyphens), collapse=',');
    return(combined);
}

hyphenSuffix <- function(lhnd, hhnd) {
  lowBefore <- str_split(lhnd,'-')[[1]][1];
  lowAfter <- paste(str_extract_all(str_split(lhnd,'-')[[1]][2], '[0-9]')[[1]], collapse="");
  highBefore <- str_split(hhnd,'-')[[1]][1];
  highAfter <-  paste(str_extract_all(str_split(hhnd,'-')[[1]][2], '[0-9]')[[1]], collapse="");
  
  sequence <- seq(
    str_extract_all(lhnd, '[0-9]') %>% unlist %>% paste(collapse="") %>% parse_number,
    str_extract_all(hhnd, '[0-9]') %>% unlist %>% paste(collapse="") %>% parse_number,
    2
  )
  
  noHyphens = paste(sequence);
  
  hyphens <- paste(
    str_sub(sequence, 1, nchar(lowBefore)), 
    '-', 
    str_sub(sequence, -nchar(lowAfter)),
    sep = ""
  );
  
  
  suffices <- LETTERS[
    seq(
      characterMap %>% filter(values == str_extract(lhnd, '[A-Z]') %>% unlist) %>% select(keys) %>% unlist,
      characterMap %>% filter(values == str_extract(hhnd, '[A-Z]') %>% unlist) %>% select(keys) %>% unlist
    )
  ]
  
  noHyphenAndSuffix <- paste(expand.grid(a = noHyphens, b = suffices) %>% unite(c,a,b, sep=""), collapse=',') ;
  hyphenAndSuffix <- paste(expand.grid(a = hyphens, b = suffices) %>% unite(c,a,b, sep=""), collapse = ',');
  
  combined <- paste(c(noHyphenAndSuffix, hyphenAndSuffix), collapse=',')
  
  return(combined)
}

# Sample data with PAD data frame in the environment
# padSample <- pad[sample(nrow(pad), nrow(pad) * 0.1), ]
# # padSample <- padSample %>% filter(rowType == 'hyphenNoSuffix')
# padSample <- padSample %>% select(starts_with('lhns'), starts_with('hhns'), starts_with('lhnd'), starts_with('hhnd'), rowType)
# 
# padSample <- padSample %>%
#   mutate(
#     houseNums = apply(
#       padSample,
#       1,
#       function(x) {
#         if (x['rowType'] == 'nonAddressable') {
#           return(NA)
#         }
# 
#         if (x['rowType'] == 'singleAddress') {
#           return(singleAddress(x['lhnd']))
#         }
# 
#         if (x['rowType'] == 'numericType') {
#           return(numericType(x['lhns_lhyphen_i'], x['hhns_lhyphen_i']))
#         }
# 
#         if (x['rowType'] == 'hyphenNoSuffix') {
#           return(
#             hyphenNoSuffix(
#               x['lhns_numeric'],
#               x['hhns_numeric'],
#               x['lhns_lhyphen_i'],
#               x['lhns_rhyphen_i']
#             )
#           )
#         }
# 
#         if (x['rowType'] == 'hyphenSuffix') {
#           return(hyphenSuffix(x['lhnd'], x['hhnd']))
#         }
# 
#         if(x['rowType'] == 'noHyphenSuffix') {
#           return()
#         }
#       }
#     )
#   )
