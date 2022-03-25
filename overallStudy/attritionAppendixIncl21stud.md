---
title: "Appendix [?]: Attrition Analysis"
output: word_document
---







### Note

One school (call it "Q") dropped out of the study before randomization, and its students are not considered attritors. However, 21 students who started at different schools transferred into Q over the course of the study. Our main analysis counts them as Q students, and hence not attritors. However, this is not quite accurate--they _were_ randomized, and transferred subsequent to randomization (at which point most stopped using the software). In fact, a pretest score is available for 13 of these students, and a posttest is only available for 1 of them.

This version of the appendix considers these 21 students as students of other schools, not of Q.



## Introduction

Our approach to causal inference under attrition, following WWC (2020) and others, is to attempt to estimate treatment effects for the subset of students in our analysis sample, i.e. those who did not attrit. Under this approach, missing data methods such as full-information maximum likelihood or multiple imputation are not necessary, since we make no claims about larger populations that include both potential attritors and non-attritors. On the other hand, causal inference for non-attritors will be biased if attrition induces a selection effect–that is, if different students would attrit under different experimental conditions, and if these differences correlate with experimental outcomes. We assess the threat of attrition bias in two ways–first, by comparing attrition rates across conditions, and second by checking if non-attritting students assigned to different conditions were equivalent at baseline. More details can be found at WWC (2020).

## Calculating Attrition Rates




Table: Table 1: Attrition rates by experimental condition

|                     | Overall| active Control| Immediate Feedback| DragonBox|   FH2T|
|:--------------------|-------:|--------------:|------------------:|---------:|------:|
|# Randomized         |  3612.0|          723.0|              725.0|     724.0| 1440.0|
|# in Analysis Sample |  1850.0|          366.0|              381.0|     350.0|  753.0|
|# Attrition Rate (%) |    48.8|           49.4|               47.4|      51.7|   47.7|

To compare overall and differential attrition for pairwise comparisons of FH2T, DragonBox, and Immediate Feedback to Active Control, we calculate overall attrition as the number attrited for both conditions combined, divided by the number randomized; differential attrition is simply the difference of the numbers in the third row of Table 1 for the two conditions under comparison. The results are in Table 2.


Table: Table 2: Overall attrition for pairwise comparisons in the lower triangular, and the differential attrition in the upper triangular.

|                   | active Control| Immediate Feedback| DragonBox| FH2T|
|:------------------|--------------:|------------------:|---------:|----:|
|active Control     |              -|                1.9|      -2.3|  1.7|
|Immediate Feedback |           48.4|                  -|      -4.2| -0.3|
|DragonBox          |           50.5|               49.6|         -|  3.9|
|FH2T               |           48.3|               47.6|      49.0|    -|

Figure 1 superimposes the results in Table 2, for Active control comparisons, onto Figure II.2 from the What Works Clearinghouse (WWC) Standards Handbook, Version 4.1 (WWC 2020), showing that attrition is tolerable under optimistic and/or cautious assumptions.

Figure 1: Attrition rates for Active control comparisons, compared to WWC standards.
![plot of chunk wwcPlot](figure/wwcPlot-1.png)

Finally, the following is a test of null hypothesis that the probability of attrition is equal across the four conditions:

```
## 
## 	4-sample test for equality of proportions without continuity
## 	correction
## 
## data:  as.vector out of as.vectorNcond - ncond out of Ncond
## X-squared = 3.6791, df = 3, p-value = 0.2983
## alternative hypothesis: two.sided
## sample estimates:
##    prop 1    prop 2    prop 3    prop 4 
## 0.4937759 0.4744828 0.5165746 0.4770833
```

### Attrition rates for students in Virtual or In-Person Conditions

Anecdotal evidence from teachers and other education professionals involved in the study suggested that some students assigned to the DragonBox condition who began the school year remotely had difficulties installing the DragonBox software, and that this may have led to higher attrition rates.
To see whether this may be so, we decompose attrition rates by virtual versus in-person status.


Table: Table 3: Population and sample sizes and attrition rates for virtual students

|                     | Overall| active Control| Immediate Feedback| DragonBox|  FH2T|
|:--------------------|-------:|--------------:|------------------:|---------:|-----:|
|# Randomized         |  1534.0|          307.0|              308.0|       308| 611.0|
|# in Analysis Sample |   605.0|          120.0|              125.0|       111| 249.0|
|# Attrition Rate (%) |    60.6|           60.9|               59.4|        64|  59.2|


Table: Table 4: Population and sample sizes and attrition rates for in-person students

|                     | Overall| active Control| Immediate Feedback| DragonBox|  FH2T|
|:--------------------|-------:|--------------:|------------------:|---------:|-----:|
|# Randomized         |  2078.0|          416.0|              417.0|     416.0| 829.0|
|# in Analysis Sample |  1245.0|          246.0|              256.0|     239.0| 504.0|
|# Attrition Rate (%) |    40.1|           40.9|               38.6|      42.5|  39.2|

Overall attrition rates are substantially higher for virtual students ($\approx$60%) than for in-person students ($\approx$40\%).
Differential attrition is similar for virtual and in-person students when comparing Active Control to FH2T (-1.7 vs -1.8) or to Immediate Feedback (-1.5 vs -2.1).
However, when comparing Active Control to DragonBox, differential attrition is double for virtual students (3.4) than for in-person students (1.7), providing some support for the hypothesis that virtual students assigned to DragonBox had particular difficulty participating in the experiment.

Notably, the overall and differential attrition rates for virtual students do not meet either the optimistic or cautious WWC standards, while the rates for in-person students meet both sets of standards.

## Baseline Equivalence for Non-Attritors

To further check whether differential attrition was informative or ignorable, we compared covariate means between non-attritting students assigned to each of the three experimental conditions (FH2T, DragonBox, and Immediate Feedback) and non-attritting students assigned to the Active Control.

Figure 2 plots covariate distributions across the four treatment groups; little imbalance is apparent.



![Figure 2: Comparing covariates across conditions](figure/balancePlot-1.png)

### Estimating Baseline Equivalence

First, we estimated covariate imbalance between conditions for each covariate, in the scale recommended by WWC (2020).
In particular, for pretest (a numeric variable), we estimated Hedges' g comparing pretest between conditions "A" and "B" as:
$$ g=\left(1-\frac{3}{4(n_A+n_B)-9}\right)\frac{\bar{x}_A-\bar{x}_B}{\sqrt{\frac{(n_A-1)s_A^2+(n_B-1)s_B^2}{n_A+n+B-2}}}$$
where $\bar{x}_A$, $S^2_A$, and $n_A$ are the average and sample variance pretest and sample size in condition A, and $\bar{x}_B$, $S^2_B$, and $n_B$ are defined similarly.

For binary or categorical variables, we estimated the Cox index. Let $p_A$ and $p_B$ be the sample proportions in conditions A and B. Then
$$ d_{Cox}=\frac{1}{1.65}log\left(\frac{p_A(1-p_B)}{p_B(1-p_A)}\right)$$
See WWC (2020b), p. 15.

The results for the three Active control comparisons are in Table 5 and Figure 3. All of the differences are below the upper WWC threshold of 0.25, though several are above the lower threshold of 0.05, indicating the need for statistical adjustment.


Table: Table 5: Cox indices (for binary or categorical covariates) and Hedges's g (for numeric covariates) comparing baseline covariate means between each of the experimental conditions and the Active Control (positive differences indicate higher means for the experimental conditions, compared to Active Control). Stars indicate effect sizes >0.05, for which WWC recommends statistical adjustment

|            |ASSISTments |Dragon  |FH2T    |
|:-----------|:-----------|:-------|:-------|
|FEMALE      |0.047       |0.039   |-0.06*  |
|EIP         |0.022       |0.101*  |-0.031  |
|IEP         |-0.046      |0.084*  |-0.162* |
|GIFTED      |0.025       |-0.231* |-0.026  |
|virtual     |0.001       |-0.03   |0.008   |
|accelerated |-0.024      |-0.075* |-0.058* |
|Asian       |-0.05       |-0.116* |-0.1*   |
|Other       |-0.1*       |0.092*  |0.065*  |
|pretest     |0.087*      |0.099*  |0.038   |


![Figure 3: Effect Sizes comparing covariate means between each experimental condition and the Active Control. The solid line at 0 indicates identical means; effect sizes outside of the dashed lines at -0.05 and 0.05 indicate a need for statistical adjustment](figure/lovePlot-1.png)


### Testing the Null Hypothesis of Baseline Equivalence

If attrition is ignorable, then the observed treatment groups in the analysis sample--i.e. non-attritor--should be comparable.
Evidence against ignorable attrition could be expressed as evidence against the null hypothesis
$$H_0: X \perp Z$$
where $X$ is a covariate and $Z$ indicates treatment assignment.
In practice, we test the following simpler null hypothesis (which is also, arguably, more to the point):
$$H_0: \mathbf{E}[X|Z=A]=\mathbf{E}[X|Z=B]$$
of equality of expectation between treatment conditions A and B.

There are a number of methodological hurdles to a proper test.
First of all, the tests should account for the randomization blocking. Second, we conduct a test of $H_0$ for each covariate for three different Active control comparisons, leading to multiple comparisons and (potentially) inflated Type-I error rates.

We rely on methods described in Hansen and Bowers (2008) and implemented in the `RItools` package in `R`.
This includes a separate omnibus test for balance in all covariates for each of the comparisons.
It also accounts for blocking (for simplicity, we use classrooms as blocks) and computes tests for individual covariates.

Table 6 gives the test statistics and p-values for omnibus tests across all covariates:

Table: Table 6: Overall covariate balance for each of the Active Control comparisons

|contrast           | chisquare| df| p.value|
|:------------------|---------:|--:|-------:|
|Immediate Feedback |     6.391|  8|   0.604|
|FH2T               |    10.200|  8|   0.251|
|DragonBox          |    15.771|  8|   0.046|

There is some evidence for imbalance between the Active Control and DragonBox condition, although if we were to correct for having tested three separate null hypotheses, that result would cease to be statistically significant.
There is no evidence for imbalance in the other two contrasts.

Table 7 gives hypothesis test results (Z-scores) for each covariate in each Active Control comparison. across the three comparisons, only pretest is significantly imbalanced.
Since pretest is the most important covariate, imbalance in pretest across the groups is notable, even if multiplicity corrections would increase the p-values above 0.05.


Table: Table 7: Z-scores testing baseline covariate balance between each experimental condition and the Active Control

|                |Immediate Feedback |FH2T   |DragonBox |
|:---------------|:------------------|:------|:---------|
|pretest         |2.014*             |2.03*  |3.013**   |
|raceWhite       |0.794              |0.385  |-0.238    |
|raceAsian       |-0.658             |-0.981 |-1.31     |
|raceOther       |-0.369             |0.294  |1.222     |
|FEMALE          |0.088              |-0.962 |0.275     |
|EIP             |0.182              |-0.334 |0.153     |
|IEP             |-0.752             |-1.639 |0.304     |
|GIFTED          |0.255              |-0.034 |-1.24     |
|virtual         |0                  |0      |0         |
|acceleratedTRUE |0.077              |0.08   |-0.319    |




