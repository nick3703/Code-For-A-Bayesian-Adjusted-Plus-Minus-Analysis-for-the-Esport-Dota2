

dat<-dat.ph %>%select(-game,-team,-gpm,-k,-xpm)

dat.mut<-dat %>% mutate(rowsum = 10-orep-drep)


dat.indicat<- dat!=0

num.of.player.counts<-apply(dat.indicat,1,sum)
rm(dat.indicat)

#count.repl<-dat.mut$rowsum
#count.repl.ph<-count.repl

#dat<-dat %>% filter(count.repl!=0)

#count.repl<- dat.mut  %>% select(rowsum)

x<-as.matrix(dat)

#y.val.df<-dat.ph%>%filter(count.repl.ph!=0)%>% select(gpm)

y.val<-dat.ph$gpm

y.val.std<-y.val-mean(y.val)

#rad.flag.df<-dat.ph %>% filter(count.repl.ph!=0) %>% select(team)

x.Mat<-Matrix(x,sparse=TRUE)

pairs<-summary(x.Mat)
pair.dat.arr<-arrange(pairs,i)



rad.flag<-as.numeric(dat.ph$team=="home")

counts<-cumsum(c(0,num.of.player.counts))

bayes.dat<-list(y=y.val.std,
                W_sparse = pair.dat.arr[,2],
                n=nrow(x),
                p=ncol(x),
                hp=ncol(x)/2,
                tot=nrow(pair.dat.arr),
                coef=pair.dat.arr[,3],
                counter=num.of.player.counts,
                countsum=counts[-length(counts)],
                radflag=rad.flag)

fit<-stan("WPMAPMStan.stan",bayes.dat,pars=c("beta","mu","sigoff","sigdef","radavg","sigw","y_rep","offaboverep","defaboverep"),iter=5000)
