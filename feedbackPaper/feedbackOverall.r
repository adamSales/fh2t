library(tidyverse)
library(RItools)
library(mosaic)
library(lme4)
library(texreg)
library(table1)
library(xtable)
library(lmtest)

source("code/functions.r")


load('data/feedbackData.RData')


### sample sizes
s=data.frame(
  test=c('post','state','both','total'),
  n=c(
    sapply(select(dat,hasPosttest,hasStatetest,hasBothtest),sum),
    with(dat, sum(hasPosttest|hasStatetest)))
  )




## ### plot % observed
## dat%>%
##   bind_rows(mutate(dat,Z='All'))%>%
##   group_by(Z)%>%
##   summarize(across(starts_with('has'),mean))%>%
##   select(-hasPretest)%>%
##   pivot_longer(-Z,names_to='Outcome',names_prefix='has',values_to="perObs")%>%
##   ungroup()%>%
##   ggplot(aes(Outcome,perObs,color=Z,group=Z))+geom_point()+geom_line()

### plot overall & differential attrition vs WWC standards


#### covariate balance
covNames <-
    c("pretestC","ScaleScore5imp","race","MALE","EIP","ESOL","IEP","GIFTED","accelerated") ## more?

dat%>%
    filter(hasPosttest)%>%
    mutate(race=substr(as.character(race),1,1))%>%
  balPlot(covNames,trtVar="Z",data=.,top="Posttest Sample")

dat%>%
    filter(hasStatetest)%>%
    mutate(race=substr(as.character(race),1,1))%>%
  balPlot(covNames,trtVar="Z",data=.,top="State Test Sample")

dat%>%
    filter(hasBothtest)%>%
    mutate(race=substr(as.character(race),1,1))%>%
  balPlot(covNames,trtVar="Z",data=.,top="Intersection Sample")


covForm <- as.formula(paste("I(Z=='Immediate')~",paste(covNames,collapse="+")))


bals <-
  map(c('Post','State','Both')%>%setNames(.,.),
      function(test)
        xBalance(covForm,
                 data=dat[dat[[paste0('has',test,'test')]],],
                 report=c('std.diffs','z.scores','chisquare.test'),
                 strata=list(cls=~class)))

###################
### estimating imbalance as suggested in WWC document
dCox=function(x,z){
  pi=mean(x[z],na.rm=TRUE)
  pc=mean(x[!z],na.rm=TRUE)
  (qlogis(pi)-qlogis(pc))/1.65
}

hedgesG=function(x,z){
  yi=mean(x[z],na.rm=TRUE)
  yc=mean(x[!z],na.rm=TRUE)
  ni=sum(!is.na(x[z]))
  nc=sum(!is.na(x[!z]))
  N=ni+nc
  omega=1-3/(4*N-9)
  omega*(yi-yc)/sqrt(((ni-1)*var(x[z])+(nc-1)*var(x[!z]))/(N-2))
}

stdDiffs=list()
for(test in c('Post','State','Both')){
  subst=paste0('has',test,'test')
  diffDat=
    dat[dat[[subst]],]%>%
    mutate(Znum=Z=='Immediate')%>%
    select(all_of(covNames),Znum)

  diffs=map_dbl(setdiff(covNames,c('pretestC','race','ScaleScore5imp'))%>%setNames(.,.),
                ~dCox(diffDat[[.]],diffDat$Znum))

  for(r in levels(diffDat$race)[-1]){
    diffs=c(diffs,dCox(diffDat$race==r,diffDat$Znum))
    names(diffs)[length(diffs)] <- r
  }

  diffs=c(diffs,pretest=hedgesG(diffDat$pretestC,diffDat$Znum))

  stdDiffs[[test]] <- diffs
}
diffs <- as.data.frame(stdDiffs)

lapply(diffs,
       function(x)
         paste0(round(x,3),
                ifelse(abs(x)>0.05,'*','')))%>%
  as.data.frame(row.names=rownames(diffs))%>%
  knitr::kable(caption="Table 5: Cox indices (for binary or categorical covariates) and Hedges's g (for numeric covariates) comparing baseline covariate means between each of the experimental conditions and the Active Control (positive differences indicate higher means for the experimental conditions, compared to Active Control). Stars indicate effect sizes >0.05, for which WWC recommends statistical adjustment",
        digits=3)


diffs%>%rownames_to_column('covr')%>%pivot_longer(-covr,names_to = "Subset",values_to = "Effect Size")%>%mutate(covr=ifelse(covr%in%c('Asian','Other'),paste('race:',covr),covr))%>%ggplot(aes(`Effect Size`,covr,color=Subset))+geom_point()+geom_vline(xintercept=0)+geom_vline(xintercept=c(-0.05,0.05),linetype='dashed')+ylab(NULL)


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

### overall p-values
sapply(bals,function(x) x$overall)


###########################################
####### Table 1
###########################################
tab1=map(c('Post','State','Both'),
         function(test){
           t1=table1(~Gender+`Race/Ethnicity`+accelerated+as.logical(EIP)+
                       as.logical(GIFTED)+as.logical(IEP)+as.logical(virtual)|Z,
                     data=dat[dat[[paste0('has',test,'test')]],])%>%
             as.data.frame()
           names(t1)[1]='varb'
           t1$varb=gsub("  |as.logical\\(|\\)","",t1$varb)
           t1=subset(t1,varb!='No')
           drop=NULL
           for(i in 1:nrow(t1))
             if(t1$varb[i]=='Yes'){
               t1$varb[i]=t1$varb[i-1]
               drop=c(drop,i-1)
             }
           t1=t1[-drop,-4]
           if(test!="Post") t1=t1[,-1]
           t1
         })
tab1=do.call("cbind",tab1)

print(xtable(tab1),type='html',file='table1.html',include.rownames=FALSE)


                                        #%>%
 # reduce(bind_cols)


#### estimate effects


### posttest
##
post0=lm(postS~Z+as.factor(class),data=dat,subset=hasPosttest)

post1=lm(postS~Z+ScaleScore5imp+pretestC+as.factor(class),data=dat,subset=hasPosttest)
post2=lm(postS~Z+ScaleScore5imp+pretestC+MALE+race+EIP+ESOL+IEP+GIFTED+accelerated+ScaleScore5miss+as.factor(class),data=dat,subset=hasPosttest)
screenreg(list(post0,post1,post2))
postInt=lm(postS~Z*pretestC+ScaleScore5imp+as.factor(class),data=dat,subset=hasPosttest)
screenreg(list(post0,post1,post2,postInt))

post0b=update(post0,subset=hasBothtest)
post2b=update(post2,subset=hasBothtest)

### state test
state0=lm(ScaleScore7~Z+as.factor(class),data=dat,subset=hasStatetest)
state1=lm(ScaleScore7~Z+ScaleScore5imp+pretestC+as.factor(class),data=dat,subset=hasStatetest)
state2=lm(ScaleScore7~Z+ScaleScore5imp+pretestC+MALE+race+EIP+ESOL+IEP+GIFTED+accelerated+ScaleScore5miss+as.factor(class),data=dat,subset=hasStatetest)
screenreg(list(state0,state1,state2))
stateImp=lm(ScaleScore7~Z*pretestC+ScaleScore5imp+as.factor(class),data=dat,subset=hasStatetest)
screenreg(list(state0,state1,state2,stateImp))

state0b=update(state0,subset=hasBothtest)
state2b=update(state2,subset=hasBothtest)

list(post0,post2,post0b,post2b,state0,state2,state0b,state2b)%>%
  map(coeftest,vcov.=vcovHC,type='HC')%>%
  stargazer(out="rq12.doc",ci=FALSE,single.row=FALSE,omit="as.factor\\(class\\)",
            type='html',digits=3,star.cutoffs=c(.05,0.01,0.001),intercept.bottom=FALSE)

### estimates
list(post0,post2,post0b,post2b,state0,state2,state0b,state2b)%>%
  map(coeftest,vcov.=vcovHC,type='HC')%>%
  map(function(x) round(x['ZImmediate',],3))


### CIs
list(post0,post2,post0b,post2b,state0,state2,state0b,state2b)%>%
  map(coefci,"ZImmediate",vcov.=vcovHC,type='HC')%>%
  map(round, digits=3)


## #### mlm


## datLong=dat%>%
##   pivot_longer(
##     c(mid,post,ScaleScore7),names_to="test",values_to="score")

## gmod1=lmer(score~Z*test+ScaleScore5imp+pretestC+FEMALE+race+EIP+ESOL+IEP+GIFTED+AbsentDays5+MOBILE5+
##              class+
##              (1|student_number),
##               data=datLong)
## VarCorr(gmod1)
## summary(gmod1)$coef[!startsWith(names(fixef(gmod1)),'class'),]
## ### estimates by time point
## ### lazy: just rerun model after changing ref
## gmod1a=update(gmod1,data=mutate(datLong,test=fct_relevel(test,'post')))
## summary(gmod1a)$coef['ZImmediate',]

## gmod1b=update(gmod1,data=mutate(datLong,test=fct_relevel(test,'ScaleScore7')))
## summary(gmod1b)$coef['ZImmediate',]

## gmod2=update(gmod1,.~.-(1|student_number)+(test|student_number))
