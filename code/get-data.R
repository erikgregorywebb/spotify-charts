library(tidyverse)
library(lubridate)
library(beepr)

# define date range
dates = seq(as.Date("2017-01-01"), as.Date("2020-03-10"), by="days")
urls = sprintf('https://spotifycharts.com/regional/global/daily/%s/download', dates)

# compile data
datalist = list()
for (i in 1:length(dates)) {
  Sys.sleep(2)
  
  # construct url
  url = sprintf('https://spotifycharts.com/regional/global/daily/%s/download', dates[i])
  
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
raw = do.call('rbind', datalist)
write_csv(raw, 'spotify-charts-daily-raw.csv')

# errors: 2017-02-23, 2017-05-30, 2017-05-31, 2017-06-0

# clean
spotify = raw %>%
  rename(Track = `Track Name`, Date = date) %>%
  mutate(DOW = weekdays(Date, abbreviate = F))

write_csv(spotify, 'spotify-charts-daily-all.csv')
