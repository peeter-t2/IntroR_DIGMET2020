
# So far we have worked with the clean gapminder dataset. Usually the datasets that we need to use are less clean than this one, include extra information and are not built exactly for working in R.
# We can here take the equivalent data to gapminder on EU from the EUROSTAT page.

# They were available on the website in a .tsv format, and thus can be read with read_tsv
eu_lifeExp <- read_tsv("data/demo_mlexpec.tsv")
eu_lifeExp
# Looking at it more closely we see that it has used colon as a marker for missing data. This can differ a lot by datasets, and the solutions to deal with it as well.

# Currently, we can rely on an extra function for tidyverse readers, where we can mark the value used for na.
eu_lifeExp <- read_tsv("data/demo_mlexpec.tsv", na = ":")
# It gives us some errors, but let's not worry about that for now
eu_lifeExp

#One thing that we notice here is that there are a number of values in the first column, separated by commas. Here, the tab value used in .tsv was not used, so the reader did not split them. If we encounter situations like this, we can use a function separate() which separates this column into several different ones.

# We do this on the first column and give new column names ourselves.
eu_lifeExp <-
  eu_lifeExp %>% 
  separate(col=1,into=c("unit","sex","age","geo"), sep=",")

# See more on functions separate() and its complement unite() yourself at some point
# ?separate
# ?unite

# Now we have a bit cleaner dataset, let's have another look.
eu_lifeExp

# One thing that we notice in this dataframe is that it has a different format than the gapminder dataset. Here, observations of different years are place in columns not rows. In a sense, the sequence of numbers is here one observation. This is sometimes referred to as the wide format, while the way gapminder is set up for years as the long format. The one that is more appropriate depends on the task at hand.
gapminder



# However, to change the format of the table tidyverse offers two simple commands pivot_wider() for going from long to wide format, and pivot_longer() for going from wide to long format. (The names were chosen by the community after a long discussion on which names would be least likely to be misunderstood.)

# Thus, we can convert the data frame into a wide format by specifying which columns to select and which names to give to new columns. The previous column headers, written as numbers are written in a separate column of year, and the values in another column of lifeExp.
eu_lifeExp %>% 
  pivot_longer(cols=matches("[0-9]"), names_to="year", values_to="lifeExp")

###########
# Small diversion to column selection
# Here we used a bit more advanced features for column selecting too. eu_lifeExp as a wide dataset benefits from selecting the right data

# Easiest we can select just one year
eu_lifeExp %>% 
  select(unit,sex,age,"geo","2017")

# We can select also two years
eu_lifeExp %>% 
  select(unit,sex,age,"geo","2018","2017")

# But we can also use more complex queries. For example starts_with for 2000s
eu_lifeExp %>% 
  select(unit,sex,age,geo,starts_with("200"))

# Ends with for each 5 years
eu_lifeExp %>% 
  select(unit,sex,age,geo,ends_with("5"))

# We can use regular expressions to get data from each 5 years. If you don't know regular expressions, don't worry about it now. Here, | means OR, and $ means end of the text string.
eu_lifeExp %>% 
  select(unit,sex,age,geo,matches("0$|5$"))

# Or also with regular expressions, we can get all columns that contain a number in the name. This is what we used above. [] brackets give alternatives 0-9 gives all numbers in it.
eu_lifeExp %>% 
  select(unit,sex,age,geo,matches("[0-9]"))
###########################


# If we want to change the gapminder dataset to a wider format, we can use the pivot_wider() command. Here we note the names of the id columns, the ones that should stay as they are, the column to take the names from and the column to take the values from. In this case we need to limit to one of the values, as the wide format does not neatly fit more.

gapminder %>% 
  select(country,continent,year,pop) %>% 
  pivot_wider(id_cols=c("country","continent"),names_from="year",values_from="pop")


# Should we want to turn that to longer again, we can use pivot_longer on the result.
gapminder %>% 
  select(country,continent,year,pop) %>% 
  pivot_wider(id_cols=c("country","continent"),names_from="year",values_from="pop") %>%   
  pivot_longer(cols=matches("[0-9]"), names_to="year", values_to="pop")


# See also the illustrations in the files
#' <center>
#' ![](figures/pivot_wider_tidybook.png)
#' </center>
#' 
#' <center>
#' ![](figures/pivot_longer_tidybook.png)
#' </center>
#' 


# The long format is used frequently in tidyverse operations
# For example the plot needs the data in a long format
gapminder %>%
  group_by(country) %>%
  filter(year==max(year)) %>%
  ggplot(aes(y=lifeExp,x=gdpPercap,size=pop,color=continent))+
  geom_point()+
  scale_x_log10()

eu_lifeExp %>% 
  pivot_longer(cols=matches("[0-9]"), names_to="year", values_to="lifeExp") %>%
  filter(sex=="T",age=="Y1") %>%
  mutate(year=as.numeric(year)) %>% 
  ggplot(aes(y=lifeExp,x=year, color=geo))+
  geom_point()



# In this case we do not yet have the gdp per capita data for EU, only life expectancy data. This is given in a separate file.

# Let's read the file and do the same preprocessing
eu_gdpPercap <- read_tsv("data/sdg_08_10.tsv", na = ":") 
eu_gdpPercap <- eu_gdpPercap %>% # Nagu varemgi peame faili iseärasuste tõttu jaotama tunnusteks
  separate(col=1,into=c("unit","na_item","geo"), sep=",")

# The population data is also available in a separate file
eu_pop <- read_tsv("data/tps00001.tsv", na = ":") %>% 
  separate(col=1,into=c("when","geo"), sep=",")


# Now we have three datasets from EU.
eu_lifeExp
eu_gdpPercap
eu_pop



# This is now a very typical situation for in data analysis - the values we need are in different datasets and we need to combine them somehow. For this there are a number of commands in tidyverse to *join* datasets in different ways. (In other R packages, merge() is often used for this purpose.)

# There are a few main ways to join tables. The image below illustrates, and depicts the rows that will be kept.

#
#' <center>
#' ![](figures/joins.png)
#' </center>
#' 
#' 
#' - left_join() - joins the matching lines from right to the left, keeping the left table intact.
#' - right_join() - joins the matching lines from left to the right, keeping the right table intact.
#' - inner_join() - keeps only the matching lines from both tables
#' - full_join() - keeps all lines from both tables, even if nothing matches.
#' - anti_join() - works in an opposite way, and removes any matching rows from the first (left) table.
#' 
#' 
# The official documentation has a nice illustration for this

# We have two datasets here. (They are a part of the tidyverse dataset.)
band_members
band_instruments


# We can keep only the matching rows
band_members %>% inner_join(band_instruments)
#> Joining, by = "name"
#> # A tibble: 2 x 3
#>   name  band    plays 
#>   <chr> <chr>   <chr> 
#> 1 John  Beatles guitar
#> 2 Paul  Beatles bass  

#The command looks for common variable names, they can be set manually too
band_members %>% inner_join(band_instruments, by = "name")

# We can keep all rows in the left
band_members %>% left_join(band_instruments)
#> Joining, by = "name"
#> # A tibble: 3 x 3
#>   name  band    plays 
#>   <chr> <chr>   <chr> 
#> 1 Mick  Stones  <NA>  
#> 2 John  Beatles guitar
#> 3 Paul  Beatles bass  

# We can keep all rows in the right
band_members %>% right_join(band_instruments)
#> Joining, by = "name"
#> # A tibble: 3 x 3
#>   name  band    plays 
#>   <chr> <chr>   <chr> 
#> 1 John  Beatles guitar
#> 2 Paul  Beatles bass  
#> 3 Keith <NA>    guitar

# We can keep all rows from each table
band_members %>% full_join(band_instruments)
#> Joining, by = "name"
#> # A tibble: 4 x 3
#>   name  band    plays 
#>   <chr> <chr>   <chr> 
#> 1 Mick  Stones  <NA>  
#> 2 John  Beatles guitar
#> 3 Paul  Beatles bass  
#> 4 Keith <NA>    guitar

# We can remove any matching rows from the left
band_members %>% anti_join(band_instruments)
#> Joining, by = "name"
#> # A tibble: 1 x 2
#>   name  band  
#>   <chr> <chr> 
#> 1 Mick  Stones






# Seejärel võime teha kummastki tabelist "pika" variandi
eu_lifeExp_long <- eu_lifeExp %>% 
  filter(sex=="T",age=="Y1") %>% 
  select(-unit,-sex,-age) %>% 
  pivot_longer(cols=matches("[0-9]"), names_to="year", values_to="lifeExp")

eu_gdpPercap_long <- eu_gdpPercap %>% 
  filter(unit=="CLV10_EUR_HAB") %>% 
  select(-unit,-na_item) %>% 
  pivot_longer(cols=matches("[0-9]"), names_to="year", values_to="gdpPercap")


eu_pop_long <- eu_pop %>% 
  select(-when,-`2019`) %>% 
  pivot_longer(cols=matches("[0-9]"), names_to="year", values_to="pop")


# Ja lõpuks need kokku siduda riikide ja aastate kaupa. Nüüd on meil kõrvuti eluiga ja antud väärtus sellest.
eu_lifeExp_gdpPercap <- eu_lifeExp_long %>% 
  left_join(eu_gdpPercap_long,by=c("geo","year"))

eu_lifeExp_gdpPercap %>% 
  filter(!is.na(lifeExp),!is.na(gdpPercap))

eu_lifeExp_gdpPercap <- eu_lifeExp_long %>% 
  inner_join(eu_gdpPercap_long,by=c("geo","year"))

eu_lifeExp_gdpPercap_pop <- eu_lifeExp_gdpPercap %>% 
  inner_join(eu_pop_long,by=c("geo","year"))


eu_lifeExp_gdpPercap_pop %>% 
  ggplot(aes(y=lifeExp,x=gdpPercap,size=pop,color=geo))+
  geom_point()+
  scale_x_log10()




# Try this yourself.

# 1. Now start with the EU dataset. First, pick a country.

# 2. Filter out only the data relevant to that country.

# 3. Calculate its gdp in the first year there is data.

# 4. Calculate its average life expectancy in the last 5 years for which there is data.

# 5. Create a table with the life expectancy, gdp per capita, population and gdp by year for the 2000s. Save it in a file. Preferably in a wide format.


# For saving the file you can use write_tsv(). Simply replace data with your variable name, or remove data, and attach this to the end of a block via a pipe %>%. Change the filename as needed. This writes a tsv. See write_csv, write_csv2, write_delim for more options.

?write_csv
write_tsv(data,"filename.tsv")
