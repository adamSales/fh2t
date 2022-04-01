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
  mutate(
    ScaleScore7 = Scale(Scale.Score7),
    hasStatetest=is.finite(ScaleScore7),
    hasPretest=is.finite(pre.total_math_score),
    hasMidtest=is.finite(mid.total_math_score),
    hasPosttest=is.finite(post.total_math_score),
    Z =relevel(factor(rdm_condition),ref='BAU')
  )%>%
  filter(!is.na(Z),Z%in%c('ASSISTments','BAU'))%>%
  mutate(
    teach=ifelse(is.na(TeaIDPre),TeaIDEnd,TeaIDPre),
    class=ifelse(is.na(ClaIDPre),ClaIDEnd,ClaIDPre))


## drop the school that has no pretest scores
## which school?
noPre=dat1%>%
  group_by(SchIDPre)%>%
  summarize(pretest=mean(hasPretest))%>%
  filter(pretest<0.01)%>%
  pull(SchIDPre)

### Which teachers?
noPreTch=unique(dat1$TeaIDPre[dat1$SchIDPre==noPre])

### update: we are keeping them in (as we should)
dat2 <- dat1%>%filter(!teach%in%noPreTch)

noPost=dat2%>%
  group_by(SchIDPre)%>%
  summarize(posttest=mean(hasPosttest))%>%
  filter(posttest<0.01)%>%
  pull(SchIDPre)

noPostTch=unique(dat1$TeaIDPre[dat1$SchIDPre==noPost])

dat3=dat2%>%filter(!teach%in%noPostTch)

dat4=dat3%>%filter(hasPretest)

dat=filter(dat4,hasMidtest|hasPosttest|hasStatetest)


save(dat,file='data/feedbackData.RData')
