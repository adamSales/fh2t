
makeRmd <- function(test,inclPre=TRUE){
    varb <- paste0('has',test)
    cat('
---
title: "Attrition Analysis:',test,', ',ifelse(inclPre,'Including','Excluding'),' Pretest No-Shows"
output: html_document
---

```{r init, include=FALSE}
library(knitr)
opts_chunk$set(echo=FALSE,message=FALSE,warning=FALSE,error=FALSE,fig.width=9,fig.height=9,
  cache=FALSE)
```

```{r}
library(tidyverse)
library(RItools)
library(mosaic)
source("../code/functions.r")

Scale <- function(x) (x-mean(x,na.rm=TRUE))/sd(x,na.rm=TRUE)

dat <- read_csv("../data/Assessment_merged_2021_06_16_state_assessment_N=4311.csv")

### attrition variables
dat <- dat%>%
    mutate(
        ScaleScore7 = Scale(Scale.Score_7th.grade),
        hasPretest=is.finite(pre_MA_total_score),
        hasMidtest=is.finite(mid_MA_total_score),
        hasPosttest=is.finite(post_MA_total_score),
        hasDelayed=is.finite(delayed.total_math_score),
        hasStatetest=is.finite(ScaleScore7),
        Z =rdm_condition
)%>%
filter(!is.na(Z))
```

```{r}

dat <- dat%>%
    mutate(
        race=student_raceEthnicityFed%>%
               factor()%>%
               fct_lump_min(200)%>%
               fct_recode(`Hispanic/Latino`="1",Asian="3",White="6",Black="4")%>%
            fct_relevel("White"),
        ScaleScore5 = Scale(`ScaleScore_5th grade`),
        pretest = pre.total_math_score-round(mean(pre.total_math_score,na.rm=TRUE))
        )

covNames <-
    c("pretest","ScaleScore5","race","FEMALE","EIP","ESOL","IEP","GIFTED") ## more?
```

#Drop schools with <0.01 posttest scores (S03 & S07)
```{r}

dat$initial_school_id[is.na(dat$initial_school_id)] <- "SNA"

## drop schools where (almost) everyone dropped out (S03 & S07)
dat <- dat%>%
    group_by(initial_school_id)%>%
    mutate(postPer=mean(hasPosttest))%>%
    filter(postPer>0.01)%>%
    ungroup()%>%
    select(-postPer)
```
',
ifelse(inclPre,'','
Excluding students with no pretest scores.
```{r}
dat <- filter(dat,hasPretest)
```
'
),'
```
````
Non-Attrition rates by condition:
```{r}

```{r attritionRates}
dat%>%
    bind_rows(mutate(dat,Z="Overall"))%>%
    mutate(Z=factor(Z,levels=c("Overall",unique(dat$Z))))%>%
    group_by(Z)%>%
    summarize(n_assigned=n(),across(starts_with("has"),mean))%>%
    kable(digits=3)
```

```

Study sample:
Students with ',test,' scores, ',ifelse(inclPre,'including','excluding'),' those without pretest scores, and excluding students of teachers in S03 and S07 and students with NA condition assignment.

```{r}
dat%>%
  filter(',varb,')%>%
  mutate(N=n())%>%
  group_by(Z)%>%
  summarize(Total=N[1],n=n())%>%
  kable()
```

Overall and Differential Attrition vis a vis WWC Standards:
```{r}
## treatment levels
trtLevs <- unique(na.omit(dat$Z))
trtLevs <- trtLevs[!endsWith(trtLevs,"Resource")]
nlevs <- length(trtLevs)
ndiff <- nlevs*(nlevs-1)/2

wwc <- read.csv("wwc.csv")
names(wwc)[1] <- "Overall"


ov <- NULL
diff <- NULL
diffName <- NULL

for(i in 1:(nlevs-1))
  for(j in (i+1):nlevs){
    diffDat <- filter(dat,Z%in% trtLevs[c(i,j)])
    ov <- c(ov,1-mean(diffDat[["',varb,'"]]))
    diff <- c(diff,
               mean(subset(diffDat,Z==trtLevs[i])[["',varb,'"]])-
               mean(subset(diffDat,Z==trtLevs[j])[["',varb,'"]])
             )
             diffName <- c(diffName,paste(trtLevs[c(i,j)],collapse=" vs. "))
  }

with(wwc,
  plot(Overall,Differential1,type="l",ylim=c(0,11),
       main="',paste(test,ifelse(inclPre,'Including','Excluding'), 'Pretest No-Shows'),'",
                  xlab="Overall Attrition", ylab="Differential Attrition"))
  polygon(c(0,0,65,65),c(0,11,11,0),col="red")
  polygon(c(0,wwc[[1]],65),c(0,wwc$Differential1,0),col="yellow")
  polygon(c(0,wwc[[1]]),c(0,wwc$Differential0),col="green")

  ov <- ov*100
  diff <- abs(diff)*100

  points(ov,diff,pch=16)
  text(ov,diff,diffName,pos=2)

```


Balance plot:
```{r}
dat%>%
    filter(',varb,')%>%
    mutate(race=substr(as.character(race),1,1))%>%
    balPlot(covNames,trtVar="Z",data=.)
```

Balance tests:
```{r}
ddd <- dat%>%
    filter(',varb,',!is.na(Z), !endsWith(Z,"Resource"))

tests <- map_dfr(covNames,~balTestOne(ddd[[.]],ddd$Z,ddd$initial_teacher_class))
tests <- tests[,sapply(tests,function(x) all(!is.na(x)))]
tests$p.adj <- p.adjust(tests$p.value,method="fdr")
tests$covariate <- covNames
tests%>%
    select(covariate,method,statistic,p.value,p.adj)%>%
    kable()
```
xBalance version:
```{r}
covForm <- as.formula(paste("~",paste(covNames,collapse="+")))
totForm <- update(covForm,Z~.)

bals <- xbalMult(totForm,ddd,trtLevs=unique(ddd$Z)[!endsWith(unique(ddd$Z),"Resource")],strata=list(cls=~ddd$initial_teacher_class),na.rm=TRUE)
plotXbals(bals)

map_dfr(names(bals),~tibble(Comparison=.,Overall.p=bals[[.]]$overall[1,"p.value"]))%>%
    kable(digits=3)
```
',
file=paste0(test,'Attrition',ifelse(inclPre,'','ExclPre'),'.Rmd'),
sep='',append=FALSE
)
}




for(test in c('Midtest','Posttest','Delayed','Statetest')){
    makeRmd(test)
    knitr::knit(paste0(test,'Attrition.Rmd'))
    rmarkdown::render(paste0(test,'Attrition.md'))
}
