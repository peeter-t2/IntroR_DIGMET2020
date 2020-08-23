# To recap, we now know

#' - %>% - move data into the next process
#' - filter() - filter data by some criteria
#' - select() - pick certain columns of the dataset
#' - unique() - keep only unique rows
#' - arrange() - sort the data by some parameter
#' - arrange(desc()) - sort the data by some parameter in descending order


# It is often the case that the information we want to use is not exactly present in the dataset, but needs to be created.

#' For this we have the following commands
#' mutate() - make a new column with some function

# The colum that we create can be very simple. For example, we can make a column "ourdata". This may be useful if we want to combine it with some other data.

gapminder %>% 
  mutate(set="ourdata")

# Or simply 1
gapminder %>% 
  mutate(set=1)

# We can also use other columns to calculate these values. For example, we have population pop and gdp per capita gdpPercap. If we multiply them, we get the full gdp.
gapminder %>% 
  mutate(gdp=gdpPercap*pop)

# We can now sort the table by gpd
gapminder %>% 
  mutate(gdp=gdpPercap*pop) %>% 
  arrange(desc(gdp))

# The leader position does not belong to Kuwait in 1952 by this metric.

# We can use this like we used other metrics before, and make a top 10 countries by their top gdp.
gapminder %>% 
  mutate(gdp=gdpPercap*pop) %>% 
  arrange(desc(gdp)) %>% 
  select(country,continent) %>% 
  unique()


# mutate() needs to take variables that are either with a length of 1 or with the length of a dataset.
# Thus we can also give each row a number.
gapminder %>% 
  mutate(sequencepos=1:1704)


# Given that we know that there are 142 countries in the set, with 12 years each, we can also give the observations numbers 1:12 for each country by using a special function for repetitions rep().
gapminder %>% 
  select(country) %>% 
  unique()

gapminder %>% 
  mutate(sequencecountry=rep(1:12,142))

# Generally we might not know the exact contents of the dataset, and for this, more flexible functions are made.

# A generally useful function for the datasets is group_by(). With this function, we can do operations on the dataset in groups. 

# For example we can group the dataset by country.
gapminder %>% 
  group_by(country)

# And give each year a row number within a country.
gapminder %>% 
  group_by(country) %>% 
  mutate(sequencecountry=row_number())


# There are a number of useful functions that can be applied here. 
# We can use max() for maximum value, min() for minimum value, row_number() for row number, mean() for mean() value, sd() for standard deviation etc, first() for first value, last() for last value, n() for a count of how many, log() for the value in logarithmic scale.
gapminder %>% 
  group_by(country) %>% 
  mutate(sequencecountry=row_number())


# For example, if we want to add a column for a population at the first year in the dataset. For this, we place the name of the variable we want to use inside the function.
gapminder %>% 
  group_by(country) %>% 
  mutate(firstpop=first(pop))

#If we do not have the grouping variable, it will pick the first population total for the entire dataset. 
gapminder %>% 
  mutate(firstpop=first(pop))


# We can use this to look at the maximum life expectancy at any point.
gapminder %>% 
  group_by(country) %>% 
  mutate(maxlife=max(lifeExp))


# And we can then use the filter to find the exact years when this was the case.
gapminder %>% 
  group_by(country) %>% 
  mutate(maxlife=max(lifeExp)) %>% 
  filter(lifeExp==maxlife)

# It is interesting to know, if there is a country, where it is not the year 2007
see <-gapminder %>% 
  group_by(country) %>% 
  mutate(maxlife=max(lifeExp)) %>% 
  filter(lifeExp==maxlife) %>% 
  filter(year<2007)
# In fact it seems there are a number of countries, mostly in Africa, where the life expectancy has not been increasing in the 2000s



# Ok, we have seen mutate() and we have seen group_by(). A third relevant command for computing new values from the dataset is summarise(). summarise() is essentially mutate(), however it will only leave the summary values and grouping factors.

# For example, we can summarise to find the top population value.
gapminder %>% 
  summarise(pop=max(pop))
# It returns just that value. If we want the maximal value by population, we group by country.

# And we get a maximal population value there.
gapminder %>% 
  group_by(country) %>% 
  summarise(pop=max(pop))


# This can be combined with other calculations.
gapminder %>% 
  summarise(maxgdp = max(pop * gdpPercap))

gapminder %>% 
  mutate(gdp = pop * gdpPercap) %>% 
  summarise(maxgdp = max(gdp))


# And it is also possible to create multiple value columns at the same time.

gapminder %>% 
  summarise(maxpop=max(pop), maxgdppercap=max(gdpPercap), maxgdp = max(pop * gdpPercap))



# group_by also impacts how filters work. Filters in a way allow for simple calculations to be done within them.
# We can get the minimum gdp per capita per country like this quite easily.
gapminder %>% 
  group_by(country) %>% 
  filter(gdpPercap==min(gdpPercap))


# Another way that this can be accomplished can be through sorting
gapminder %>% 
  arrange(gdpPercap) %>% 
  group_by(country) %>% 
  filter(row_number()==1) %>% 
  arrange(country)


# It is generally a good idea to remove the grouping condition once it is no longer needed. It sometimes can interfere with commands from other packages and bring unexpected results. This can be done by adding ungroup() at the end.
gapminder %>% 
  arrange(gdpPercap) %>% 
  group_by(country) %>% 
  filter(row_number()==1) %>% 
  arrange(country) %>% 
  ungroup()
# You can see that the grouping variable is no longer there
# No more: "Groups:   country [142]"


# Try it yourself!
# mutate() - create a new variable
# group_by() - group by a variable
# summarise() - create a summary variable, drop the other data.

# 1. Make a new variable row number.

# 2. Pick a year, group the dataset by continent, sort it by life expectancy, and create a new variable: the relative position of a country within the continent.

# 3. Find the top 3 countries within each continent.

# 4. Find the maximal gdp per continent.

# 5. Find the countries, where the maximal gdp per capita is more than 9 times bigger than minimal gdp per capita recorded




# Summary tables

# The summarise() function combined with group_by() is quite good for making summary tables. For example, we can retrieve the maximal gdp per continent or per country.
gapminder %>% 
  mutate(gdp = pop * gdpPercap) %>% 
  group_by(continent) %>% 
  summarise(max_gdp = max(gdp))

gapminder %>% 
  group_by(country) %>% 
  summarise(max_gdpPercap = max(gdpPercap)) %>% 
  arrange(desc(max_gdpPercap))

# Note that, a similar result can be found with a filter
gapminder %>% 
  group_by(country) %>% 
  filter(gdpPercap==max(gdpPercap))


# We can also use this in later processing. For example we can sort by that category then

gapminder %>% 
  group_by(country) %>% 
  mutate(max_gdpPercap=max(gdpPercap)) %>% 
  filter(gdpPercap == max_gdpPercap) %>% 
  select(country,continent,year,gdpPercap) %>% 
  arrange(desc(gdpPercap))


# We can find the countries where the last year was not the richest year through this
gapminder %>% 
  group_by(country) %>% 
  mutate(max_gdpPercap=max(gdpPercap),max_year=max(year)) %>% 
  filter(gdpPercap == max_gdpPercap) %>% 
  filter(!year==max_year) %>% 
  select(country,continent,year,gdpPercap) %>% 
  arrange(year)


# These calculations can be made also within the filter() command.
gapminder %>% 
  group_by(country) %>% 
  filter(gdpPercap == max(gdpPercap), !year == max(year)) %>% 
  select(country,continent,year,gdpPercap) %>% 
  arrange(year)


# We can use summarise to calculate mean values
gapminder %>% 
  group_by(continent) %>% 
  summarise(mean_gdpPercap = mean(gdpPercap)) 

gapminder %>% 
  group_by(continent,year) %>% 
  summarise(mean_gdpPercap = mean(gdpPercap))


# We can also calculate other values at the same time, giving us a nice overview table
gapminder %>% 
  group_by(continent) %>% 
  summarise(mean_gdpPercap = mean(gdpPercap),sd_gdpPercap = sd(gdpPercap), median_gdpPercap=median(gdpPercap),min_gdpPercap = min(gdpPercap),max_gdpPercap = max(gdpPercap)) 


# We can use these values to determine the ranks of the countires on some parameters. rank() is a shorter version for this, that could be expressed longer as a sequence of arrange() and mutate(rank=row_number()).
gapminder %>% 
  group_by(continent) %>% 
  summarise(mean_gdpPercap = mean(gdpPercap),sd_gdpPercap = sd(gdpPercap), median_gdpPercap=median(gdpPercap),min_gdpPercap = min(gdpPercap),max_gdpPercap = max(gdpPercap)) %>% 
  mutate(rank=rank(-mean_gdpPercap))


# Keep in mind that if we filter the dataset without groups, then any function will work on the entire dataset. For example row_number()<10 takes the first 10 rows from the dataset. Using mean() as a basis of the filter, the table will use all observations at the same time (table mean is 29.6 millions). If we now try to filter on this, we get 0 rows, if we test for lower than, then we get all rows.

gapminder %>% 
  filter(row_number()<10)

gapminder %>% 
  filter(mean(pop)>30000000)

gapminder %>% 
  filter(mean(pop)<30000000)


#' But we can do the same after grouping the dataset, and get first 5 rows per country row_number()<5 or all the information on the countries where the mean population is above 30 million, mean(pop)>30000000. sample_n() will give us that number of observations from each group.

# 4 first years for each country
gapminder %>% 
  group_by(country) %>% 
  filter(row_number()<5)

# Countries where the mean population is above 30 million
gapminder %>% 
  group_by(country) %>% 
  filter(mean(pop)>30000000)

# Countries where the maximal population is above 100 million
gapminder %>% 
  group_by(country) %>% 
  filter(max(pop)>100000000)

# 5 random countries from each continent
gapminder %>% 
  group_by(continent) %>% 
  sample_n(5)


# Summary values can be collected with the command summary(), but R also has a number of handy packages to explore the dataset. Here, we will use the command skim() from the *skimr* package. Let's first activate the packate. (Also look up the package summarytools for summary information.)

library(skimr)

# Skimr gives an easy overview of the data. It shows the means, quartiles and histograms of the data.
skim(gapminder)

# Or for a clearer view
gapminder %>% 
  select(year,lifeExp) %>% 
  skim()

# However this is not very informative, since years and countries can vary quite a bit. skim() can use the groups given in the dataframe and give more precise details. Let's group the dataset by year.

# Now we see the life expectancy by year. Here we can see an increase in the top countries, while the minimum values see less growth. 50th percentile of 2007 is almost as high as the maximal value in 1952.
gapminder %>% 
  select(year,lifeExp) %>% 
  group_by(year) %>% 
  skim()


# We can also look at other variables through other grouping factors. We can look at for example the distribution of wealth within continents at some points in time.
gapminder %>% 
  filter(year==1977) %>% 
  select(continent,gdpPercap) %>% 
  group_by(continent) %>% 
  skim()



# There is also a way to nest the grouped data. This can be used to perform grouped calculations, but we will not look at those here.
gapminder %>% 
  group_by(country) %>% 
  nest()

# To show one application, nesting allows sample_n() to select a random country from the entire set.

# While sample_n() by groups will pick one date per country.
gapminder %>%
  group_by(country) %>% 
  sample_n(1)

# A nested table will allow us to pick all the data associated with a random value. (Here, it is important to ungroup before using the sample_n() command).
gapminder %>%
  group_by(country) %>% 
  nest() %>% 
  ungroup() %>% 
  sample_n(1)

# We can here thus look at the basic detail of one country
gapminder %>% 
  group_by(country) %>%
  nest() %>% 
  ungroup() %>% 
  sample_n(1) %>% 
  unnest() %>% 
  skim()


# As with most things in R, there are many ways to do anything. A random country can be selected also by sampling a random datapoint, picking the variable country and then filtering on that value.
selected <- gapminder %>% 
  sample_n(1) %>% 
  pull(country)

gapminder %>% 
  filter(country==selected) %>% 
  skim()


# As a combination of basic commands it is now possible to get quite diverse information out of a dataframe.

# To recap
#' - %>% - move data into the next process
#' - filter() - filter data by some criteria
#' - select() - pick certain columns of the dataset
#' - unique() - keep only unique rows
#' - arrange() - sort the data by some parameter
#' - arrange(desc()) - sort the data by some parameter in descending order
#' - mutate() - create a new variable
#' - group_by() - group by a variable
#' - ungroup() - remove grouping
#' - summarise() - create a summary variable, drop the other data.
#' - sample_n() - take a random row
#' - skimr::skim() - get a table overview
#' - min(), max(), mean(), sd(), median(), log(), first(), last(), row_number(), n() - values



# Try this yourself!


# 1. Pick a country and store its data in a separate variable.

# 2. Take two random years, and keep only the year with a larger gdp per capita.

# 3. Get european data from the year 2007, and calculate mean life expectancy, median of population and least gdppercap Hint: mean(), median(), min()

# 4. Take the data stored in point one, and add a new variable that shows how much larger is its gdppercap in 2007 from 1952

# 5. Find all countries within Europe that have had a life expectancy over 75 for at least 20 years before 2007.

