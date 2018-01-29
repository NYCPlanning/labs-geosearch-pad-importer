"SEQUENCING" %>% print
# This step creates a new column, `houseNums`, which is either NA or a comma-separated list of value(s). 
# Based on the rowType above, it will delegate a particular row in the iteration to a specific function
# that constructs the comma-sparated list. This list is not a true R list, but a simple character with commas and values. 

# garbage collection
gc()


pad <- pad %>%
  mutate(
    houseNums = apply(
      pad,
      1,
      delegate
    )
  )
