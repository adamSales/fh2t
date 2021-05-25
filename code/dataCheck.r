library(tidyverse)
library(readxl)

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
xtabs(~movement+condition_updated,data=dat,addNA=TRUE)%>%addmargins()

