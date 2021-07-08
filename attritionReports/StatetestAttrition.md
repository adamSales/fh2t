
---
title: "Attrition Analysis:Statetest, Including Pretest No-Shows"
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
Students with Statetest scores, including those without pretest scores, and excluding students of teachers in S03 and S07 and students with NA condition assignment.


|Z               | Total|    n|
|:---------------|-----:|----:|
|ASSISTments     |  2685|  542|
|BAU             |  2685|  512|
|Dragon          |  2685|  514|
|Dragon-Resource |  2685|   39|
|FH2T            |  2685| 1041|
|FH2T-Resource   |  2685|   37|

Overall and Differential Attrition vis a vis WWC Standards:
![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)


Balance plot:
![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)

Balance tests:

|covariate   |method     | statistic|   p.value|     p.adj|
|:-----------|:----------|---------:|---------:|---------:|
|pretest     |ANOVA      | 1.6419051| 0.1776624| 0.7878324|
|ScaleScore5 |ANOVA      | 0.1835416| 0.9076235| 0.9076235|
|race        |chisq.test | 8.3324758| 0.5010188| 0.9076235|
|FEMALE      |prop.test  | 1.0003777| 0.8011606| 0.9076235|
|EIP         |prop.test  | 0.9760398| 0.8070494| 0.9076235|
|ESOL        |prop.test  | 4.4850382| 0.2136287| 0.7878324|
|IEP         |prop.test  | 3.7024616| 0.2954371| 0.7878324|
|GIFTED      |prop.test  | 0.7353156| 0.8648676| 0.9076235|
xBalance version:
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png)

|Comparison             | Overall.p|
|:----------------------|---------:|
|FH2T vs. BAU           |     0.644|
|FH2T vs. ASSISTments   |     0.336|
|FH2T vs. Dragon        |     0.709|
|BAU vs. ASSISTments    |     0.666|
|BAU vs. Dragon         |     0.659|
|ASSISTments vs. Dragon |     0.997|
