# HW-3 Readme
HW-3 Rmarkdown: Analysis of COVID-19 Data
Chris Rice
2024-04-09
This project used two existing csv files from Project 1. Dataset manipulation and cleaning was first done in Rstudio then all other manipulations were done inside the Spark session, locally. For Rmarkdown simplicity, a data frame called “spark_subset” was saved to be used as a reference for the two ggplots below.

The code below that is commented out shows the steps the analyst underwent to prepare the 2 imported CSVs into a merged data set. We had to do some moderate cleaning such as removing “X” from the date columns and reformatting the date column. In addition, we created the numeric column “days_since_start” so that the linear regression could be performed. Once that was in place then we proceeded with creating two graphs that are shown below.

Take note, we can see the where the Spark connection begins. After connecting and running things in Spark, locally, we created the ggplots. Initially, we tried to connect to Spark using an AWS server but this attempt was unsuccessful.

#Here is the code to prepare Project 1 datasets: 

# Convert dataset to long format
#data_long <- pivot_longer(
  #data_wide,
  #cols = starts_with("X"),
  #names_to = "date",
  #values_to = "cases"
#)

# Remove the leading 'X' from the date column and replace dots with slashes
# data_long <- data_long %>%
#   mutate(date = gsub("^X", "", date),
#          date = gsub("\\.", "/", date))

#data_long <- data_long %>%
  #mutate(date = as.Date(date, format = "%m/%d/%y")) # Adjust format as necessary

# Find the start date
#start_date <- min(data_long$date, na.rm = TRUE)

# Calculate days since start
# data_long <- data_long %>%
#   mutate(days_since_start = as.numeric(date - start_date))
# 
# #data_long <- data_long %>%
#   mutate(rate = (cases / Population) * 100000) # This calculates rate per 100,000 population

######## Begin SPARK Activities ##############################################
# 
# 
# library(sparklyr)
# 
# sc <- spark_connect(master = "local")
# 
# # Copy the data frame to Spark
# spark_data_long <- sdf_copy_to(sc, data_long, "data_long", overwrite = TRUE)
# 
# 
# library(dplyr)
# library(ggplot2)
# 
# 
# # Assuming 'Country_Region' is the column with country names
# countries_of_interest <- c("Germany", "China", "Japan", "United Kingdom", "US", "Brazil", "Mexico")
# 
# filtered_spark_data_long <- spark_data_long %>%
#   filter(Country_Region %in% countries_of_interest)
# 
# # check columns
# colnames(filtered_spark_data_long)
# 
# # Collect a smaller, relevant subset since full dataset is too large
# spark_subset <- filtered_spark_data_long %>%
#   select(Country_Region, date, cases, rate, Population, days_since_start) %>%
#   collect()
# 
# spark_subset <- filtered_spark_data_long %>%
#   group_by(Country_Region, date) %>%
#   summarise(
#     total_cases = sum(cases, na.rm = TRUE),
#     average_rate = mean(rate, na.rm = TRUE),
#     Population = max(Population, na.rm = TRUE),
#     days_since_start = sum(days_since_start, na.rm = TRUE),
#     .groups = "drop"  # This will remove all grouping from the resulting data frame
#   ) %>%
#   collect()

load("C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/spark_subset.RData")

ggplot(spark_subset, aes(x = date, y = total_cases, color = Country_Region)) +
  geom_line() +
  labs(title = "Change in the Number of Cases by Country and Date",
       x = "Date", y = "Total Cases") +
  theme_minimal()


Graph 1: displays our project’s selected countries and change in cases
As we can observe in the graph above, the highest rise in cases over time occurred in the United States, followed by Germany and Brazil, respectively.

ggplot(spark_subset, aes(x = date, y = average_rate, color = Country_Region)) +
  geom_line() +
  labs(title = "Change in the Rate of Cases by Country and Date",
       x = "Date", y = "Rate of Cases") +
  theme_minimal()


Graph 2: displays our project’s selected countries and change in cases
As we can observe in the graph above, the highest change of rate of cases over time occurred in Germany, followed by United States and Japan, respectively.

Linear Regression
load("C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/spark_data_subset_r.RData")

model_local <- lm(
  log_total_cases ~ Country_Region + days_since_start + Population, 
  data = spark_data_subset_r
)

# Tidy and display the model using broom and kableExtra
tidied_model_local <- tidy(model_local)

kable(tidied_model_local, caption = "Regression Model Summary", format = "html", 
      col.names = c("Term", "Estimate", "Std. Error", "Statistic", "P-value"),
      digits = c(3, 4, 4, 3, 20),
      align = c('l', 'r', 'r', 'r', 'r')) %>%
  kable_styling(bootstrap_options = c("striped", "hover"))
Regression Model Summary
Term	Estimate	Std. Error	Statistic	P-value
(Intercept)	15.2951	0.0885	172.786	0.000000e+00
Country_RegionChina	-6.8657	0.1845	-37.214	0.000000e+00
Country_RegionGermany	-0.7908	0.1251	-6.323	2.696085e-10
Country_RegionJapan	-2.0104	0.1251	-16.077	0.000000e+00
Country_RegionMexico	-1.6407	0.1251	-13.120	0.000000e+00
Country_RegionUnited Kingdom	-2.3390	0.1377	-16.991	0.000000e+00
Country_RegionUS	1.0453	0.1251	8.359	7.402000e-17
days_since_start	0.0002	0.0000	29.645	0.000000e+00
Population	NA	NA	NA	NA
Linear Regression showing the relationship between log cases and model vars.
Note: Country_RegionUS is yielding NA results. In fact, no matter the order used in “model_local” the 8th row produces NA results. Thus, the order was rearranged again below in an addition regression to show all modeled information. This was the work around to complete the task. If future time exists more trouble shooting would be advised.

Linear Regression 2
load("C:/Users/ricecakes/Desktop/Git1/HW-3/HW-3/spark_data_subset_r.RData")

model_local <- lm(
  log_total_cases ~ Country_Region + Population + days_since_start,
  data = spark_data_subset_r
)

# Tidy and display the model using broom and kableExtra
tidied_model_local <- tidy(model_local)

kable(tidied_model_local, caption = "Regression Model Summary", format = "html", 
      col.names = c("Term", "Estimate", "Std. Error", "Statistic", "P-value"),
      digits = c(3, 4, 4, 3, 20),
      align = c('l', 'r', 'r', 'r', 'r')) %>%
  kable_styling(bootstrap_options = c("striped", "hover"))
Regression Model Summary
Term	Estimate	Std. Error	Statistic	P-value
(Intercept)	15.2951	0.0885	172.786	0.000000e+00
Country_RegionChina	-6.8657	0.1845	-37.214	0.000000e+00
Country_RegionGermany	-0.7908	0.1251	-6.323	2.696085e-10
Country_RegionJapan	-2.0104	0.1251	-16.077	0.000000e+00
Country_RegionMexico	-1.6407	0.1251	-13.120	0.000000e+00
Country_RegionUnited Kingdom	-2.3390	0.1377	-16.991	0.000000e+00
Country_RegionUS	1.0453	0.1251	8.359	7.402000e-17
Population	NA	NA	NA	NA
days_since_start	0.0002	0.0000	29.645	0.000000e+00










## Session Info

<pre>
```
$spark.env.SPARK_LOCAL_IP.local
[1] "127.0.0.1"

$sparklyr.connect.csv.embedded
[1] "^1.*"

$spark.sql.legacy.utcTimestampFunc.enabled
[1] TRUE

$sparklyr.connect.cores.local
[1] 4

$spark.sql.shuffle.partitions.local
[1] 4

> sessionInfo()
R version 4.3.0 (2023-04-21 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Matrix products: default


locale:
[1] LC_COLLATE=English_United States.utf8 
[2] LC_CTYPE=C                            
[3] LC_MONETARY=English_United States.utf8
[4] LC_NUMERIC=C                          
[5] LC_TIME=English_United States.utf8    

time zone: America/New_York
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets 
[6] methods   base     

other attached packages:
[1] texreg_1.39.3

loaded via a namespace (and not attached):
 [1] vctrs_0.6.5       httr_1.4.7        cli_3.6.2        
 [4] knitr_1.46        rlang_1.1.3       xfun_0.43        
 [7] DBI_1.2.2         purrr_1.0.2       generics_0.1.3   
[10] jsonlite_1.8.8    glue_1.7.0        openssl_2.1.1    
[13] dbplyr_2.5.0      askpass_1.2.0     htmltools_0.5.8.1
[16] fansi_1.0.6       rmarkdown_2.26    evaluate_0.23    
[19] tibble_3.2.1      fastmap_1.1.1     yaml_2.3.8       
[22] lifecycle_1.0.4   compiler_4.3.0    dplyr_1.1.4      
[25] pkgconfig_2.0.3   tidyr_1.3.1       sparklyr_1.8.5   
[28] rstudioapi_0.16.0 digest_0.6.34     R6_2.5.1         
[31] tidyselect_1.2.1  utf8_1.2.4        pillar_1.9.0     
[34] magrittr_2.0.3    tools_4.3.0
