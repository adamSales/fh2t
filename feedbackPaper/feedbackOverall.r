library(tidyverse)
library(RItools)
library(mosaic)
library(lme4)
library(estimatr)
library(texreg)


source("code/functions.r")

Scale <- function(x) (x-mean(x,na.rm=TRUE))/sd(x,na.rm=TRUE)

load('data/feedbackData.RData')


### sample sizes
ns=data.frame(
  test=c('post','state','both','total'),
  n=c(
    sapply(select(dat,hasPosttest,hasStatetest,hasBoth),sum),
    with(dat, sum(hasPosttest|hasStatetest)))
  )


### attrition analysis
att=rbind(
  cbind(
    post=1-mean(~hasPosttest|Z,data=dat),
    state=1-mean(~hasStatetest|Z,data=dat),
   both=1-mean(~hasBoth|Z,data=dat)),
  all=1-sapply(select(dat,hasPosttest,hasStatetest,hasBoth),mean))


### plot % observed
dat%>%
  bind_rows(mutate(dat,Z='All'))%>%
  group_by(Z)%>%
  summarize(across(starts_with('has'),mean))%>%
  select(-hasPretest)%>%
  pivot_longer(-Z,names_to='Outcome',names_prefix='has',values_to="perObs")%>%
  ungroup()%>%
  ggplot(aes(Outcome,perObs,color=Z,group=Z))+geom_point()+geom_line()

### plot overall & differential attrition vs WWC standards
plotWWC(ov=att['all',],diff=apply(att,2,function(x) x['ASSISTments']-x['BAU']),
        labs=colnames(att))


#### covariate balance
covNames <-
    c("pretest","ScaleScore5","race","FEMALE","EIP","ESOL","IEP","GIFTED") ## more?




covForm <- as.formula(paste("I(Z=='ASSISTments')~",paste(covNames,collapse="+")))


### midtest
bals <-
  map(c('Mid','Post','State')%>%setNames(.,.),
      function(test)
        xBalance(covForm,
                 data=dat[dat[[paste0('has',test,'test')]],],
                 report=c('std.diffs','z.scores','chisquare.test'),
                 strata=list(cls=~class)))

map_dfr(names(bals),
        function(nn)
          as.data.frame(RItools:::prepareXbalForPlot(bals[[nn]]))%>%
          rownames_to_column()%>%
          mutate(test=nn))%>%
  ggplot(aes(y = rowname, x = cls)) +
  geom_vline(xintercept = 0) +
  geom_vline(xintercept=c(-.25,-.05,.25,.05),linetype='dotted')+
  geom_point() +
  theme(legend.position = "bottom")+
  facet_wrap(~test,nrow=1)+theme_bw()+xlab("Standardized Difference")+ylab(NULL)

### which variables are imbalanced with |stand. diff|>0.05?
bals%>%
  map(~rownames(.$results)[abs(.$results[,'std.diff',1])>0.05])%>%
  unlist()%>%unique()

#### estimate effects
dat$post=Scale(dat$post.total_math_score)
dat$mid=Scale(dat$mid.total_math_score)

### midtest
mid0=lm_robust(mid~Z,data=dat,subset=hasMidtest,fixed_effects=~class)
mid1=lm_robust(mid~Z+ScaleScore5imp+pretest,data=dat,subset=hasMidtest,fixed_effects=~class)
mid2=lm_robust(mid~Z+ScaleScore5imp+pretest+FEMALE+race+ESOL+IEP+GIFTED+AbsentDays5+MOBILE5,data=dat,subset=hasMidtest,fixed_effects=~class)
screenreg(list(mid0,mid1,mid2))
mid1=lm_robust(mid~Z*pretest+ScaleScore5imp,data=dat,subset=hasMidtest,fixed_effects=~class)


### posttest
post0=lm_robust(post~Z,data=dat,subset=hasPosttest,fixed_effects=~class)
post1=lm_robust(post~Z+ScaleScore5imp+pretest,data=dat,subset=hasPosttest,fixed_effects=~class)
post2=lm_robust(post~Z+ScaleScore5imp+pretest+FEMALE+race+EIP+ESOL+IEP+GIFTED+AbsentDays5+MOBILE5,data=dat,subset=hasPosttest,fixed_effects=~class)
screenreg(list(post0,post1,post2))
postInt=lm_robust(post~Z*pretest+ScaleScore5imp,data=dat,subset=hasPosttest,fixed_effects=~class)
screenreg(list(post0,post1,post2,postInt))


### state test
state0=lm_robust(ScaleScore7~Z,data=dat,subset=hasStatetest,fixed_effects=~class)
state1=lm_robust(ScaleScore7~Z+ScaleScore5imp+pretest,data=dat,subset=hasStatetest,fixed_effects=~class)
state2=lm_robust(ScaleScore7~Z+ScaleScore5imp+pretest+FEMALE+race+EIP+ESOL+IEP+GIFTED+AbsentDays5+MOBILE5,data=dat,subset=hasStatetest,fixed_effects=~class)
screenreg(list(state0,state1,state2))
stateImp=lm_robust(ScaleScore7~Z*pretest+ScaleScore5imp,data=dat,subset=hasStatetest,fixed_effects=~class)
screenreg(list(state0,state1,state2,stateImp))


#### mlm


datLong=dat%>%
  pivot_longer(
    c(mid,post,ScaleScore7),names_to="test",values_to="score")

gmod1=lmer(score~Z*test+ScaleScore5imp+pretest+FEMALE+race+EIP+ESOL+IEP+GIFTED+AbsentDays5+MOBILE5+
             class+
             (1|student_number),
              data=datLong)
VarCorr(gmod1)
summary(gmod1)$coef[!startsWith(names(fixef(gmod1)),'class'),]
### estimates by time point
### lazy: just rerun model after changing ref
gmod1a=update(gmod1,data=mutate(datLong,test=fct_relevel(test,'post')))
summary(gmod1a)$coef['ZASSISTments',]

gmod1b=update(gmod1,data=mutate(datLong,test=fct_relevel(test,'ScaleScore7')))
summary(gmod1b)$coef['ZASSISTments',]

gmod2=update(gmod1,.~.-(1|student_number)+(test|student_number))
