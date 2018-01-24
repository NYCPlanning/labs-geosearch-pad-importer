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

    combined <- paste(c(hyphenated, noHyphens), collapse=',')
    return(combined);
}

hyphenSuffix <- function(lowNumeric, highNumeric, lowSuffix, highSuffix, lhyphenNumeric) {
  houseNumSeq <- seq(lowNumeric, highNumeric, 2);
  
  noHyphens = paste(houseNumSeq);
  
  # add the hyphen in the original position
  hyphenated <- paste(
    str_sub(houseNumSeq, 1, nchar(parse_character(lhyphenNumeric))),
    '-',
    str_sub(houseNumSeq, nchar(parse_character(lhyphenNumeric)) + 1, -1),
    sep = ""
  );
  
  suffices <- LETTERS[
    seq(
      characterMap %>% filter(values == lowSuffix %>% unlist) %>% select(keys) %>% unlist,
      characterMap %>% filter(values == highSuffix %>% unlist) %>% select(keys) %>% unlist
    )
  ]
  
  noHyphenAndSuffix <- paste(expand.grid(a = noHyphens, b = suffices) %>% unite(c,a,b, sep=""), collapse=',')
  hyphenAndSuffix <- paste(expand.grid(a = hyphenated, b = suffices) %>% unite(c,a,b, sep=""), collapse = ',')
  
  combined <- paste(c(noHyphenAndSuffix, hyphenAndSuffix), collapse=',')
  
  return(combined)
}

noHyphenSuffix <- function(from, to, lowSuffix, highSuffix) {
  houseNumbers <- paste(seq(from, to, 2), collapse=',')
  
  suffices <- LETTERS[
    seq(
      characterMap %>% filter(values == lowSuffix %>% unlist) %>% select(keys) %>% unlist,
      characterMap %>% filter(values == highSuffix %>% unlist) %>% select(keys) %>% unlist
    )
  ]
  
  productOfSequences <- paste(expand.grid(a = houseNumbers, b = suffices) %>% unite(c,a,b, sep=""), collapse=',')
  return(productOfSequences)
}

# Sample data with PAD data frame in the environment
# padSample <- pad[sample(nrow(pad), nrow(pad) * 1), ]
# # padSample <- padSample %>% filter(rowType == 'hyphenSuffix')
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
#           return(
#             hyphenSuffix(
#               x['lhns_numeric'],
#               x['hhns_numeric'],
#               x['lhns_suffix'],
#               x['hhns_suffix'],
#               x['lhns_lhyphen_i']
#             )
#           )
#         }
# 
#         if(x['rowType'] == 'noHyphenSuffix') {
#           return(
#             noHyphenSuffix(
#               x['lhns_numeric'],
#               x['hhns_numeric'],
#               x['lhns_suffix'],
#               x['hhns_suffix']
#             )
#           )
#         }
#       }
#     )
#   )
