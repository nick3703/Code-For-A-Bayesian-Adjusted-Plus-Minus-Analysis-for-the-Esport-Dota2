library(rstan)
library(Matrix)
library(tidyverse)

#Get data into format for Stan Code


dat.ph<-readRDS("apm.wins.with.rep.rds")

y.val<-dat.ph$home.w

dat<-dat.ph %>% 
  mutate(rep=rep.h+rep.a)%>%
  select(-game,-team,-home.w,-rep.h,-rep.a,-rep)

abs.dat.ph<-abs(dat)

abs.dat<-abs.dat.ph %>% mutate(rowsum = rowSums(.))

dat<-dat.ph %>% 
  mutate(rep=rep.h+rep.a)%>%
  select(-rep.h,-rep.a)

count.repl<-abs.dat$rowsum+(dat$rep!=0)
x<-as.matrix(dat[,-(1:3)])
x.Mat<-Matrix(x,sparse=TRUE)
pairs<-summary(x.Mat)
pair.dat.arr<-arrange(pairs,i)


counts<-cumsum(c(0,count.repl))

dat<-list(y=y.val,
          W_sparse = pair.dat.arr[,2],
          n=nrow(x),
          p=ncol(x),
          tot=nrow(pair.dat.arr),
          coef=pair.dat.arr[,3],
          counter=count.repl,
          countsum=counts[-length(counts)])

fit<-stan(model_name="WLAPMStan.stan",dat,pars=c("beta","mu","sig"),iter=50000,chains=3)
