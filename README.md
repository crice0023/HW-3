# HW-3 Readme: Analysis of COVID-19 Data

## Project Description

This project used two existing data frames from a clean Rdata set from Project 1 (data_long and data_wide). Dataset manipulation and 
cleaning was first done in Rstudio session then all other manipulations were done inside the Spark session, locally. We opted to do Spark on the local machine
after many unsuccessful attempts using AWS (Amazon Web Services), a cloud based application where in theory, one could use Spark to complete this project. 

##  Repository Organization
The folder structure can be found here [https://github.com/crice0023/HW-3/tree/main].

For any users interested in replicating the project they can find two folders to accomplish this task using the link above. 

![image](https://github.com/crice0023/HW-3/assets/161267590/f4bc6a92-9f04-4f7c-83d9-3a1dfd7fb3f0)

## Main Findings
![image](https://github.com/crice0023/HW-3/blob/main/Rplot.png)

The highest rise in cases over time occurred in the United States, followed by Germany and Brazil, respectively.

![image](https://github.com/crice0023/HW-3/blob/main/Rplot01.png)

The highest change of rate of cases over time occurred in Germany, followed by United States and Japan, respectively.

## Interpretation of Regression Results

The intercept of 11.3086 translates to about 81,520 total COVID-19 cases when "Country_Region" is at its reference level and "days_since_start" is zero, assuming a nominal or baseline population value for the reference region, rather than zero. This would represent the estimated number of cases at the very start of data tracking or the outbreak in that baseline region.

### China Estimate (lowest estimate in the model)
  Based on the regression model's estimate, the total COVID-19 cases for China, when "days_since_start" is zero and assuming other variables are at their baseline or reference levels, would be approximately 4,741 cases. This reflects a significant decrease compared to the baseline country or region due to the -2.8446 coefficient associated with China in the model.

### United States Estimate (highest estimate in the model)
  Based on the regression model's estimate, when "days_since_start" is zero and assuming other variables are at their baseline or reference levels, the total COVID-19 cases for the United States would be approximately 231,863 cases. This represents a significant increase in cases compared to the baseline country or region, reflecting the 1.0453 coefficient increase associated with the United States in the model.

### days_since_start Estimate
  Based on the model's estimate of 0.0072:

After 1 day since the start of the dataset, the total COVID-19 cases are projected to increase to approximately 82,109, up from about 81,520 at the start.

After 10 days, the total COVID-19 cases are projected to reach approximately 87,606.

This demonstrates the cumulative effect of the daily increase in the logarithm of cases, with a coefficient of 0.0072. Each day contributes to a small but consistent rise in the number of cases, illustrating how the situation can escalate over time if other factors remain constant.

### t-statistic and p value: United States

The statistic column, otherwise known as the t-statistic for Country_RegionUS is 12.082 standard deviations away from zero and robust, while the p-value is extremely low. Hence, it provides very strong evidence that the coefficient for Country_RegionUS is significantly different from zero. This indicates that the model provides strong statistical evidence that the factor Country_RegionUS has a significant positive effect on the log of total COVID-19 cases, compared to the reference category in the model.

The statistic and P-value for Country_RegionUS clearly suggest a significant and impactful relationship between being in the US and the number of COVID cases, after controlling for other factors in the model such as population and days since the start of the pandemic.

### Regression 2 Interpretation

The intercept of 10.792 in your regression model corresponds to approximately 48,630 total COVID-19 cases. This represents the model's estimate for the number of cases at the starting point (zero days since the start) and in a minimal population scenario (hypothetical zero million population).

The Population_in_Millions t-statistic of -23.845, while negative, is also highly significant. This indicates that the predictor is statistically significant and the relationship it shows is reliable according to the model. The negative sign indicates that higher population figures are associated with a decrease in the logarithm of total COVID-19 cases.

The days_since_start t-statistic is 91.797 These t-statistics suggest that both the number of days since the start and the population size (despite the inverse nature) are crucial factors in predicting the log of COVID-19 cases, with very high levels of statistical certainty.
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
