---
title: "Appendix B: In-Person Students"
output: word_document
---










Both overall and differential attrition was substantially worse for students who began the year with remote instruction, as opposed to in-person instruction.
This section repeats the attrition analysis and the main HLM analysis for the subset of students who started the academic year in-person.

## Attrition Analysis

### Overall and Differential Attrition Rates for In-Person Students

Table: Table B.1: Attrition rates by experimental condition

|                     | Overall| active Control| Immediate Feedback| DragonBox|  FH2T|
|:--------------------|-------:|--------------:|------------------:|---------:|-----:|
|# Randomized         |  2078.0|          416.0|              417.0|     416.0| 829.0|
|# in Analysis Sample |  1245.0|          246.0|              256.0|     239.0| 504.0|
|# Attrition Rate (%) |    40.1|           40.9|               38.6|      42.5|  39.2|

![Figure B.1: Overall and Differential Attrition for In-Person Students, Plotted Against WWC Standards.](figure/IPwccAttritionNumbers-1.png)

### Baseline Equivalence for In-Person Students


Figure B.2 plots covariate distributions across the four treatment groups; little imbalance is apparent.



![Figure B.2: Comparing covariates across conditions](figure/IPbalancePlot-1.png)





Table: Table B.2: Effect sizes for covariate mean differences between each of the experimental conditions and the Active Control for in-person students. Stars indicate effect sizes >0.05, for which WWC recommends statistical adjustment

|            |ASSISTments |Dragon  |FH2T    |
|:-----------|:-----------|:-------|:-------|
|FEMALE      |0.028       |-0.043  |-0.107* |
|EIP         |0.062*      |0.108*  |-0.032  |
|IEP         |-0.174*     |-0.003  |-0.219* |
|GIFTED      |0.093*      |-0.302* |0.009   |
|accelerated |0.035       |-0.025  |-0.05   |
|Hispanic    |-0.206*     |0.085*  |0.037   |
|Asian       |-0.119*     |-0.354* |-0.318* |
|Other       |-0.026      |-0.213* |-0.067* |
|pretest     |0.087*      |0.174*  |0.108*  |


Table: Table B.3: Overall covariate balance for each of the Active Control comparisons for In-Person students

|contrast           | chisquare| df| p.value|
|:------------------|---------:|--:|-------:|
|Immediate Feedback |     5.119|  9|   0.824|
|FH2T               |    11.918|  9|   0.218|
|DragonBox          |    11.079|  9|   0.270|


Table: Table B.4: Z-scores testing baseline covariate balance for in-person students between each experimental condition and the Active Control

|                |Immediate Feedback |FH2T   |DragonBox |
|:---------------|:------------------|:------|:---------|
|pretest         |0.932              |1.968* |2.542*    |
|raceWhite       |1.229              |0.727  |0.258     |
|raceHispanic    |-0.803             |0.488  |1.121     |
|raceAsian       |-0.774             |-1.449 |-1.427    |
|raceOther       |-0.317             |-0.627 |-0.746    |
|FEMALE          |-0.185             |-1.239 |-0.449    |
|EIP             |0.377              |-0.2   |0.036     |
|IEP             |-1.217             |-1.68. |-0.118    |
|GIFTED          |0.728              |-0.025 |-0.983    |
|acceleratedTRUE |0.273              |0.049  |0.477     |

## HLM Models


Table: HLMs for in-person students

|                      |Model 1 |            |Model 2 |              |Model 3 |             |Model 4 |             |
|:---------------------|:-------|:-----------|:-------|:-------------|:-------|:------------|:-------|:------------|
|(Intercept)           |3.75*** |[3.11,4.4]  |3.24*** |[2.87,3.62]   |3.21*** |[2.83,3.6]   |3.18*** |[2.8,3.57]   |
|FH2T                  |0.38*   |[0.08,0.68] |0.33*   |[0.04,0.63]   |0.36*   |[0.07,0.66]  |0.39**  |[0.09,0.68]  |
|DragonBox             |0.6***  |[0.25,0.95] |0.54**  |[0.19,0.88]   |0.67*** |[0.32,1.02]  |0.7***  |[0.35,1.05]  |
|Instant               |0.15    |[-0.19,0.5] |0.12    |[-0.22,0.45]  |0.13    |[-0.21,0.47] |0.16    |[-0.18,0.49] |
|center(pre)           |-       |-           |0.26*** |[0.19,0.32]   |0.25*** |[0.18,0.31]  |0.11.   |[-0.01,0.23] |
|Asian                 |-       |-           |0.31    |[-0.15,0.77]  |0.35    |[-0.11,0.81] |0.36    |[-0.1,0.82]  |
|Hispanic              |-       |-           |0.21    |[-0.09,0.51]  |0.22    |[-0.08,0.52] |0.23    |[-0.07,0.52] |
|Other                 |-       |-           |0.26    |[-0.17,0.68]  |0.23    |[-0.19,0.65] |0.22    |[-0.2,0.64]  |
|MALE                  |-       |-           |-0.25*  |[-0.47,-0.03] |-0.21.  |[-0.43,0.01] |-0.21.  |[-0.43,0.01] |
|GIFTED                |-       |-           |0.61**  |[0.18,1.03]   |0.61**  |[0.18,1.03]  |0.6**   |[0.17,1.02]  |
|acceleratedTRUE       |-       |-           |1.88*** |[1.34,2.42]   |1.8***  |[1.26,2.33]  |1.86*** |[1.32,2.4]   |
|EIP                   |-       |-           |-0.14   |[-0.53,0.24]  |-0.11   |[-0.5,0.28]  |-0.1    |[-0.49,0.29] |
|IEP                   |-       |-           |0.02    |[-0.35,0.38]  |0.04    |[-0.33,0.4]  |0.03    |[-0.34,0.39] |
|center(percomp)       |-       |-           |-       |-             |0.77*** |[0.33,1.2]   |0.75*** |[0.31,1.19]  |
|FH2T:center(pre)      |-       |-           |-       |-             |-       |-            |0.22**  |[0.08,0.36]  |
|DragonBox:center(pre) |-       |-           |-       |-             |-       |-            |0.11    |[-0.06,0.27] |
|Instant:center(pre)   |-       |-           |-       |-             |-       |-            |0.07    |[-0.09,0.23] |
