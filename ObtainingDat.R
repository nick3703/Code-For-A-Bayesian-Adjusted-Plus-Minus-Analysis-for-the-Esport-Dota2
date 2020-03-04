library(jsonlite)
library(RDota2)
library(tidyverse)
article_key <- "589506D2C6E14DC123BED6BBAC538036" 
key_actions(action='register_key',value=article_key)

prof.dota.dat=read.csv("GameIDs.csv") 

prof.dota.tib=prof.dota.dat
tot.games=length(unique(prof.dota.tib$match_id))
unique.games=unique(prof.dota.tib$match_id)
count=1
place.hold=data.frame(game=NA,player=NA,slot=NA,id=NA,i0=NA,i1=NA,i2=NA,i3=NA,i4=NA,i5=NA,bp0=NA,
                      bp1=NA,bp2=NA,itemn=NA,kills=NA,deaths=NA,assists=NA,l_st=NA,la_hits=NA,denies=NA,gpm=NA,xpm=NA,level=NA,win=NA)
prof.match.details=list()
for(k in 1:tot.games){
  game=get_match_details(unique.games[k])
  for(j in 1:10){
    place.hold[count,1]=unique.games[k]
    place.hold[count,(2:(ncol(place.hold)-1))]=data.frame(game$content[[1]][[j]])
    if(j<=5){
      place.hold[count,]$win=(prof.dota.tib%>%filter(match_id==unique.games[k])%>%select(win))[1,]
    }else{
      place.hold[count,]$win=(prof.dota.tib%>%filter(match_id==unique.games[k])%>%select(win))[6,]
    }
    count=count+1
  }
}

dota.working.data=as.tibble(place.hold)

dota.working.data$win=unlist(place.hold$win)



write.csv(dota.working.data,"FullData.csv")

key_actions(action='delete_key')
