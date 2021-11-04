# This script works well; I appreciate the package design
# which incorporates automatic pauses to prevent the query
# from crashing.

# One drawback is that ther appears not to be a way to limit 
# the query...so you have to pull every observation. I would really
# prefer to customize the query and get only the data I want,
# but if this is the only way then so be it I guess. 

# I could write a wrapper that takes a year as an argument 
# and then gets all the data for that year and saves it as a 
# csv file....then write a loop to repeat that function over 
# a list of years. 

# Eventually then I would need to put this in a database because 
# just one year is several hundred megabytes. 

from baseball_scraper import statcast

data = statcast(start_dt='2018-03-01', end_dt='2018-12-01')

data.to_csv('test-data-2018.csv', index=False)
