library(tidyverse)
library(RItools)
library(mosaic)
library(lme4)
library(texreg)
source("code/functions.r")


Scale <- function(x) (x-mean(x,na.rm=TRUE))/sd(x,na.rm=TRUE)

dat0 <- read_csv("data/DATA20220202_4092.csv",na = c("", "NA","#NULL!"))

### attrition variables
dat1 <- dat0%>%
  filter(!is.na(rdm_condition),rdm_condition%in%c('ASSISTments','BAU'))%>%
  mutate(
    ScaleScore7 = Scale(Scale.Score7),
    hasStatetest=is.finite(ScaleScore7),
    hasPretest=is.finite(pre.total_math_score),
    #hasMidtest=is.finite(mid.total_math_score),
    hasPosttest=is.finite(post.total_math_score),
    hasBoth=hasStatetest&hasPosttest,
    Z =fct_recode(factor(rdm_condition),Delayed="BAU",Immediate="ASSISTments"),
    race=raceEthnicityFed%>%
               factor()%>%
               fct_lump_min(100)%>%
               fct_recode(`Hispanic/Latino`="1",Asian="3",White="6")%>%
               fct_relevel('White'),
    pretestC = pre.total_math_score-round(mean(pre.total_math_score,na.rm=TRUE)),
    `Race/Ethnicity`=factor(raceEthnicityFed)%>%
      fct_recode(
        `Hispanic/Latino`="1",
        `American Indian/Alaska Native`="2",
        Asian="3",
        `Black/African American`="4",
        `Native Hawaiian or Other Pacific islander`="5",
        White="6",
        `Two or more races`="7")%>%
      fct_explicit_na("Unknown"),
    Gender=factor(ifelse(FEMALE==1,'Female','Male'))%>%fct_explicit_na("Unknown"),
    teach=ifelse(is.na(TeaIDPre),TeaIDEnd,TeaIDPre),
    class=ifelse(is.na(ClaIDPre),ClaIDEnd,ClaIDPre))%>%
  group_by(class)%>%
  mutate(ScaleScore5imp=ifelse(is.na(Scale.Score5),mean(Scale.Score5,na.rm=TRUE),Scale.Score5))%>%
  ungroup()


## ## drop the school that has no pretest scores
## ## which school?
## noPre=dat1%>%
##   group_by(SchIDPre)%>%
##   summarize(pretest=mean(hasPretest))%>%
##   filter(pretest<0.01)%>%
##   pull(SchIDPre)

## ### Which teachers?
## noPreTch=unique(dat1$TeaIDPre[dat1$SchIDPre==noPre])

## ### update: we are keeping them in (as we should)
## dat2 <- dat1%>%filter(!teach%in%noPreTch)

### keep the same students as impact paper
dat2 <- filter(dat1,DROPSCH1==0)

noPost=dat2%>%
  group_by(SchIDPre)%>%
  summarize(posttest=mean(hasPosttest))%>%
  filter(posttest<0.01)%>%
  pull(SchIDPre)

noPostTch=unique(dat1$TeaIDPre[dat1$SchIDPre==noPost])

dat3=dat2%>%filter(!teach%in%noPostTch)

dat4=dat3%>%filter(hasPretest)

dat=filter(dat4,hasPosttest|hasStatetest)

attr(dat,'nRandomized') <- table(dat2$Z)

save(dat,file='data/feedbackData.RData')
