---
title: "Attrition Analysis: Dragon Box"
output: html_document
---







#Drop schools with <0.01 posttest scores (S03 & S07)


```
````
Non-Attrition rates by condition:


|Z               | n_assigned| hasPretest| hasMidtest| hasPosttest| hasDelayed| hasStatetest|
|:---------------|----------:|----------:|----------:|-----------:|----------:|------------:|
|Overall         |       3634|      0.787|      0.571|       0.488|      0.343|        0.739|
|FH2T            |       1409|      0.783|      0.568|       0.493|      0.345|        0.739|
|BAU             |        706|      0.779|      0.574|       0.493|      0.333|        0.725|
|ASSISTments     |        708|      0.778|      0.595|       0.500|      0.357|        0.766|
|Dragon          |        704|      0.800|      0.541|       0.463|      0.310|        0.730|
|Dragon-Resource |         53|      0.868|      0.660|       0.434|      0.472|        0.736|
|FH2T-Resource   |         54|      0.870|      0.630|       0.537|      0.556|        0.685|

Non-Attrition rates by Virtual/In-Person status:

|Z               |virtual   | n_assigned| hasPretest| hasMidtest| hasPosttest| hasDelayed| hasStatetest|
|:---------------|:---------|----------:|----------:|----------:|-----------:|----------:|------------:|
|Overall         |In-Person |       2016|      0.929|      0.672|       0.575|      0.414|        0.815|
|Overall         |Virtual   |       1618|      0.610|      0.446|       0.379|      0.255|        0.643|
|FH2T            |In-Person |        772|      0.926|      0.665|       0.580|      0.420|        0.811|
|FH2T            |Virtual   |        637|      0.609|      0.451|       0.386|      0.254|        0.651|
|BAU             |In-Person |        388|      0.925|      0.668|       0.570|      0.379|        0.786|
|BAU             |Virtual   |        318|      0.601|      0.459|       0.399|      0.277|        0.651|
|ASSISTments     |In-Person |        389|      0.933|      0.704|       0.589|      0.437|        0.841|
|ASSISTments     |Virtual   |        319|      0.589|      0.461|       0.392|      0.260|        0.674|
|Dragon          |In-Person |        386|      0.930|      0.648|       0.565|      0.386|        0.834|
|Dragon          |Virtual   |        318|      0.642|      0.412|       0.340|      0.217|        0.604|
|Dragon-Resource |In-Person |         40|      0.950|      0.750|       0.500|      0.525|        0.800|
|Dragon-Resource |Virtual   |         13|      0.615|      0.385|       0.231|      0.308|        0.538|
|FH2T-Resource   |In-Person |         41|      0.951|      0.707|       0.585|      0.585|        0.780|
|FH2T-Resource   |Virtual   |         13|      0.615|      0.385|       0.385|      0.462|        0.385|


Overall and Differential Attrition vis a vis WWC Standards:
![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-2.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-3.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-4.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-5.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-6.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-7.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-8.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-9.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-10.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-11.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-12.png)
