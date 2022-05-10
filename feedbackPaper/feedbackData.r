library(tidyverse)
library(RItools)
library(mosaic)
library(lme4)
library(texreg)
source("code/functions.r")


psd=function(y,z){
  z=z[!is.na(y)]
  y=y[!is.na(y)]
  z=as.numeric(z)
  n1=sum(z==1)
  n0=sum(z!=1)
  v1=var(y[z==1])
  v0=var(y[z!=1])
  sqrt(((n1-1)*v1+(n0-1)*v0)/(n1+n0-2))
}

Scale <- function(x,z=NULL){
  scl <- if(is.null(z)) sd(x,na.rm=TRUE) else psd(x,z)
  (x-mean(x,na.rm=TRUE))/scl
}

dat0 <- read_csv("data/DATA20220202_4092.csv",na = c("", "NA","#NULL!"))

### attrition variables
dat1 <- dat0%>%
  filter(!is.na(rdm_condition),rdm_condition%in%c('ASSISTments','BAU'))%>%
  mutate(
    Z =fct_recode(factor(rdm_condition),Delayed="BAU",Immediate="ASSISTments")%>%relevel('Delayed'),
    #ScaleScore7 = Scale(Scale.Score7,Z),
    #postS=Scale(post.total_math_score,Z),
    hasStatetest=is.finite(Scale.Score7),
    hasPretest=is.finite(pre.total_math_score),
    #hasMidtest=is.finite(mid.total_math_score),
    hasPosttest=is.finite(post.total_math_score),
    hasBothtest=hasStatetest&hasPosttest,
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
    accelerated=grepl('Accelerated',courseName),
    #Gender=factor(ifelse(FEMALE==1,'Female','Male'))%>%fct_explicit_na("Unknown"),
    teach=ifelse(is.na(TeaIDPre),TeaIDEnd,TeaIDPre),
    class=ifelse(is.na(ClaIDPre),ClaIDEnd,ClaIDPre),
    ScaleScore5imp=ifelse(is.na(Scale.Score5),mean(Scale.Score5,na.rm=TRUE),Scale.Score5),
    ScaleScore5miss=ifelse(is.na(Scale.Score5),1,0))


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


dat4=filter(dat3,hasPosttest|hasStatetest)

dat=dat4%>%filter(hasPretest)

dat=mutate(dat,
           ScaleScore7 = Scale(Scale.Score7,Z),
           postS=Scale(post.total_math_score,Z))

save(dat,file='data/feedbackData.RData')

#######################################
## attrition analysis
#######################################

### analysis sample vs n randomized
nRandomized=table(dat2$Z)
att=rbind(
  cbind(
    post=1-sum(~hasPosttest|Z,data=dat)/nRandomized,
    state=1-sum(~hasStatetest|Z,data=dat)/nRandomized,
   bothtest=1-sum(~hasBothtest|Z,data=dat)/nRandomized),
  all=1-sapply(select(dat,hasPosttest,hasStatetest,hasBothtest),sum)/sum(nRandomized))

pdf('feedbackPaper/plots/wwcPlot.pdf')
plotWWC(ov=att['all',],diff=apply(att,2,function(x) x['Immediate']-x['Delayed']),
        labs=colnames(att),main="Attrition for Delayed vs Immediate Feedback")
dev.off()


### incl NA pretest in numerator
### analysis sample vs n randomized
attWPre=rbind(
  cbind(
    post=1-sum(~hasPosttest|Z,data=dat4)/nRandomized,
    state=1-sum(~hasStatetest|Z,data=dat4)/nRandomized,
   bothtest=1-sum(~hasBothtest|Z,data=dat4)/nRandomized),
  all=1-sapply(select(dat4,hasPosttest,hasStatetest,hasBothtest),sum)/sum(nRandomized))


pdf('feedbackPaper/plots/wwcPlotInclPre.pdf')
plotWWC(ov=att['all',],diff=apply(att,2,function(x) x['Immediate']-x['Delayed']),
        labs=colnames(att))
dev.off()
