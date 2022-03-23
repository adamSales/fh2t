library(tidyverse)
library(RItools)
library(mosaic)
library(lme4)
source("code/functions.r")

library(tidyverse)
library(RItools)
library(mosaic)
library(lme4)
source("code/functions.r")

Scale <- function(x) (x-mean(x,na.rm=TRUE))/sd(x,na.rm=TRUE)

dat0 <- read_csv("data/DATA20220202_4092.csv",na = c("", "NA","#NULL!"))

### attrition variables
dat0 <- dat0%>%
  mutate(
    ScaleScore7 = Scale(Scale.Score7),
    hasPretest=is.finite(pre.total_math_score),
    hasPosttest=is.finite(post.total_math_score),
    Z =rdm_condition
  )%>%
  filter(!is.na(Z))%>%
  mutate(
    teach=ifelse(is.na(TeaIDPre),TeaIDEnd,TeaIDPre),
    class=ifelse(is.na(ClaIDPre),ClaIDEnd,ClaIDPre))




### sample size numbers

##"A total of 52 seventh-grade mathematics teachers and their students from 10 middle schools were recruited from a large, suburban district in the Southeastern United States in the summer of 2020. Together, these teachers taught 190 mathematics classrooms andA total of 4092 students, who were randomly assigned into four intervention conditions."

## teachers are weird cuz they have different ids in S11
## "190 mathematics classrooms"
n_distinct(dat0$class)
## "4092 students"
nrow(dat0)

###  "Students who were not enrolled in resource settings (n = 3972)"
sum(!endsWith(dat0$Z,'Resource'))

### "Students enrolled in resource settings (n = 120)"
sum(endsWith(dat0$Z,'Resource'))

### drop the resource students
dat1=filter(dat0,!endsWith(dat0$Z,'Resource'))

## drop the school that has no pretest scores
## which school?
noPre=dat1%>%
  group_by(SchIDPre)%>%
  summarize(pretest=mean(hasPretest))%>%
  filter(pretest<0.01)%>%
  pull(SchIDPre)

### Which teachers?
noPreTch=unique(dat1$TeaIDPre[dat1$SchIDPre==noPre])
## how many students?
sum(dat1$teach%in%noPreTch)

### this is different from the 381 in the paper
sum(dat1$DROPSCH1)
## here are the differences:
sch1Diffid=dat1$StuID[!dat1$teach%in%noPreTch & dat1$DROPSCH1==1]
## they all started elsewhere, but ended up in the dropped school:
dat1%>%filter(StuID%in%sch1Diffid)%>%xtabs(~SchIDPre+SchIDEnd,data=.)
### more info on them:
dat1%>%filter(StuID%in%sch1Diffid)%>%summarize(sum(virtual),sum(hasPretest),sum(hasPosttest))

#### anyway let's drop 'em (I've emailed Craig... we'll see what he says)
dat2 <- filter(dat1,DROPSCH1==0)


noPost=dat2%>%
  group_by(SchIDPre)%>%
  summarize(posttest=mean(hasPosttest))%>%
  filter(posttest<0.01)%>%
  pull(SchIDPre)

noPostTch=unique(dat1$TeaIDPre[dat1$SchIDPre==noPost])

### now there's only one discrepancy
sch2Diffid=dat2$StuID[!dat2$TeaIDPre%in%noPostTch&dat2$DROPSCH2==1]

## do they have a posttest score? 
dat2$hasPosttest[dat2$StuID==sch2Diffid]
### no. so it doesn't really matter does it?

dat3 <- dat2%>%filter(DROPSCH2==0)

sum(dat3$hasPretest) ## on target
sum(dat3$hasPretest & dat3$hasPosttest) ## ditto

dat <- filter(dat3,hasPretest&hasPosttest)




Scale <- function(x) (x-mean(x,na.rm=TRUE))/sd(x,na.rm=TRUE)

dat0 <- read_csv("data/Assessment_merged_2022_01_19_N=4,343 - Sheet1.csv")

### attrition variables
dat0 <- dat0%>%
    mutate(
        ScaleScore7 = Scale(Scale.Score_7th.grade),
        hasPretest=is.finite(pre.total_math_score),
        hasPosttest=is.finite(post.total_math_score),
        Z =rdm_condition
)%>%
filter(!is.na(Z))

### sample size numbers

##"A total of 52 seventh-grade mathematics teachers and their students from 10 middle schools were recruited from a large, suburban district in the Southeastern United States in the summer of 2020. Together, these teachers taught 190 mathematics classrooms andA total of 4092 students, who were randomly assigned into four intervention conditions."

## teachers are weird cuz they have different ids in S11
## "190 mathematics classrooms"
n_distinct(dat0$initial_teacher_class)
## "4092 students"
nrow(dat0)

###  "Students who were not enrolled in resource settings (n = 3972)"
sum(!endsWith(dat0$Z,'Resource'))

### "Students enrolled in resource settings (n = 120)"
sum(endsWith(dat0$Z,'Resource'))

### dropping two schools with (basically) no data
#### spoiler alert: this is S03 & S07. But I want to document it...

dat0%>%
    group_by(initial_school_id)%>%
    summarize(pretest=mean(hasPretest),
              posttest=mean(hasPosttest)
              )
### school S03 has no data at all
### school S07 has almost no posttest scores

### How many students in S03 and S07?
## S03:
sum(dat0$initial_school_id=='S03',na.rm=TRUE)
## S07:
sum(dat0$initial_school_id=='S07',na.rm=TRUE)


### there are teachers in the virtual schoool who are associated with S03 and S07
### they are listed in this dataset:
teachDrop <- read_csv('../data/IES_school_teacher_ID_list_opt_out - teacher (1).csv')

dat0$schoolSupp <- dat0$initial_school_id
dat0$schoolSupp[dat0$initial_teacher_id%in%teachDrop$teacher_id[teachDrop$note=='S03']] <- 'S03'
dat0$schoolSupp[dat0$initial_teacher_id%in%teachDrop$teacher_id[teachDrop$note=='S07']] <- 'S07'

dat0%>%
    group_by(schoolSupp)%>%
    summarize(pretest=mean(hasPretest),
              posttest=mean(hasPosttest)
              )

### NOW how many students in S03 and S07?
## S03:
sum(dat0$schoolSupp=='S03',na.rm=TRUE)
## S07:
sum(dat0$schoolSupp=='S07',na.rm=TRUE)

### " Therefore, the corresponding teachers (n = 7) and their students (n = 740) were removed from the study."

## all together:
with(dat0, sum(initial_school_id%in%c('S03','S07')|initial_teacher_id%in%teachDrop$teacher_id))
### [1] 718
## uh oh! missing 22 students to make up the 740!

dat1 <- subset(dat0,!schoolSupp%in%c('S03','S07'))

### This resulted in a sample of 3352 students across 160 classes and 45 teachers participating at the start of the interventions.
nrow(dat1)
## 3374 oops!
n_distinct(dat1$initial_teacher_class)
## 160 this one's right

### "Of these, 103 students were in a resource setting and were not included in this specific study"
sum(endsWith(dat1$Z,'Resource'))
## OK


### now drop the Resource kids:
dat2 <- dat1%>%
    filter(!endsWith(Z,'Resource'))

### "...resulting in a final pool of 3249 students across 143 classes and 34 teachers. "
nrow(dat2)
## 3271 still with the extra 22
n_distinct(dat2$initial_teacher_class)
### 143

###"Of these potential students, 2828 had a pretest assessment,..."
sum(dat2$hasPretest)
## 2841 extra 13 now getting better

### "... and of these 2828 students 1847 also had a posttest assessment. "
sum(dat2$hasPretest&dat2$hasPosttest)
### 1848 off by 1!!

dat3 <- filter(dat2,hasPretest&hasPosttest)

### "These students were enrolled in 127 classes with 34 teachers"
dat3%>%
    summarize(n(),n_distinct(initial_teacher_class))

table(dat3$Z)
## extra 1 dragonbox

dat3%>%
    group_by(Z)%>%
    summarize(preMean=mean(pre.total_math_score),preSD=sd(pre.total_math_score))

### one extra person
### who are they?
dat3%>%filter(Z=='Dragon')%>%group_by(student_raceEthnicityFed)%>%summarize(n=n())%>%arrange(n)
## white
dat3%>%filter(Z=='Dragon')%>%group_by(MALE)%>%summarize(n())
## hmmm we have missing genders WHAT DOES CRAIG KNOW??

dat3%>%filter(Z=='Dragon')%>%group_by(EIP)%>%summarize(n=n())%>%arrange(n)
## missing
dat3%>%filter(Z=='Dragon')%>%group_by(IEP)%>%summarize(n=n())%>%arrange(n)
## missing
dat3%>%filter(Z=='Dragon')%>%group_by(GIFTED)%>%summarize(n=n())%>%arrange(n)
## missing
dat3%>%filter(Z=='Dragon')%>%group_by(virtual)%>%summarize(n=n())%>%arrange(n)
## virtual!
dat3%>%filter(Z=='Dragon')%>%group_by(startsWith(courseName,'Accelerated'))%>%summarize(n=n())
## accelerated!

dat3%>%filter(Z=='Dragon',virtual==1,student_raceEthnicityFed==6,startsWith(courseName,'Accelerated'))%>%pull(pre.total_math_score)%>%sort()

## What is this student's pretest score?
## craig's mean for dragonbox: 4.95
ss <- sum(dat3$pre.total_math_score[dat3$Z=='Dragon'])
nn <- sum(dat3$Z=='Dragon')

## with my data:
ss/nn

## dropping one student, by pretest score:
sapply(setNames(1:10,1:10),function(x) round((ss-x)/(nn-1),2))

## so they got 8,9, or 10

## can we tell by SD?
## craig's SD: 2.60
## my sd:
sd(dat3$pre.total_math_score[dat3$Z=='Dragon'])
## also 2.60

scores <- dat3$pre.total_math_score[dat3$Z=='Dragon']
sapply(8:10,function(x) round(sd(scores[-(which(scores==x)[1])]),2))
## 8 or 9

dat3%>%filter(Z=='Dragon',virtual==1,student_raceEthnicityFed==6,pre.total_math_score%in%c(8,9))%>%pull(student_id)

### replicate model 1 (leaving in the extra student):
dat3$Z <- factor(dat3$Z)
dat3$Z <- relevel(dat3$Z,ref='BAU')

### use final teacher/class id to impute missing initial teacher/class id
dat3 <- mutate(dat3,
               teach=ifelse(is.na(initial_teacher_id),final_teacher_id,initial_teacher_id),
               class=ifelse(is.na(initial_teacher_class),final_teacher_class,initial_teacher_class))

mod1 <- lmer(post.total_math_score~Z+(1|initial_school_id/teach/class),data=dat3)
