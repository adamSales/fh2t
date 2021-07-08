
---
title: "Attrition Analysis:Delayed, Including Pretest No-Shows"
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

```

Study sample:
Students with Delayed scores, including those without pretest scores, and excluding students of teachers in S03 and S07 and students with NA condition assignment.


|Z               | Total|   n|
|:---------------|-----:|---:|
|ASSISTments     |  1247| 253|
|BAU             |  1247| 235|
|Dragon          |  1247| 218|
|Dragon-Resource |  1247|  25|
|FH2T            |  1247| 486|
|FH2T-Resource   |  1247|  30|

Overall and Differential Attrition vis a vis WWC Standards:
![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)


Balance plot:
![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)

Balance tests:

|covariate   |method     |  statistic|   p.value|     p.adj|
|:-----------|:----------|----------:|---------:|---------:|
|pretest     |ANOVA      |  1.2995569| 0.2732307| 0.4371691|
|ScaleScore5 |ANOVA      |  0.6628409| 0.5750088| 0.6802536|
|race        |chisq.test | 12.9403916| 0.1653221| 0.4371691|
|FEMALE      |prop.test  |  1.8915320| 0.5952219| 0.6802536|
|EIP         |prop.test  |  0.5497273| 0.9078383| 0.9078383|
|ESOL        |prop.test  |  5.7676182| 0.1234800| 0.4371691|
|IEP         |prop.test  |  5.5834760| 0.1337302| 0.4371691|
|GIFTED      |prop.test  |  4.1957259| 0.2410902| 0.4371691|
xBalance version:
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png)

|Comparison             | Overall.p|
|:----------------------|---------:|
|FH2T vs. BAU           |     0.090|
|FH2T vs. Dragon        |     0.054|
|FH2T vs. ASSISTments   |     0.476|
|BAU vs. Dragon         |     0.509|
|BAU vs. ASSISTments    |     0.059|
|Dragon vs. ASSISTments |     0.477|
