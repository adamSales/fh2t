library(tidyverse)
library(readxl)
library(lme4)
library(mosaic)

dat0 <- read_excel('data/ASSISTment_merge_2021_04_12_N=1,587_ver.02.xlsx')
dat <- read_csv('data/IES_assessment_final_2021_06_03_N=4284 - Sheet1.csv')
dat0$student_number <- gsub("\\.0",'',dat0$student_number)

dat <- filter(dat,student_number%in%dat0$student_number)%>%
    rename(condition=condition_assignment)

dat$race <- dat$student_raceEthnicityFed%>%
    factor()%>%
    fct_lump_min(200)%>%
    fct_recode(`Hispanic/Latino`="1",Asian="3",White="6")%>%
    fct_relevel('White') ## make White (the biggest category) the reference

### check that prob level sums to total
all.equal(rowSums(select(dat,starts_with("correct.01_"))),dat$pre.total_math_score)
all.equal(rowSums(select(dat,starts_with("correct.06_"))),dat$mid.total_math_score)


datLongPre <- dat%>%
    select(student_number,starts_with("correct.01_"))%>%
    pivot_longer(cols=-student_number,names_to='prob',values_to='pre',names_prefix='correct.01_')%>%
    mutate(prob=substr(prob,1,2))

datLongMid <- dat%>%
    select(student_number,starts_with("correct.06_"))%>%
    pivot_longer(cols=-student_number,names_to='prob',values_to='mid',names_prefix='correct.06_')%>%
    mutate(prob=substr(prob,1,2))

datLong <-
    dat%>%
    select(student_number,condition,ScaleScore,EIP,ESOL,IEP,FEMALE,GIFTED,race)%>%
    right_join(datLongPre,by='student_number')%>%
    full_join(datLongMid,by=c('student_number','prob'))

### is there item-level missingness?
datLong%>%
    group_by(student_number)%>%
    summarize(preNA=mean(is.na(pre)),midNA=mean(is.na(mid)))%>%
    ungroup()%>%
    distinct(preNA,midNA)
## no

mean(is.na(dat0$mid.total_math_score))
mean(is.na(datLong$mid))
mean(is.na(dat0$pre.total_math_score))
mean(is.na(datLong$pre)

datLong%>%









