library(tidyverse)
library(lubridate)
library(beepr)

# define date range
dates = seq(as.Date("2017-01-01"), as.Date("2020-07-23"), by="days")
urls = sprintf('https://spotifycharts.com/regional/global/daily/%s/download', dates)

# compile data
datalist = list()
for (i in 1:length(dates)) {
  Sys.sleep(.5)
  
  # construct url
  url = sprintf('https://spotifycharts.com/regional/global/daily/%s/download', dates[i])
  print(url)
  
  # download file
  tryCatch({
    download.file(urls[i], 'temp.csv', quiet = T)
    temp = read_csv('temp.csv', skip = 1)
    temp = temp %>% mutate(date = dates[i])
    datalist[[i]] = temp},
    error = function(error_condition) {
      beep(sound = 2) 
    })
}
raw = bind_rows(datalist)
glimpse(raw)
write_csv(raw, 'spotify-charts-daily-raw.csv')


# clean
spotify = raw %>%
  select(-`<html>`) %>%
  rename(Track = `Track Name`, Date = date)

write_csv(spotify, 'spotify-charts-daily-all-clean.csv')
