suppressPackageStartupMessages({
  library(magrittr)
  })


# accept command line argument for make

results_file_path <- commandArgs(trailingOnly = TRUE)[[1]]

cat("Gathering data....\n\n")
cat("Results file is ", results_file_path, "\n")

# don't need to run this any more since I am using vectorized operations 
# instead of an implicit loop over the teams. Saving the code should I ever 
# need to do something similar 

# yearly_tm_ids <- function(year){
#   
#   ids <- retrosheet::getTeamIDs(year = year)
#   Sys.sleep(1)
#   return(ids)make 
#   
# }
# 
# tictoc::tic('Retrieve team IDs')
# all_tm_ids <- purrr::map(1900:1998, yearly_tm_ids)
# tictoc::toc()
# 

tictoc::tic("Retrieve season results")
all_res <- purrr::map(.x = 1900:2019, 
                      .f = purrr::possibly(retrosheet::get_retrosheet, otherwise = NA), 
                      type = 'game')
tictoc::toc() 


# write results to disk 


readr::write_rds(
  x = all_res,
  file = results_file_path
)


