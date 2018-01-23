characterMap <- tibble(keys = seq(1, length(LETTERS)), values = LETTERS)

singleAddress <- function(display) {
  return(display)
}

numericType <- function(from, to) {
  return(paste(seq(from, to, 2), collapse=','))
}

hyphenNoSuffix <- function(lNumeric, rNumeric, lDashNumeric, rDashNumeric) {
  # handle same length before and after hyphen, and lowbefore == highbefore
  if (lNumeric == rNumeric) {
    # generate numerical sequence
    sequence <- seq(lNumeric, rNumeric, 2);
    
    # convert numbers to strings for non-hyphenated housenums
    noHyphens <- paste(sequence)
    
    # add the hyphen in the original position
    hyphens <- paste(
      str_sub(sequence, 1, nchar(lDashNumeric)), 
      '-', 
      str_sub(sequence, -nchar(rDashNumeric)),
      sep = ""
    );
    
    combined <- paste(c(hyphens, noHyphens), collapse=',');
    return(combined);
  }
  
  return(NA);
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
