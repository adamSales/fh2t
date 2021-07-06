library(tidyverse)
library(readxl)
library(lme4)
library(mosaic)
library(rstanarm)

dat0 <- read_excel('data/ASSISTment_merge_2021_04_12_N=1,587_ver.02.xlsx')
dat <- read_csv('data/IES_assessment_final_2021_06_03_N=4284 - Sheet1.csv')
dat0$student_number <- gsub("\\.0",'',dat0$student_number)

dat <- filter(dat,student_number%in%dat0$student_number)%>%
    rename(condition=condition_assignment)

dat$race <- dat$student_raceEthnicityFed%>%
    factor()%>%
    fct_lump_min(200)%>%
    fct_recode(`Hispanic/Latino`="1",Asian="3",White="6")%>%
    fct_relevel('White') ## make White (the biggest category) the reference

### check that prob level sums to total
all.equal(rowSums(select(dat,starts_with("correct.01_"))),dat$pre.total_math_score)
all.equal(rowSums(select(dat,starts_with("correct.06_"))),dat$mid.total_math_score)


datLongPre <- smallDat%>%
    select(student_number,starts_with("correct.01_"))%>%
    pivot_longer(cols=-student_number,names_to='prob',values_to='pre',names_prefix='correct.01_')%>%
    mutate(prob=substr(prob,1,2))

datLongMid <- smallDat%>%
    select(student_number,starts_with("correct.06_"))%>%
    pivot_longer(cols=-student_number,names_to='prob',values_to='mid',names_prefix='correct.06_')%>%
    mutate(prob=substr(prob,1,2))

datLong <-
    smallDat%>%
    select(student_number,initial_teacher_class,condition,ScaleScore,EIP,ESOL,IEP,FEMALE,GIFTED,race,ScaleScoreMISS,ESOLMISS,raceMISS)%>%
    right_join(datLongPre,by='student_number')%>%
    full_join(datLongMid,by=c('student_number','prob'))


datLong%>%
    group_by(prob,condition)%>%
    summarize(gain=mean(mid)-mean(pre))%>%
    ggplot(aes(condition,gain,fill=condition))+
    geom_hline(yintercept=0)+
    geom_col()+
    facet_wrap(~prob)
ggsave('gainByProb.jpg')

mod0 <- glmer(mid~condition+pre+(1|student_number/initial_teacher_class)+(1|prob),data=datLong,family=binomial)
mod1 <- update(mod0,.~.+ScaleScore)
mod2 <- update(mod1,.~.-(1|prob)+(pre|prob))
an12 <- anova(mod1,mod2)
mod3 <- update(mod2,.~.-(pre|prob)+(pre+condition|prob))
an23 <- anova(mod1,mod2,mod3)
mod4 <- update(mod3,.~.-(pre+condition|prob)+(pre+ScaleScore+condition|prob))
an14 <- anova(mod1,mod2,mod3,mod4)

library(broom.mixed)
sepMods <- datLong%>%
    nest(-prob)%>%
    mutate(
        mod=map(data, ~glmer(mid~condition+pre+ScaleScore+(1|initial_teacher_class),data=.x,family=binomial)),
        mod=map(mod,~tidy(.)%>%filter(term=='conditionInstant'))
    )%>%
    unnest(mod)

library(estimatr)
sepOLS <-  datLong%>%
    nest(-prob)%>%
    mutate(
        mod=map(data, ~lm_robust(mid~condition+pre+ScaleScore,data=.x,fixed_effects=~initial_teacher_class)),
        mod=map(mod,~tidy(.)%>%filter(term=='conditionInstant'))
    )%>%
    unnest(mod)


re3 <- ranef(mod3,condVar=TRUE)
effByProb <- fixef(mod3)['conditionInstant']+re3$prob$condition
pv <- attr(re3$prob,'postVar')
seByProb <- sqrt(summary(mod3)$coef['conditionInstant',2]^2+pv[3,3,])

effs3 <- data.frame(item=rownames(re3$prob),effect=effByProb,seEff=seByProb)%>%
    mutate(signif=ifelse(effect-2*seEff>0,'Positive',ifelse(effect+2*seEff<0,'Negative','Undetermined')))

effs3%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',color='Year')
ggsave('effectByProblem.jpg')

re4 <- ranef(mod4,condVar=TRUE)
effByProb <- fixef(mod4)['conditionInstant']+re4$prob$condition
pv <- attr(re4$prob,'postVar')
seByProb <- sqrt(summary(mod4)$coef['conditionInstant',2]^2+pv[4,4,])

data.frame(item=rownames(re4$prob),effect=effByProb,seEff=seByProb)%>%
    mutate(signif=ifelse(effect-2*seEff>0,'Positive',ifelse(effect+2*seEff<0,'Negative','Undetermined')))%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',color='Year')
ggsave('effectByProblem4.jpg')


mod3a <- stan_glmer(mid ~ condition + pre  + ScaleScore + (1 | student_number/initial_teacher_class) + (pre + condition | prob),
                   data=datLong,family=binomial(logit))
samp <- as.matrix(mod3a$stanfit)[,grep('condition',rownames(mod3a$stan_summary))]

effsStan <- samp[,rep('conditionInstant',10)]+samp[,paste0('b[conditionInstant prob:',rownames(re3$prob),']')]
colnames(effsStan) <- rownames(re3$prob)

effsStan2 <- apply(effsStan,2,function(x) c(effect=mean(x), seEff=sd(x),quantile(x,c(.025,.975))))%>%
    t()%>%
    as.data.frame()%>%
    rownames_to_column('item')

effStan2%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',color='Year')

diffs <- matrix(nrow=10,ncol=10)
for(i in 1:10) for(j in 1:10) diffs[i,j] <- mean(effsStan[,i]>effsStan[,j])
rownames(diffs) <- colnames(diffs) <- effsStan2$item

### is there item-level missingness?
datLong%>%
    group_by(student_number)%>%
    summarize(preNA=mean(is.na(pre)),midNA=mean(is.na(mid)))%>%
    ungroup()%>%
    distinct(preNA,midNA)
## no

mean(is.na(dat0$mid.total_math_score))
mean(is.na(datLong$mid))
mean(is.na(dat0$pre.total_math_score))
mean(is.na(datLong$pre)

datLong%>%









y <- mod3a$y  # matrix of "success" and "failure" counts
trials <- rowSums(y)
y_prop <- y[, 1] / trials  # proportions

# get predicted success proportions
yrep <- posterior_predict(mod3a)
yrep_prop <- sweep(yrep, 2, trials, "/")

ppc_error_binned(y, yrep[1:6, ])
