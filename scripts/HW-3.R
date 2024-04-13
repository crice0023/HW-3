# Load data sets from HW-1 #
load("C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/clean_covid_data.RData")

# explore data_long and data_wide for cleaning/merging

library(tidyr)
library(dplyr)

# Convert dataset to long format
data_long <- pivot_longer(
  data_wide,
  cols = starts_with("X"),
  names_to = "date",
  values_to = "cases"
)

# Remove the leading 'X' from the date column and replace dots with slashes
data_long <- data_long %>%
  mutate(date = gsub("^X", "", date),
         date = gsub("\\.", "/", date))

data_long <- data_long %>%
  mutate(date = as.Date(date, format = "%m/%d/%y")) =

# Find the start date
start_date <- min(data_long$date, na.rm = TRUE)

# Calculate days since start
data_long <- data_long %>%
  mutate(days_since_start = as.numeric(date - start_date))

data_long <- data_long %>%
  mutate(rate = (cases / Population) * 100000) # This calculates rate per 100,000 population

data_long <- data_long %>%
  mutate(
    rate = ifelse(Population > 0, (cases / Population) * 100000, NA), 
    total_cases = ifelse(is.na(cases), 0, cases), 
    log_total_cases = log(total_cases + 1)  
  )



######## Begin SPARK Activities ##############################################


library(sparklyr)

sc <- spark_connect(master = "local")

# Copy the data frame to Spark
spark_data_long <-
  sdf_copy_to(sc, data_long, "data_long", overwrite = TRUE)


library(dplyr)
library(ggplot2)


# Assuming 'Country_Region' is the column with country names
countries_of_interest <-
  c("Germany",
    "China",
    "Japan",
    "United Kingdom",
    "US",
    "Brazil",
    "Mexico")

filtered_spark_data_long <- spark_data_long %>%
  filter(Country_Region %in% countries_of_interest)

# check columns
colnames(filtered_spark_data_long)

# Collect a smaller, relevant subset since full dataset is too large
spark_subset <- filtered_spark_data_long %>%
  select(Country_Region, date, cases, rate, Population, days_since_start) %>%
  collect()

# Aggregation, assuming data_long is already prepared
spark_subset <- filtered_spark_data_long %>%
  group_by(Country_Region, date) %>%
  summarise(
    total_cases = sum(total_cases, na.rm = TRUE),
    average_rate = mean(rate, na.rm = TRUE),
    Population = max(Population, na.rm = TRUE),  
    days_since_start = max(days_since_start, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  collect()

spark_data_subset_r <- spark_data_subset_r %>%
  mutate(Population_scaled = scale(Population))


# Print summary to check for NAs and zeros in key variables
colnames(spark_data_subset_r)

summary(spark_data_subset_r$Population)

# Preparing for regression
spark_data_subset_r <- spark_subset %>%
  mutate(log_total_cases = log(total_cases + 1))  

# Plot: Change in the Number of Cases by Country and Day
library(ggplot2)

ggplot(spark_subset,
       aes(x = date, y = total_cases, color = Country_Region)) +
  geom_line() +
  labs(title = "Change in the Number of Cases by Country and Date",
       x = "Date", y = "Total Cases") +
  theme_minimal()

# Plot: Change in the Rate of Cases by Country and Day
ggplot(spark_subset,
       aes(x = date, y = average_rate, color = Country_Region)) +
  geom_line() +
  labs(title = "Change in the Rate of Cases by Country and Date",
       x = "Date", y = "Rate of Cases") +
  theme_minimal()

# # Assuming `spark_subset` is your local R data frame that needs to be in Spark
spark_data_subset <-
  sdf_copy_to(sc, spark_subset, "spark_data_subset", overwrite = TRUE)

spark_data_subset_r <-
  sdf_copy_to(sc, spark_data_subset, "spark_data_subset_r", overwrite = TRUE)
########################################
#
#
# #check columns
 colnames(spark_data_subset)

# Imputing total_cases with 0 (assuming NA means no cases)
spark_data_subset_r <- spark_data_subset_r %>%
  mutate(total_cases = ifelse(is.na(total_cases), 0, total_cases)) %>%
  mutate(log_total_cases = log(total_cases + 1))  # Adding 1 to avoid log(0)

spark_data_subset_r %>%
  summarize(
    Count_NA_log_total_cases = sum(ifelse(is.na(log_total_cases), 1, 0)),
    Count_NA_total_cases = sum(ifelse(is.na(total_cases), 1, 0))
  ) %>%
  collect()



model <- ml_linear_regression(spark_data_subset_r,
                              formula = log_total_cases ~ Country_Region + Population + days_since_start)


summary(model)


model_stats <- sdf_collect(spark_data_subset_r)

# Now model_stats is an R dataframe
library(knitr)
kable(model_stats, caption = "Regression Model Summary", format = "html")


#install.packages("kableExtra")
#install.packages("broom")
library(kableExtra)
library(broom)
# Use broom to tidy the model and make it ready for kable
tidied_model <- tidy(model)

# Display the model coefficients table
kable(
  model_stats,
  caption = "Regression Model Summary",
  format = "html",
  col.names = c("Term", "Estimate", "Std. Error", "Statistic", "P-value"),
  align = c('l', 'r', 'r', 'r', 'r')
) %>%
  kable_styling(bootstrap_options = c("striped", "hover"))


# disconnect from spark, close connection
spark_disconnect(sc)

################ SPARK ACTIVITIES END #########################################
###############
#############
#########            

#      Session info  ########   #########   ##########   ########

# Assuming 'sc' is your Spark connection object
config <- spark_config(sc)
print(config)
sessionInfo()

#####  end session info

### Additional prep work for Rmarkdown ease of use ############################

################### Data frame saves and misc #######

# Save the spark_subset dataset to an RData file
save(spark_subset, file = "C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/spark_subset.RData")

save(spark_subset, file = "C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/model_stats.RData")

save(data_long, file = "C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/data_long.RData")
# List all Spark DataFrames currently available
src_tbls(sc)

# Collect Spark DataFrame into an R DataFrame
spark_data_subset_r <- sdf_collect(spark_data_subset_r)
# Collect Spark DataFrame into an R DataFrame
spark_data_subset <- sdf_collect(spark_data_subset)


# Save the R DataFrame to an RData file
save(spark_data_subset_r, file = "C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/spark_data_subset_r.RData")

# Save the R DataFrame to an RData file
save(spark_data_subset, file = "C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/spark_data_subset.RData")

##############################################################################
spark_data_subset_r$Population_in_millions <- spark_data_subset_r$Population / 1e6

model_local <- lm(
  log_total_cases ~ days_since_start + Population_in_millions, 
  data = spark_data_subset_r
)
summary(model_local)
