
---
title: "Attrition Analysis:Midtest, Including Pretest No-Shows"
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
Students with Midtest scores, including those without pretest scores, and excluding students of teachers in S03 and S07 and students with NA condition assignment.


|Z               | Total|   n|
|:---------------|-----:|---:|
|ASSISTments     |  2076| 421|
|BAU             |  2076| 405|
|Dragon          |  2076| 381|
|Dragon-Resource |  2076|  35|
|FH2T            |  2076| 800|
|FH2T-Resource   |  2076|  34|

Overall and Differential Attrition vis a vis WWC Standards:
![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)


Balance plot:
![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)

Balance tests:

|covariate   |method     | statistic|   p.value|     p.adj|
|:-----------|:----------|---------:|---------:|---------:|
|pretest     |ANOVA      | 1.7552387| 0.1537508| 0.5844802|
|ScaleScore5 |ANOVA      | 0.8341824| 0.4750404| 0.7600646|
|race        |chisq.test | 6.6204212| 0.6765715| 0.7732246|
|FEMALE      |prop.test  | 3.2337401| 0.3569718| 0.7139435|
|EIP         |prop.test  | 0.7989668| 0.8497142| 0.8497142|
|ESOL        |prop.test  | 4.8854090| 0.1803830| 0.5844802|
|IEP         |prop.test  | 4.4238939| 0.2191801| 0.5844802|
|GIFTED      |prop.test  | 1.8869972| 0.5961887| 0.7732246|
xBalance version:
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png)

|Comparison             | Overall.p|
|:----------------------|---------:|
|FH2T vs. BAU           |     0.621|
|FH2T vs. Dragon        |     0.190|
|FH2T vs. ASSISTments   |     0.453|
|BAU vs. Dragon         |     0.269|
|BAU vs. ASSISTments    |     0.268|
|Dragon vs. ASSISTments |     0.811|
