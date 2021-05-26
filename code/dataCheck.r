library(tidyverse)
library(readxl)
library(mosaic)
library(lme4)
library(RItools)
library(texreg)

dat <- read_excel('data/ASSISTment_merge_2021_04_12_N=1,587.xlsx')

### are students unique? what are their IDs?
## nrow(dat)
## sum(is.na(dat$student_number))
## n_distinct(dat$student_number)
## n_distinct(dat$student_id.x)
## all good

### look at random assignment
table(dat$initial_CONDITION)
table(dat$condition_updated)
xtabs(~initial_CONDITION+condition_updated,data=dat) ## same thing

n_distinct(dat$initial_school_id)
xtabs(~initial_school_id+initial_CONDITION,data=dat)
xtabs(~KEEP+condition_updated,data=dat,addNA=TRUE)  ## I only have KEEP rows. should I have all rows?

n_distinct(dat$initial_teacher)
xtabs(~initial_teacher+condition_updated,data=dat,addNA=TRUE)
xtabs(~initial_SectionNumber+condition_updated,data=dat,addNA=TRUE)
xtabs(~movement+condition_updated,data=dat,addNA=TRUE)%>%addmargins()

## are section numbers nested w/i teachers?
dat%>%group_by(initial_SectionNumber)%>%summarize(nt=n_distinct(initial_teacher))%>%xtabs(~nt,data=.)
## no!

## are teachers nested w/i section numbers?
dat%>%group_by(initial_teacher)%>%summarize(nt=n_distinct(initial_SectionNumber))%>%xtabs(~nt,data=.)
## no!

## are section numbers nested w/i schools?
dat%>%group_by(initial_SectionNumber)%>%summarize(nt=n_distinct(initial_school_id))%>%xtabs(~nt,data=.)
## mostly...

## are teachers nested w/i schools?
dat%>%group_by(initial_teacher)%>%summarize(nt=n_distinct(initial_school_id))%>%xtabs(~nt,data=.)
## partly

### missigness on mid test
sum(is.na(dat$mid.total_math_score))

tally(is.na(mid.total_math_score)~condition_updated,data=dat,format="percent")

### test covariate balance between responders and non-responders
dat$midMis <- is.na(dat$mid.total_math_score)
balMid <- xBalance(midMis~ScaleScore+PerformanceLevel+EIP+ESOL+IEP+FEMALE+GIFTED+student_hispanicEthnicity+student_raceEthnicityFed,data=dat,
                   report='all')

tally(is.na(mid.total_math_score)~is.na(pre.total_math_score),data=dat,format="percent")

mean(is.na(dat$pre.total_math_score))

mean(is.na(dat$mid.total_math_score[!is.na(dat$pre.total_math_score)]))

tally(midMis~condition_updated,data=filter(dat,!is.na(pre.total_math_score)),format="percent")

summary(glm(midMis~condition_updated*scale(pre.total_math_score),data=dat,family=binomial(probit)))
summary(glm(midMis~condition_updated*ScaleScore,data=dat,family=binomial(probit)))

mean(dat$midMis)
mean(dat$midMis[dat$condition_updated=='Instant'])-mean(dat$midMis[dat$condition_updated!='Instant'])
### meets optimistic WWC standard


### treatment effect estimates for mid test
library(estimatr)

dat$raceLump <- fct_lump_min(dat$student_raceEthnicityFed,200)

mod1 <- lm_robust(mid.total_math_score~condition_updated,data=dat)
mod2 <- lm_robust(mid.total_math_score~condition_updated,data=dat,fixed_effects=~initial_SectionNumber)
mod3 <- lm_robust(mid.total_math_score~condition_updated,data=dat,fixed_effects=~initial_teacher)
mod4 <- lm_robust(mid.total_math_score~condition_updated+pre.total_math_score,data=dat,fixed_effects=~initial_SectionNumber)
mod5 <- lm_robust(mid.total_math_score~condition_updated+pre.total_math_score+ScaleScore+EIP+ESOL+IEP+FEMALE+GIFTED+raceLump,data=dat)
mod6 <- lm_robust(mid.total_math_score~condition_updated+pre.total_math_score+ScaleScore+EIP+ESOL+IEP+FEMALE+GIFTED+raceLump,data=dat,fixed_effects=~initial_SectionNumber)

screenreg(list(mod1,mod2,mod3,mod4,mod5,mod6))



mod5a <- lm(mid.total_math_score~condition_updated+pre.total_math_score+ScaleScore+EIP+ESOL+IEP+FEMALE+GIFTED+raceLump,data=dat)
plot(mod5a)
summary(mod5a)

loopDat <- dat%>%filter(!is.na(mid.total_math_score))%>%
    transmute(Y=mid.total_math_score,
              Tr=ifelse(condition_updated=='Instant',1,0),
              across(c(pre.total_math_score,ScaleScore,EIP,ESOL,IEP,FEMALE,GIFTED),list(imp=~ifelse(is.na(.),median(.,na.rm=TRUE),.),mis=~is.na(.)))
              )


LOOP <- loop.estimator::loop(loopDat$Y,loopDat$Tr,as.matrix(loopDat[,-c(1:2)]))

plot(table(dat$mid.total_math_score))

gf_boxplot(mid.total_math_score~condition_updated,data=dat,outlier.shape=NA)+geom_jitter()

ggplot(dat,aes(mid.total_math_score))+geom_histogram(bins=10)+facet_wrap(~condition_updated,ncol=1)

ggplot(dat,aes(mid.total_math_score))+geom_bar()+facet_wrap(~condition_updated,ncol=1)+scale_x_continuous(breaks=0:10)

dat%>%group_by(condition_updated)%>%mutate(nt=sum(!is.na(mid.total_math_score)))%>%group_by(condition_updated,mid.total_math_score)%>%summarize(percent=n()/nt)%>%ggplot(aes(mid.total_math_score,percent,color=condition_updated,group=condition_updated))+geom_point()+geom_line()+scale_x_continuous(breaks=0:10)+scale_y_continuous(labels=scales::percent,limits=c(0,.15))

dat%>%group_by(condition_updated,mid.total_math_score)%>%summarize(n=n())%>%ggplot(aes(mid.total_math_score,n,color=condition_updated,group=condition_updated))+geom_point()+geom_line()+scale_x_continuous(breaks=0:10,minor_breaks=NULL)+scale_y_continuous(breaks=seq(0,60,10),minor_breaks=seq(0,60,5),limits=c(0,60))


wilcox.test(mid.total_math_score~condition_updated,data=dat)
