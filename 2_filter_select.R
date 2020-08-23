# Processing data in R


# Let's read in some data
gapminder <- read_csv("data/gapminder.csv")


# As before we can look within a variable to see what it contains. In this case it is a dataframe.
gapminder

# Generally, we can also have a look at what is within the dataframe by clicking on its name in the environment menu top right. The same can be accomplished by running View(varname) - this is one of the rare functions starting with a capital letter.


View(gapminder)


# Let's start using basic functions in tidyverse format.
## data %>%
##  function1() %>%
##  function2()
## 


# We can take filter() as the first function. This allows rows to be selected from a dataset based on some criteria.

# For example, we can take all data from Finland. This will give us 12 yearly observations on Finland.
gapminder %>% 
  filter(country=="Finland")

# Alternatively we can take all data from the year 1952. Here we get one datapoint per country.
gapminder %>% 
  filter(year==1952)

# To spell it out, we are making a test for all the values in the column year or country, and keeping only the ones that match our case.


# Because it works sequentially, we can add one multiple filters
gapminder %>% 
  filter(country=="Finland") %>% 
  filter(year==1952)


# We can place here different types of tests that we encountered before.
gapminder %>% 
  filter(country%in%c("Finland","Germany"))


gapminder %>% 
  filter(year > 2000)


#And we can again add several criteria


gapminder %>% 
  filter(year <2000) %>% 
  filter(year >1980)

# We can also place several options within the filter. 

# AND & function means that both statements need to be true.
gapminder %>% 
  filter(year <2000&year >1980)

# , comma accomplishes the same function
gapminder %>% 
  filter(year <2000,year >1980)


# OR | function means that at least one statement needs to be true
gapminder %>% 
  filter(year >2000|year <1980)


# If we replace the earlier and with or, we get the whole dataset.
gapminder %>% 
  filter(year <2000|year >1980)

# There are a number of different combinations we can make.

gapminder %>% 
  filter(year==1952,pop<1000000)

gapminder %>% 
  filter(year==1952,lifeExp>70)


# And we can also include negation.
gapminder %>% 
  filter(!year==1952,gdpPercap>500,gdpPercap<1000)



# When running queries in sequence, make sure there is no pipe %>%  at the end of the query.
gapminder %>% 
  filter(country=="Finland") %>% 
  filter(year==1952) %>%
errror




### Small exercise

# 1. Find all data from Poland.


# 2. Find the population of Poland in 1972.


# 3. Find all data from Europe.


# 4. Find all European countries that had their life expectancy above 75 at some point in the 1970s.





######################################################################################3

# We can now expand our vocabulary a bit.


 
#' So far we know: ' 
#' - %>% - move data into the next process
#' - filter() - filter data by some criteria
#' 
#' Now we will add three more functions
#' - select() - pick certain columns of the dataset
#' - unique() - keep only unique rows
#' 
#' - arrange() - sort the data by some parameter
#' - arrange(desc()) - sort the data by some parameter in descending order
#' 


# The select() command can be used to select different parts of the dataframe. Although this dataset is quite compact, and not much selection is needed.
gapminder %>% 
  select(country,continent,year,lifeExp)

# We can also use numbers to select columns
gapminder %>% 
  select(1:4)

# We can take just country and continent
gapminder %>% 
  select(1:2)

# And the unique values there
gapminder %>% 
  select(1:2) %>% 
  unique()

# Or the same for continents
gapminder %>% 
  select(continent) %>% 
  unique()



# We can use arrange() to sort the data.

# The simplest option, we can find from throughout the dataset, which country had the highest population.

# First when we just arrange, we get the lowest population.
gapminder %>% 
  arrange(pop)

# Then, when we arrange in descending order, we get the highest population
gapminder %>% 
  arrange(desc(pop))

#However, as we see, in the 10 lowest, and the 10 highest values, there is a lot of repetitions. If we want to get a top10 or bottom10 list based on these parameters across all time, we can use a combination of select() and unique(). There are always many ways to accomplish the same task here.

# We can select() the columns country and continent, and we can keep only one option of each. The commands preserve the original order, and we get an all-time bottom10 list.
gapminder %>% 
  arrange(pop) %>% 
  select(country,continent) %>% 
  unique()

# Or a top 10 list, try here.





# But a more sensible question may be, which was the most populous country in 1952. For this we can use the filters again.
gapminder %>% 
  filter(year == 1952) %>% 
  arrange(desc(pop))

# Or what's the lowest life expectancy in 2007
gapminder %>% 
  filter(year == 2007) %>% 
  arrange(lifeExp) %>% 
  select(country, lifeExp)



# Select can be used here also to find the subset of the data that we are interested in.
gapminder %>% 
  filter(country=="Finland") %>% 
  select(year,pop,lifeExp)




# Finally, sometimes we want to take random samples from the dataset. Since this is a common need, there is a special function for it sample_n()

# We can take simply any 10 observations
gapminder %>% 
  sample_n(10)


# Or more meaningfully, pick 10 country observations from the year 2007.
gapminder %>% 
  filter(year==2007) %>% 
  sample_n(10)


# Try this out yourself! Find:

# 1. The country and year with the highest gdp per capita.


# 2. The trends in gdpPercap and life expectancy in that country. When was it lowest?


# 3. The top 10 countries in all time life expectancy.


# 4. An overview of the population of India


# 5. Five random countries in Asia in the year 2007

