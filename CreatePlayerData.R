d = read.csv('FullData.csv')
h = read.csv('heroes.csv')
d$X=NULL
d$win=d$win-1 #Got coded 2,1 vice 1,0
d = d %>% 
  rename(k=kills, d=deaths, a=assists, st=l_st, 
         lh=la_hits, dn=denies, w=win, lev=level) %>%
  mutate(w=as.numeric(w), l=1-w, gp=1) ## wins, losses, games played
d$game.num = as.numeric(factor(d$game))
## create radiant/dire column
d$rd = NA
rows.r = d$slot %in% 0:4    
rows.d = d$slot %in% 128:132
d$rd[rows.r] = 'radiant'
d$rd[rows.d] = 'dire'
head(d,2)
table(d$rd)

## rename slot.  instead of 0-4 and 128-132, make it home1-home5 and away1-away5
d$slot[rows.r] = paste0('radiant', d$slot[rows.r]+1) 
d$slot[rows.d] = paste0('dire', as.numeric(d$slot[rows.d])-127)
## convert hero numbers to names

h = select(h, hero, id, str, agi, int, tot)
d = left_join(d,h)
head(d,2)

d = rename(d, hero.id=id)

## convert player numbers to names, if possible
d$player.id = d$player 

stat.cols = c('k', 'd', 'a',  'lh', 'dn', 'gpm', 'xpm', 'lev', 'w', 'l', 'gp', 'str', 'agi', 'int', 'tot' )
dd = d %>% group_by(game, game.num, rd) %>% 
  summarise_at(stat.cols, sum) %>%
  mutate(w=w/5, l=l/5, gp=gp/5)
head(dd)

## create for/against, differential, percentage
stat.cols.a = paste0(stat.cols, '.a')
stat.cols.d = paste0(stat.cols, '.d')
stat.cols.p = paste0(stat.cols, '.p')
dd[,stat.cols.a]=NA

### against
for(j in unique(dd$game)){
  dd[dd$game==j & dd$rd=='radiant', stat.cols.a] = dd[dd$game==j & dd$rd=='dire'   , stat.cols]
  dd[dd$game==j & dd$rd=='dire'   , stat.cols.a] = dd[dd$game==j & dd$rd=='radiant', stat.cols]
}

### gpm diff and perc
dd[stat.cols.d] = dd[,stat.cols] - dd[,stat.cols.a]
dd[stat.cols.p] = dd[,stat.cols]/(dd[,stat.cols]+dd[,stat.cols.a])
head(dd)

## create team ID
rad  = d %>% select(game, slot, player, rd) %>% filter(rd=='radiant') %>% spread(key=slot, value=player)
dire = d %>% select(game, slot, player, rd) %>% filter(rd=='dire'   ) %>% spread(key=slot, value=player)
colnames(rad ) = c('game', 'rd', paste0('p', 1:5))
colnames(dire) = c('game', 'rd', paste0('p', 1:5))
cols = paste0('p', as.character(1:5))
# rad[,cols]  = apply( rad[,cols], 1, sort)
# dire[,cols] = apply(dire[,cols], 1, sort)
for(j in 1:nrow(rad )){ rad[j,cols] = sort( rad[j,cols])}
for(j in 1:nrow(dire)){dire[j,cols] = sort(dire[j,cols])}
teams = bind_rows(rad, dire) %>% arrange(game)
unique.teams = unique(teams[,cols])
n.teams = nrow(unique(teams))

## label the unique teams
unique.teams$id = 1:nrow(unique.teams)

## add labels to team data.
unique.teams$players= paste(unique.teams$p1,
                            unique.teams$p2, 
                            unique.teams$p3, 
                            unique.teams$p4, 
                            unique.teams$p5, sep='-')

teams$players = paste(teams$p1, teams$p2, teams$p3, teams$p4, teams$p5, sep='-')
head(teams,2)
head(unique.teams,6)

## match based on those columns.
teams$team.id=match(teams$players, unique.teams$players)
teams$team.id=teams$team.id+10000 ## add 10000 so that every team number is 5 digits.

## add team.id to the team data and player data
head(d ,2)
head(dd,2)
head(teams,2)
dd = left_join(dd, select(teams, game, rd, team.id))
d  = left_join(d , select(teams, game, rd, team.id))

## add players to team data
colnames(rad ) = c('game', 'rd', paste0('r', 1:5))
colnames(dire) = c('game', 'rd', paste0('d', 1:5))
rad.dire = full_join(select(rad, -rd),select(dire, -rd), by='game')
dd = left_join(dd, rad.dire)

## add team stats to player data
d = left_join(d, dd, by=c('game', 'game.num', 'rd', 'team.id'), suffix=c('', '.f'))

## save player and team data
filename = 'data/player.data.by.game.rds'
saveRDS(d, file=filename)