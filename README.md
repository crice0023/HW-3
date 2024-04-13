# HW-3 Readme: Analysis of COVID-19 Data


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
