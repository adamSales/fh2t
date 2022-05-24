library(tidyverse)
library(readxl)
library(lme4)
library(rstanarm)
library(broom.mixed)
library(estimatr)
options(mc.cores = 6)

dat0 <- read_excel('../data/ASSISTment_merge_2021_04_12_N=1,587_ver.02.xlsx')
dat <- read_csv('../data/IES_assessment_final_2021_06_03_N=4284 - Sheet1.csv')
dat0$student_number <- gsub("\\.0",'',dat0$student_number)

dat <- filter(dat,student_number%in%dat0$student_number)%>%
    rename(condition=condition_assignment)

dat$race <- dat$student_raceEthnicityFed%>%
    factor()%>%
    fct_lump_min(200)%>%
    fct_recode(`Hispanic/Latino`="1",Asian="3",White="6")%>%
    fct_relevel('White') ## make White (the biggest category) the reference

dat$hasPretest=!is.na(dat$pre.total_math_score)
dat$hasMidtest=!is.na(dat$mid.total_math_score)
dat$hasPosttest=!is.na(dat$post.total_math_score)

### check that prob level sums to total
all.equal(rowSums(select(filter(dat,hasPretest),starts_with("correct.01_"))),dat$pre.total_math_score[dat$hasPretest])
all.equal(rowSums(select(filter(dat,hasMidtest),starts_with("correct.06_"))),dat$mid.total_math_score[dat$hasMidtest])
all.equal(rowSums(select(filter(dat,hasPosttest),starts_with("correct.12_"))),dat$post.total_math_score[dat$hasPosttest])

dat=dat[dat$hasPretest,]

### covariate mean imputation w missingness indicator
dat <- dat%>%
    mutate(across(c(ScaleScore,EIP,ESOL,IEP,FEMALE,GIFTED),
                  list(imp=~ifelse(is.na(.),mean(.,na.rm=TRUE),.),
                       mis=~ifelse(is.na(.),1,0))),
           race_imp=ifelse(is.na(race),"Other",race),
           race_mis=ifelse(is.na(race),1,0)
           )



### missingness patterns
dat%>%
    select(ends_with('mis'))%>%
    cor()%>%round(digits=2)

## what does rho=.96 mean
xtabs(~EIP_mis+ESOL_mis,data=dat)


datLongPre <- dat%>%
    select(student_number,starts_with("correct.01_"))%>%
    pivot_longer(cols=-student_number,names_to='prob',values_to='pre',names_prefix='correct.01_')%>%
    mutate(prob=substr(prob,1,2))

datLongMid <- dat%>%
    select(student_number,starts_with("correct.06_"))%>%
    pivot_longer(cols=-student_number,names_to='prob',values_to='mid',names_prefix='correct.06_')%>%
    mutate(prob=substr(prob,1,2))

datLongPost <- dat%>%
    select(student_number,starts_with("correct.12_"))%>%
    pivot_longer(cols=-student_number,names_to='prob',values_to='post',names_prefix='correct.12_')%>%
    mutate(prob=substr(prob,1,2))

datLong <-
    dat%>%
    select(student_number,initial_teacher_class,condition,
           ends_with("_imp"),ScaleScore_mis,race_mis,
           starts_with('has'),pre.total_math_score)%>%
    right_join(datLongPre,by='student_number')%>%
    full_join(datLongMid,by=c('student_number','prob'))%>%
    full_join(datLongPost,by=c('student_number','prob'))

save(datLong,file='../data/datLong.RData')


####################################################
######### descriptive plots
####################################################

gainByProbMid=datLong%>%
    group_by(prob,condition)%>%
    summarize(gain=mean(mid,na.rm=TRUE)-mean(pre))

gainByProbMid%>%
    ggplot(aes(condition,gain,fill=condition))+
    geom_hline(yintercept=0)+
    geom_col()+
    facet_wrap(~prob)
ggsave('gainByProbMid.jpg')

gainByProbPost=datLong%>%
    group_by(prob,condition)%>%
    summarize(gain=mean(post,na.rm=TRUE)-mean(pre,na.rm=TRUE))
gainByProbPost%>%
    ggplot(aes(condition,gain,fill=condition))+
    geom_hline(yintercept=0)+
    geom_col()+
    facet_wrap(~prob)
ggsave('gainByProbPost.jpg')


####################################################
#### glmer models
####################################################

getEffsMLE<-function(mod){
    re3 <- ranef(mod,condVar=TRUE)
    effByProb <- fixef(mod)['conditionInstant']+re3$prob$condition
    pv <- attr(re3$prob,'postVar')
    seByProb <- sqrt(summary(mod)$coef['conditionInstant',2]^2+pv[3,3,])

    data.frame(item=rownames(re3$prob),effect=effByProb,seEff=seByProb)%>%
        mutate(signif=ifelse(effect-2*seEff>0,'Positive',ifelse(effect+2*seEff<0,'Negative','Undetermined')))
}


#### midtest
mid0 <- glmer(mid~condition+pre+(1|student_number/initial_teacher_class)+(1|prob),data=datLong,subset=hasMidtest,family=binomial)
mid1 <- update(mid0,.~.+ScaleScore_imp)
mid2 <- update(mid1,.~.-(1|prob)+(pre|prob))
mid3 <- update(mid2,.~.-(pre|prob)+(pre+condition|prob))
mid4 <- update(mid3,.~.-(pre+condition|prob)+(pre+ScaleScore_imp+condition|prob))
midAnova <- anova(mid1,mid2,mid3,mid4)
midAnova
save(mid0,mid1,mid2,mid3,mid4,midAnova,file='lme4modsByProbMid.RData')

## estimate effects
effsMid=getEffsMLE(mid3)

effsMid%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',title="Effect of Immediate vs Delayed Feedback on Midtest Problems")
ggsave('effectByProblemMid.jpg')

#### posttest
post0 <- glmer(post~condition+pre+(1|student_number/initial_teacher_class)+(1|prob),data=datLong,subset=hasPosttest,family=binomial)
post1 <- update(post0,.~.+ScaleScore_imp)
post2 <- update(post1,.~.-(1|prob)+(pre|prob))
post3 <- update(post2,.~.-(pre|prob)+(pre+condition|prob))
post4 <- update(post3,.~.-(pre+condition|prob)+(pre+ScaleScore_imp+condition|prob))
postAnova <- anova(post1,post2,post3,post4)
postAnova
save(post0,post1,post2,post3,post4,postAnova,file='lme4modsByProbPost.RData')

### get effects
effsPost=getEffsMLE(post3)

effsPost%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',title="Effect of Immediate vs Delayed Feedback on Posttest Problems")
ggsave('effectByProblemPost.jpg')


########################################################################################
####### separate models
########################################################################################

sepModsMid <- datLong%>%
    nest(-prob)%>%
    mutate(
        mod=map(data, ~glmer(mid~condition+pre+ScaleScore_imp+(1|initial_teacher_class),data=.x,family=binomial)),
        mod=map(mod,~tidy(.)%>%filter(term=='conditionInstant'))
    )%>%
    unnest(mod)

save(sepModsMid,file='sepModsMid.RData')

plot(sepModsMid$estimate,effsMid$effect,xlim=range(sepModsMid$estimate),ylim=range(sepModsMid$estimate))
abline(0,1)
abline(h=fixef(mid3)['conditionInstant'],lty=2)

sepModsPost <- datLong%>%
    nest(-prob)%>%
    mutate(
        mod=map(data, ~glmer(post~condition+pre+ScaleScore_imp+(1|initial_teacher_class),data=.x,family=binomial)),
        mod=map(mod,~tidy(.)%>%filter(term=='conditionInstant'))
    )%>%
    unnest(mod)

save(sepModsPost,file='sepModsPost.RData')

plot(sepModsPost$estimate,effsPost$effect,xlim=range(sepModsPost$estimate),ylim=range(sepModsPost$estimate))
abline(0,1)
abline(h=fixef(post3)['conditionInstant'],lty=2)


sepOLSmid <-  datLong%>%
    nest(-prob)%>%
    mutate(
        mod=map(data, ~lm_robust(mid~condition+pre+ScaleScore_imp,data=.x,fixed_effects=~initial_teacher_class)),
        mod=map(mod,~tidy(.)%>%filter(term=='conditionInstant'))
    )%>%
    unnest(mod)
save(sepOLSmid,file='sepOLSmid.RData')

plot(sepModsMid$estimate,sepOLSmid$estimate)
mod=lm(sepOLSmid$estimate~sepModsMid$estimate)
summary(mod)
abline(mod)

sepOLSpost <-  datLong%>%
    nest(-prob)%>%
    mutate(
        mod=map(data, ~lm_robust(post~condition+pre+ScaleScore_imp,data=.x,fixed_effects=~initial_teacher_class)),
        mod=map(mod,~tidy(.)%>%filter(term=='conditionInstant'))
    )%>%
    unnest(mod)
save(sepOLSpost,file='sepOLSpost.RData')

plot(sepModsPost$estimate,sepOLSpost$estimate)
mod=lm(sepOLSpost$estimate~sepModsPost$estimate)
summary(mod)
abline(mod)



########################################################################################
####### stan models
########################################################################################
getEffsStan=function(mod){
    samp <- as.matrix(mod$stanfit)[,grep('condition',rownames(mod$stan_summary))]
    cnames <- grep('b[conditionInstant prob:',colnames(samp)[!grepl('NEW',colnames(samp))],fixed=TRUE,value=TRUE)
    effsStan <- samp[,rep('conditionInstant',10)]+samp[,cnames]
    colnames(effsStan) <- str_extract(cnames,"\\d+")

    apply(effsStan,2,function(x) c(effect=mean(x), seEff=sd(x),quantile(x,c(.025,.975)),PrGr0=mean(x>0)))%>%
        t()%>%
        as.data.frame()%>%
        rownames_to_column('item')    
}

#### midtest
stanMid <- stan_glmer(mid ~ condition + pre  + ScaleScore_imp +
                           (1 | student_number/initial_teacher_class) + (pre + condition | prob),
                   data=datLong,family=binomial(logit),subset=hasMidtest)
stanMid$loo=loo(stanMid,cores=10)
save(stanMid,file='stanMid.RData')

getEffsStan(stanMid)%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',title="Effect of Immediate vs Delayed Feedback on Midtest Problems",
         subtitle="Estimated with Stan")
ggsave('byProbMidtestStan.jpg')

stanMid2 <- stan_glmer(
    mid ~ condition+pre+ScaleScore_imp+EIP_imp+ESOL_imp+IEP_imp+FEMALE_imp+GIFTED_imp+race_imp+pre.total_math_score+
                        (1 | student_number/initial_teacher_class) + (pre + condition | prob),
                    data=datLong,family=binomial(logit),subset=hasMidtest)
stanMid2$loo=loo(stanMid2,cores=10)
save(stanMid2,file='stanMid2.RData')

effsMidStan=getEffsStan(stanMid2)
rng=range(c(sepModsMid$estimate,effsMidStan$effect))
rng=rng+(rng[2]-rng[1])/20*c(-1,1)
plot(sepModsMid$estimate,effsMidStan$effect,xlim=rng,ylim=rng)
abline(0,1)

rng=range(c(sepModsMid$std.error,effsMidStan$seEff))
rng=rng+(rng[2]-rng[1])/20*c(-1,1)
plot(sepModsMid$std.error,effsMidStan$seEff,xlim=rng,ylim=rng)
abline(0,1)

mid1vsmid2=loo_compare(stanMid,stanMid2)

getEffsStan(stanMid2)%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',title="Effect of Immediate vs Delayed Feedback on Midtest Problems",
         subtitle="Estimated with Stan")
ggsave('byProbMidtestStan2.jpg')

##### posttest

stanPost <- stan_glmer(post ~ condition + pre  + ScaleScore_imp +
                           (1 | student_number/initial_teacher_class) + (pre + condition | prob),
                   data=datLong,family=binomial(logit),subset=hasPosttest)
stanPost$loo <- loo(stanPost,cores=10)
save(stanPost,file='stanPost.RData')

getEffsStan(stanPost)%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',title="Effect of Immediate vs Delayed Feedback on Posttest Problems",
         subtitle="Estimated with Stan")
ggsave('byProbPosttestStan.jpg')

stanPost2 <- stan_glmer(
    post ~ condition+pre+ScaleScore_imp+EIP_imp+ESOL_imp+IEP_imp+FEMALE_imp+GIFTED_imp+race_imp+pre.total_math_score+
                        (1 | student_number/initial_teacher_class) + (pre + condition | prob),
                    data=datLong,family=binomial(logit),subset=hasPosttest)
stanPost2$loo=loo(stanPost2,cores=10)
save(stanPost2,file='stanPost2.RData')

loo_compare(stanPost,stanPost2)

getEffsStan(stanPost2)%>%
    ggplot(aes(item, effect,ymin=effect-2*seEff,ymax=effect+2*seEff))+
    geom_point()+
    geom_errorbar(width=0)+geom_hline(yintercept=0)+
    labs(x='Item',y='Treatment Effect (Logit Scale)',title="Effect of Immediate vs Delayed Feedback on Posttest Problems",
         subtitle="Estimated with Stan")
ggsave('byProbPosttestStan2.jpg')

effsPostStan=getEffsStan(stanPost2)

rng=range(c(sepModsPost$estimate,effsPostStan$effect))
rng=rng+(rng[2]-rng[1])/20*c(-1,1)
plot(sepModsPost$estimate,effsPostStan$effect,xlim=rng,ylim=rng)
abline(0,1)

rng=range(c(sepModsPost$std.error,effsPostStan$seEff))
rng=rng+(rng[2]-rng[1])/20*c(-1,1)
plot(sepModsPost$std.error,effsPostStan$seEff,xlim=rng,ylim=rng)
abline(0,1)



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










y <- mod3a$y  # matrix of "success" and "failure" counts
trials <- rowSums(y)
y_prop <- y[, 1] / trials  # proportions

# get predicted success proportions
yrep <- posterior_predict(mod3a)
yrep_prop <- sweep(yrep, 2, trials, "/")

ppc_error_binned(y, yrep[1:6, ])
