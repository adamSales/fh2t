library(tidyverse)
library(RItools)
library(mosaic)

dat <- read_csv('data/Assessment_merged_2021_06_16_state_assessment_N=4311.csv')

### attrition variables
dat <- dat%>%
    mutate(
        hasPretest=is.finite(pre_MA_total_score),
        hasMidtest=is.finite(mid_MA_total_score),
        hasPosttest=is.finite(post_MA_total_score),
        hasDelayed=is.finite(delayed.total_math_score)
        )
### what's the difference between hasDelayed & complete_delayed_posttest?

dat$Z <- dat$rdm_condition ## differentiates between * and *-Resource (what does this mean?)

## a couple schools basically just dropped out
dat%>%
    group_by(initial_teacher_id)%>%
    summarize(n=n(),across(starts_with('has'),mean))

dat$initial_school_id[is.na(dat$initial_school_id)] <- 'SNA'


## drop schools where (almost) everyone dropped out (S03 & S07)
dat <-
    dat%>%
    group_by(initial_school_id)%>%
    mutate(prePer=mean(hasPretest),midPer=mean(hasMidtest))%>%
    filter(midPer>0.01)%>%
    ungroup()%>%
    select(-midPer)

dropOutTeachers <- c(
'F7T1123',
'F7T1123',
'F7T1120',
'F7T1115',
'F7T1115',
'F7T1134',
'F7T1134',
'F7T1133')

dat <- dat%>%filter(!initial_teacher_id%in%dropOutTeachers)

### between randomization & pretest

##overall attrition



