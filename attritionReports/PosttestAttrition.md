
---
title: "Attrition Analysis:Posttest, Including Pretest No-Shows"
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
Students with Posttest scores, including those without pretest scores, and excluding students of teachers in S03 and S07 and students with NA condition assignment.


|Z               | Total|   n|
|:---------------|-----:|---:|
|ASSISTments     |  1774| 354|
|BAU             |  1774| 348|
|Dragon          |  1774| 326|
|Dragon-Resource |  1774|  23|
|FH2T            |  1774| 694|
|FH2T-Resource   |  1774|  29|

Overall and Differential Attrition vis a vis WWC Standards:
![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)


Balance plot:
![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)

Balance tests:

|covariate   |method     | statistic|   p.value|     p.adj|
|:-----------|:----------|---------:|---------:|---------:|
|pretest     |ANOVA      | 4.2748711| 0.0051497| 0.0411976|
|ScaleScore5 |ANOVA      | 0.8198145| 0.4829046| 0.6709906|
|race        |chisq.test | 6.3556335| 0.7038645| 0.8044166|
|FEMALE      |prop.test  | 2.3487667| 0.5032429| 0.6709906|
|EIP         |prop.test  | 0.1866551| 0.9797143| 0.9797143|
|ESOL        |prop.test  | 4.7773238| 0.1888479| 0.6709906|
|IEP         |prop.test  | 4.0305181| 0.2581875| 0.6709906|
|GIFTED      |prop.test  | 3.0977805| 0.3767937| 0.6709906|
xBalance version:
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png)

|Comparison             | Overall.p|
|:----------------------|---------:|
|FH2T vs. BAU           |     0.077|
|FH2T vs. Dragon        |     0.092|
|FH2T vs. ASSISTments   |     0.377|
|BAU vs. Dragon         |     0.011|
|BAU vs. ASSISTments    |     0.192|
|Dragon vs. ASSISTments |     0.612|
