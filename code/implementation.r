library(tidyverse)

dat <- read_csv('data/IES_assessment_final_2021_06_03_N=4284 - Sheet1.csv')

dat <- dat%>%
    mutate(
        preNA=is.na(pre_PS_completed_percent),
        delayedNA=is.na(delayed.math_completed_num),
        midNA=is.na(mid.math_completed_num),
        postNA=is.na(post.math_completed_percent),
        numNA=preNA+delayedNA+midNA+postNA,
        numOutNA=delayedNA+midNA+postNA)

xtabs(~numNA,data=dat)
xtabs(~numOutNA,data=filter(dat,!preNA))
