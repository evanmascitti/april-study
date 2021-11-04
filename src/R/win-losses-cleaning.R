# This scipt does some additional data wrangling on the results 
# downloaded by the file `./src/R/win-losses-gathering.R`


suppressPackageStartupMessages({
  library(magrittr)
})



if(!interactive()){
  results_file_path <- commandArgs(trailingOnly = TRUE)[[1]]
  cat("Output file is ", results_file_path, "\n")
}



# read in the entire file of results 

all_res <- readr::read_rds(
  file = './data/all-results.rds'
)

condensed_res <- all_res %>% 
  purrr::map(tibble::as_tibble) %>% 
  purrr::map(~dplyr::mutate(., dplyr::across(.cols = dplyr::everything(), .fns = as.character))) %>% 
  dplyr::bind_rows() %>% 
  dplyr::select(Date, HmTm, VisTm, HmRuns, VisRuns) %>% 
  dplyr::mutate(
    dplyr::across(.cols = dplyr::ends_with("Runs"),
                  .fns = as.integer),
    Date = lubridate::as_date(Date),
    year = lubridate::year(Date),
    month = lubridate::month(Date),
    day = lubridate::day(Date)
  )



win_loss <- function(x){
  
  x %>% 
    dplyr::mutate(
      home_win = HmRuns > VisRuns,
      away_win = !home_win
    )
}

wins <- win_loss(condensed_res) %>% 
  tidyr::pivot_longer(
    cols = c(HmTm, VisTm),
    values_to = 'team',
    names_to = 'home_or_away'
  ) %>% 
  dplyr::mutate(
    home_or_away = dplyr::if_else(
      home_or_away == "HmTm",
      'home',
      'away'
    )
  ) %>% 
  dplyr::select(team, home_or_away, home_win, away_win, dplyr::everything()) %>% 
  dplyr::mutate(
    team_win = (home_or_away == "away" & away_win) | (home_or_away == "home" & home_win)
  )

# test code for the above. It works!! 
# wins[wins$team == "PHI" & wins$year == 2008, ] %>% 
#   dplyr::mutate(
#     team_win = (home_or_away == "away" & away_win) | (home_or_away == "home" & home_win)
#   ) %>% 
#   dplyr::filter(team_win)

# wins[wins$team == "TBA" & wins$year == 2004, ] %>%
#   dplyr::mutate(
#     team_win = (home_or_away == "away" & away_win) | (home_or_away == "home" & home_win)
#   ) %>%
#   dplyr::filter(team_win)


# compute running win percentage for every team in every year


#stop("Time to re-visit the cumulative winning percentages.")

cumulative_win_pct <- wins %>% 
  dplyr::arrange(team, year) %>% 
  dplyr::group_by(team, year) %>% 
  dplyr::mutate(cumulative_wins = cumsum(team_win),
                cumulative_losses = cumsum(!team_win),
                cumulative_win_pct = cumulative_wins / (cumulative_wins + cumulative_losses)) %>% 
  dplyr::ungroup() %>% 
  dplyr::rename(date = Date) %>% 
  dplyr::select(team, year, month, date, cumulative_win_pct)



# compute winning percentage by month for every team in every year 
win_pct_by_month <- wins %>% 
  dplyr::group_by(team, year, month) %>% 
  dplyr::summarize(win_pct = sum(team_win) / dplyr::n(), .groups = 'drop')


# compute winning percentage for the whole season for each team

win_pct_by_year <- wins %>% 
  dplyr::group_by(team, year) %>% 
  dplyr::summarize(win_pct = sum(team_win) / dplyr::n(), .groups = 'drop')


return_list <- list(
  cumulative_win_pct= cumulative_win_pct,
  win_pct_by_month = win_pct_by_month,
  win_pct_by_year = win_pct_by_year
)


# save as rds file
readr::write_rds(x = return_list, file = results_file_path)
