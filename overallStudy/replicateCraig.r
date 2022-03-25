library(tidyverse)
library(RItools)
library(mosaic)
library(lme4)
library(texreg)
source("code/functions.r")


Scale <- function(x) (x-mean(x,na.rm=TRUE))/sd(x,na.rm=TRUE)

dat0 <- read_csv("data/DATA20220202_4092.csv",na = c("", "NA","#NULL!"))

### attrition variables
dat0 <- dat0%>%
  mutate(
    ScaleScore7 = Scale(Scale.Score7),
    hasPretest=is.finite(pre.total_math_score),
    hasPosttest=is.finite(post.total_math_score),
    Z =relevel(factor(rdm_condition),ref='BAU')
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
dat1=filter(dat0,!endsWith(as.character(Z),'Resource'))

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

## did they do anything?
dat1%>%filter(StuID%in%sch1Diffid &!hasPretest)%>%select(fidelity_started_sum:complete_assignment_11)%>%as.data.frame()



#### anyway let's drop 'em (I've emailed Craig... we'll see what he says)
##dat2 <- filter(dat1,DROPSCH1==0)

### update: we are keeping them in (as we should)
dat2 <- dat1%>%filter(!teach%in%noPreTch)

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

#################
## replicating HLMs
##################
library(lmerTest)
library(lme4)

dat$post=dat$post.total_math_score
dat$pre=dat$pre.total_math_score
dat$accelerated=grepl('Accelerated',dat$courseName)
dat$race <- dat$raceEthnicityFed%>%
  factor()%>%
  fct_lump(n=2)%>%
  fct_recode(Asian="3",White="6")%>%
  fct_relevel("White")

dat$ncomp=rowSums(dat[,startsWith(names(dat),'complete_assignment')])
dat$percomp=dat$ncomp/9
#dat$percomp=dat$percomp-mean(dat$percomp)

#dat$pre=dat$pre-mean(dat$pre)
center=function(x) scale(x,center=TRUE,scale=FALSE)
mod1=lmer(post~Z+(1|class)+(1|teach),data=dat)
mod2=update(mod1,.~.+center(pre)+race+MALE+GIFTED+accelerated+EIP+IEP)
mod2a=update(mod2,.~.+virtual)
mod3=update(mod2a,.~.+center(percomp))
mod4a=update(mod2a,.~.+Z:center(pre))
mod4=update(mod4a,.~.+center(percomp))

htmlreg(list(mod1,mod2,mod3,mod4),file = "tableZZ4.html",ci.force = TRUE,
        reorder.coef=c(1,4,3,2,5:14,17,16,15),digits=3)

list(mod1,mod2,mod3,mod4)%>%
  map(~update(.,subset=DROPSCH1==0))%>%
  htmlreg(file="tableZZ4orig.html",ci.force=TRUE,single.row=TRUE,
          reorder.coef=c(1,4,3,2,5:14,17,16,15),digits=3)

### table for in-person
list(mod1,mod2,mod3,mod4)%>%
  map(~update(.,subset=virtual==0))%>%
  htmlreg(file="tableZZ4inPerson.html",ci.force=TRUE,single.row=TRUE,
          reorder.coef=c(1,4,3,2,5:13,16,15,14),digits=3)


htmlreg(list(mod1,mod2a,mod4a),file = "tableZZ4pretreat.html",ci.force = TRUE)
