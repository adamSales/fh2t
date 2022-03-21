library(tidyverse)
library(RItools)
source("code/functions.r")
Scale <- function(x) (x-mean(x,na.rm=TRUE))/sd(x,na.rm=TRUE)

inperson=FALSE
virtn=c(fhtt=249,db=110,IF=125,ac=120)
virtN=c(fhtt=611-2,db=308-1,IF=308-1,ac=307-1) ### these numbers came from my
### dataset (3/19/22) but my Ns were off by +10 for FH2T and by +3 or +4 for
### other conditions. So I assume my "virtual" numbers are too high, too and
### subtract 2 or 1 from each number, since about 1/3 of students were virtual
### I need to replace this with correct numbers

## overall and differential rates using numbers from the manuscript
## (I don't have the final dataset)
Ncond=c(fhtt=1430,db=720,IF=722,ac=719)
if(inperson) Ncond=Ncond-virtN
N=sum(Ncond)

ncond=c(fhtt=753,db=349,IF=381,ac=366)
if(inperson) ncond=ncond-virtn
n=sum(ncond)

attCond=1-ncond/Ncond

diffAtt=outer(attCond,attCond,"-")%>%abs()
overallPair=diffAtt
for(cc in names(ncond))
  for(dd in names(ncond))
    overallPair[cc,dd]=1-(ncond[cc]+ncond[dd])/(Ncond[cc]+Ncond[dd])

## plot
condNames=c(fhtt='FH2T',db='DragonBox',IF='Immediate Feedback',ac='Active Control')
wwc <- read.csv("attritionReports/wwc.csv")
names(wwc)[1] <- "Overall"

with(wwc,
  plot(Overall,Differential1,type="l",ylim=c(0,11),
       main="WWC Attrition Standards",
       xlab="Overall Attrition", ylab="Differential Attrition"))
  polygon(c(0,0,65,65),c(0,11,11,0),col="red")
  polygon(c(0,wwc[[1]],65),c(0,wwc$Differential1,0),col="yellow")
  polygon(c(0,wwc[[1]]),c(0,wwc$Differential0),col="green")

for(i in 1:3)
  for(j in (i+1):4){
    ov=overallPair[i,j]*100
    diff=diffAtt[i,j]*100
    points(ov,diff,pch=16)
    text(ov,diff,
         paste(condNames[i],'vs',condNames[j]),pos=2)
  }

##Position text by hand
text(
  overallPair['fhtt','db']*100,
  diffAtt['fhtt','db']*100-0.1,
  paste(condNames['fhtt'],'vs.',condNames['db']),
  pos=2)
text(
  overallPair['db','IF']*100,
  diffAtt['IF','db']*100+0.15,
  paste(condNames['IF'],'vs.',condNames['db']),
  pos=2)

text(
  overallPair['db','ac']*100,
  diffAtt['db','ac']*100+0.1,
  paste(condNames['db'],'vs.',condNames['ac']),
  pos=2)
text(
  overallPair['IF','ac']*100,
  diffAtt['IF','ac']*100+0.15,
  paste(condNames['IF'],'vs.',condNames['ac']),
  pos=2)
text(
  overallPair['fhtt','ac']*100,
  diffAtt['fhtt','ac']*100-0.15,
  paste(condNames['fhtt'],'vs.',condNames['ac']),
  pos=2)

text(
  overallPair['fhtt','IF']*100,
  diffAtt['fhtt','IF']*100+0.15,
  paste(condNames['fhtt'],'vs.',condNames['IF']),
  pos=2)



#### testing differential attrition
prop.test(ncond,Ncond)
prop.test(ncond[c(2,3)],Ncond[c(2,3)])


### testing covariate balance
### need full data

### best I got
load('data/analysisSample.RData')

if(inperson) dat<- subset(dat,virtual==0)

dat$Z <- relevel(factor(dat$Z),ref='BAU')

covNames <-
    c("pretest","race","FEMALE","EIP","IEP","GIFTED","virtual","accelerated") ## more?

dat <- dat%>%
    mutate(
        race=raceEthnicityFed%>%
               factor()%>%
               fct_lump(n=2)%>%
               fct_recode(Asian="3",White="6")%>%
            fct_relevel("White"),
      ScaleScore5 = Scale(`Scale.Score5`),
      accelerated=grepl('Accelerated',courseName),
      pretest = pre.total_math_score-round(mean(pre.total_math_score,na.rm=TRUE))
    )

### balance plot:
dat%>%
    filter(hasPosttest)%>%
    mutate(race=substr(as.character(race),1,1))%>%
  balPlot(covNames,trtVar="Z",data=.)


tests <- map_dfr(covNames,~balTestOne(dat[[.]],dat$Z,dat$class))
tests <- tests[,sapply(tests,function(x) all(!is.na(x)))]
tests$p.adj <- p.adjust(tests$p.value,method="fdr")
tests$covariate <- covNames
tests%>%
  select(covariate,method,statistic,p.value,p.adj)%>%
  knitr::kable()

covForm <- as.formula(paste("~",paste(covNames,collapse="+")))
totForm <- update(covForm,Z~.)
bals <- xbalMult(totForm,dat,trtLevs=unique(dat$Z),strata=list(noBlocks=NULL,cls=~class),na.rm=TRUE)

overall <- map_dfr(grep('BAU',names(bals),value=TRUE),~c(contrast=.,bals[[.]]$overall['cls',]))
print(overall)

pretestImbalance=map_dfr(grep('BAU',names(bals),value=TRUE),~c(contrast=.,round(bals[[.]]$results['pretest',,'cls'],3)))
pretestImbalance

##### standardized differences following WWC procedures 4.1 chp VI p. 15
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
for(cond in levels(dat$Z)[-1]){
  diffDat=
    dat%>%
    filter(Z%in%c(cond,'BAU'))%>%
    mutate(Z=Z==cond)%>%
    select(all_of(covNames),Z)
  diffs=map_dbl(setdiff(covNames,c('pretest','race'))%>%setNames(.,.),
                ~dCox(diffDat[[.]],diffDat$Z))
  for(r in levels(diffDat$race)[-1]){
    diffs=c(diffs,dCox(diffDat$race==r,diffDat$Z))
    names(diffs)[length(diffs)] <- r
  }
  diffs=c(diffs,pretest=hedgesG(diffDat$pretest,diffDat$Z))
  stdDiffs[[cond]] <- diffs
}
diffs <- as.data.frame(stdDiffs)

diffsTab <- lapply(diffs,
                   function(x)
                     paste0(round(x,3),
                            ifelse(abs(x)>0.05,'*','')))%>%
  as.data.frame(,row.names=rownames(diffs))




### pretest using outcome model:
library(lme4)
library(lmerTest)
pretestMod=lmer(pretest~Z+(1|class)+(1|teach),data=dat)
summary(pretestMod)

pretestModIP=lmer(pretest~Z+(1|class)+(1|teach),data=dat,subset=virtual==0)

bySch=map(unique(dat$initial_school_id)%>%setNames(.,.),
              ~lmer(pretest~Z+(1|class)+(1|teach),data=dat,subset=initial_school_id==.))
map(bySch,summary)
l
