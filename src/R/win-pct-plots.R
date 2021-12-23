# This script makes all 3 plots to use in the report. 

library(magrittr)
library(ggplot2)
theme_set(ecmfuns::theme_ecm_bw())

all_results <- readr::read_rds(file = './data/tidy-win-pcts.rds') 

yearly_win_pcts <- all_results$win_pct_by_year %>% 
  dplyr::rename(year_win_pct = win_pct)

monthly_win_pcts <- all_results$win_pct_by_month %>% 
  dplyr::rename(month_win_pct = win_pct)


month_abbs <- tibble::tibble(
  month = 1:12,
  month_abb = factor(c(
    "Jan.",
    "Feb.",
    "Mar.",
    "Apr.",
    "May",
    "June",
    "July",
    "Aug.",
    "Sept.",
    "Oct.",
    "Nov.",
    "Dec."),
    levels = c(
      "Jan.",
      "Feb.",
      "Mar.",
      "Apr.",
      "May",
      "June",
      "July",
      "Aug.",
      "Sept.",
      "Oct.",
      "Nov.",
      "Dec.")
  ))


# single-letter abbreviations
# month_abbs <- tibble::tibble(
#   month = 1:12,
#   month_abb = factor(c(
#     "J",
#     "F",
#     "M",
#     "A",
#     "M",
#     "J",
#     "J",
#     "A",
#     "S.",
#     "O",
#     "N",
#     "D"),
#     levels =c(
#       "J",
#       "F",
#       "M",
#       "A",
#       "M",
#       "J",
#       "J",
#       "A",
#       "S.",
#       "O",
#       "N",
#       "D")
#   ))

# These plots are misleading because they only show the winning percentage 
# for each month; it's not really a trend. I guess it shows whether they get better 
# or worse as the season progresses, but it's not really time series data in a strict
# sense 


# phils <- all_results %>% 
#   purrr::pluck("win_pct_by_month") %>% 
#   dplyr::filter(team == "PHI",
#                 .data$month >=4, .data$month <=9) %>% 
#   dplyr::mutate(
#     color = dplyr::case_when(
#       year == 2008 ~ 'tomato',
#       year %in% c(2007, 2009:2011) ~ 'darkblue',
#       TRUE ~ 'black')) %>% 
#   dplyr::left_join(month_abbs) %>% 
#   dplyr::mutate(
#     month_date_time = lubridate::mdy(paste(month_abb, 1, year))) 


phils_all_results <- all_results %>% 
  purrr::pluck("cumulative_win_pct") %>% 
  # purrr::pluck("win_pct_by_month") %>% 
  dplyr::filter(team == "PHI",
                .data$month >=4, .data$month <=9,
                !stringr::str_detect(as.character(date), stringr::str_c(paste0("04-"), paste0(0, 1:7, "$"), collapse = "|"))) %>% 
  dplyr::mutate(
    color = dplyr::case_when(
      year %in% c(1980, 2008) ~ 'tomato',
      year %in% c(1983, 1993, 2009) ~ 'goldenrod2',
      year %in% c(2007, 2009:2011) ~ 'darkblue',
      TRUE ~ 'black')) %>% 
  dplyr::left_join(month_abbs) %>% 
  dplyr::mutate(
    month_date_time = lubridate::mdy(paste(month_abb, 1, year))) 


phils_since_1970_daily_plots <- phils_all_results %>% 
  dplyr::filter(year >= 1970) %>% 
  ggplot(aes(date, cumulative_win_pct, color = color))+
  geom_line()+
  scale_color_identity()+
  labs(title = 'Phillies daily win %, 1970-2019')+
  scale_y_continuous("Win %", labels = scales::label_number(accuracy = .001))+
  facet_wrap(~year, scales = 'free_x')+
  theme_minimal()+
  theme(
    axis.text.x = element_text(angle = 35, size = 7),
    axis.title.x = element_blank())

if(interactive()){print(phils_since_1970_daily_plots)}

ggsave(
  plot = phils_since_1970_daily_plots,
  filename = "figures/phils-since-1970-daily-win-pcts.png",
  height = 8.5,
  width = 11)


# now for the win % by month chart rather than the daily chart


phils_by_month_results <- all_results %>% 
  purrr::pluck("win_pct_by_month") %>% 
  dplyr::filter(team == "PHI",
                .data$month >=4, .data$month <=9) %>% 
  dplyr::mutate(
    color = dplyr::case_when(
      year %in% c(1980, 2008) ~ 'tomato',
      year %in% c(1983, 1993, 2009) ~ 'goldenrod2',
      year %in% c(2007, 2009:2011) ~ 'darkblue',
      TRUE ~ 'black')) %>% 
  dplyr::left_join(month_abbs) %>% 
  dplyr::mutate(
    month_date_time = lubridate::mdy(paste(month_abb, 1, year))) 


phils_since_1970_monthly_plots <- phils_by_month_results %>% 
  dplyr::filter(year >= 1970) %>% 
  ggplot(aes(month_date_time, win_pct, color = color))+
  geom_line()+
  scale_color_identity()+
  labs(title = 'Phillies win % averaged by month, 1970-2019')+
  scale_y_continuous("Win %", labels = scales::label_number(accuracy = .001))+
  facet_wrap(~year, scales = 'free_x')+
  theme_minimal()+
  theme(
    axis.text.x = element_text(angle = 35, size = 7),
    axis.title.x = element_blank())

if(interactive()){print(phils_since_1970_monthly_plots)}

ggsave(
  plot = phils_since_1970_monthly_plots,
  filename = "figures/phils-since-1970-monthly-win-pcts.png",
  height = 8.5,
  width = 11)

# phils %>% 
#   dplyr::filter(year >= 2000) %>% 
#   ggplot(aes(month, win_pct))+
#   # geom_line()+
#   geom_col()+ # yuck 
#   facet_wrap(~year)+
#   theme_minimal()



model_data <- monthly_win_pcts %>% 
  dplyr::left_join(yearly_win_pcts) %>% 
  dplyr::filter(month >3, month <10) %>% 
  dplyr::left_join(month_abbs, by = 'month') %>% 
  dplyr::select(-month) %>% 
  dplyr::rename(month = month_abb)


models <- model_data %>% 
  split(~month) %>% 
  purrr::keep(~nrow(.) >0) %>% 
  purrr::map(~lm(data = ., formula = year_win_pct ~ month_win_pct))

r_squared_values <- models %>% 
  purrr::map(broom::glance) %>% 
  purrr::map_dbl("r.squared") %>% 
  tibble::enframe(name = 'month', value = 'r_squared') %>% 
  dplyr::mutate(month = factor(month, levels = c("Apr.", "May", "June", "July", "Aug.", "Sept.")))

monthly_win_pct_plots <- model_data %>% 
  ggplot(aes(month_win_pct, year_win_pct, color = month))+
  geom_point(alpha = 1/10)+
  geom_smooth(formula = y~x, method = lm, se = F, color = 'grey50', size = 0.25)+
  scale_y_continuous("End-of-season win %", breaks = c(0.2, 0.4, 0.6, 0.8), labels = scales::label_percent(accuracy = 1, suffix = ""))+
  expand_limits(y = c(0.2, 0.8))+
  scale_x_continuous("Monthly win %", breaks = c(0.2, 0.4, 0.6, 0.8), labels = scales::label_percent(accuracy = 1, suffix = ""))+
  facet_wrap(~month)+
  theme(strip.background = element_blank(),
        legend.position = 'none')+
  colorblindr::scale_color_OkabeIto()

r_squared_plots <- r_squared_values %>% 
  ggplot(aes(month, r_squared))+
  geom_col(aes(fill = month), alpha = 1/3)+
  scale_color_gradient()+
  scale_y_continuous("Correlation") +
  labs(title = "Correlation between monthly winning % and end-of-year winning %")+
  theme(
    panel.grid = element_blank(),
    axis.title.x = element_blank(),
    legend.position = 'none',
    panel.border = element_blank()
  )


ggsave(plot = monthly_win_pct_plots, 
       filename = "./figures/monthly-win-pct-facets.png",
       height = 6, width = 9)


ggsave(plot = r_squared_plots, 
       filename = "./figures/monthly-r-squared-plots.png",
       height = 6, width = 9)
