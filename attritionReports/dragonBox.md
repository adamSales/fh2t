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
|Overall         |       3374|      0.818|      0.615|       0.525|      0.370|        0.747|
|FH2T            |       1306|      0.815|      0.611|       0.531|      0.372|        0.747|
|BAU             |        654|      0.813|      0.619|       0.532|      0.359|        0.729|
|ASSISTments     |        657|      0.813|      0.641|       0.539|      0.385|        0.778|
|Dragon          |        654|      0.821|      0.583|       0.498|      0.333|        0.737|
|Dragon-Resource |         51|      0.902|      0.686|       0.451|      0.490|        0.765|
|FH2T-Resource   |         52|      0.904|      0.654|       0.558|      0.577|        0.692|

Non-Attrition rates by Virtual/In-Person status:

|virtual   |Z               | n_assigned| hasPretest| hasMidtest| hasPosttest| hasDelayed| hasStatetest|
|:---------|:---------------|----------:|----------:|----------:|-----------:|----------:|------------:|
|In-Person |Overall         |       2016|      0.929|      0.672|       0.575|      0.414|        0.815|
|In-Person |FH2T            |        772|      0.926|      0.665|       0.580|      0.420|        0.811|
|In-Person |BAU             |        388|      0.925|      0.668|       0.570|      0.379|        0.786|
|In-Person |ASSISTments     |        389|      0.933|      0.704|       0.589|      0.437|        0.841|
|In-Person |Dragon          |        386|      0.930|      0.648|       0.565|      0.386|        0.834|
|In-Person |Dragon-Resource |         40|      0.950|      0.750|       0.500|      0.525|        0.800|
|In-Person |FH2T-Resource   |         41|      0.951|      0.707|       0.585|      0.585|        0.780|
|Virtual   |Overall         |       1358|      0.654|      0.529|       0.451|      0.303|        0.646|
|Virtual   |FH2T            |        534|      0.655|      0.534|       0.459|      0.303|        0.655|
|Virtual   |BAU             |        266|      0.650|      0.549|       0.477|      0.331|        0.647|
|Virtual   |ASSISTments     |        268|      0.638|      0.549|       0.466|      0.310|        0.687|
|Virtual   |Dragon          |        268|      0.664|      0.489|       0.403|      0.257|        0.597|
|Virtual   |Dragon-Resource |         11|      0.727|      0.455|       0.273|      0.364|        0.636|
|Virtual   |FH2T-Resource   |         11|      0.727|      0.455|       0.455|      0.545|        0.364|

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png)![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-2.png)


Overall and Differential Attrition vis a vis WWC Standards:
![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-2.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-3.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-4.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-5.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-6.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-7.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-8.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-9.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-10.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-11.png)![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-12.png)
