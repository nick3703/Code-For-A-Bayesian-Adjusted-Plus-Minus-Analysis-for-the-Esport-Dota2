
library(tidyverse)
library(Matrix)
filename = 'data/player.data.by.game.rds'
dp = readRDS(filename)
dp$game   = factor(dp$game)

filename = 'data/team.data.by.game.rds'
dt = readRDS(filename)

## Rep players. GP for players
min.GP = 10
GP.players = dp %>% count(player) %>% arrange(desc(n))
rows = GP.players$n < min.GP
rep.players = as.character(GP.players$player[rows])
length(which(!rows))
head(rep.players)

## d with replacement players
dr=dp
rows = dr$player %in% rep.players
dr$player[rows] = 'rep'
head(dr,2)

rows1 = dp$rd=='radiant'
rows2 = dp$rd=='dire'
dp$player = factor(dp$player)
dr$player = factor(dr$player)


create.wide.for.apm = function(dp=NULL, dt=NULL, rows='game', cols='player', outcomes='w',
                               off.def=T, rep=T){
  
  formula  = as.formula(paste0(' ~ ', rows, '+', cols))
  xh = xtabs(formula, data=dp[rows1,], sparse=T, drop.unused.levels = F)
  xa = xtabs(formula, data=dp[rows2,], sparse=T, drop.unused.levels = F)
  xh = as.data.frame.matrix(xh)
  xa = as.data.frame.matrix(xa)
  games = rownames(xh)
  
  if(off.def==F){
    x = xh - xa
    if(rep==T){x = select(x, -rep) %>% mutate(rep.h=xh$rep, rep.a=-xa$rep)}
    x$team = 'radiant'
  }
  
  if(off.def==T){
    col.names = c(paste0('o', colnames(xh)), paste0('d', colnames(xh)), 'team')
    x = rbind(cbind(xh, xa, team='radiant'), 
              cbind(xa, xh, team='dire'))
    colnames(x) = col.names
  }
  
  x$game = games
  
  ## create y
  
  ## if off.def=F, take radiant wins
  if(off.def==F){  
    y = dt %>% 
      filter(rd=='radiant') %>% 
      mutate(radiant.w=w, team='radiant') %>% 
      select(game, radiant.w, team) 
  }
  
  if(off.def==T){
    yh = dt %>% filter(rd=='radiant') %>% select('game', outcomes) %>% mutate(team='radiant')
    ya = dt %>% filter(rd=='dire') %>% select('game', outcomes) %>% mutate(team='dire')
    y = rbind(yh, ya)
  }
  
  d = merge(y, x, by=c('game', 'team'), all=T, sort=F)
  
  ## the end
  
  return(d)
}


## wins
dw  = create.wide.for.apm(dp, dt, 'game', 'player', outcomes='w', off.def=F, rep=F)
dwr = create.wide.for.apm(dr, dt, 'game', 'player', outcomes='w', off.def=F, rep=T)

## gpm
dg  = create.wide.for.apm(dp, dt, 'game', 'player', outcomes=c('gpm','k', 'xpm'), off.def=T, rep=F)
dgr = create.wide.for.apm(dr, dt, 'game', 'player', outcomes=c('gpm','k', 'xpm'), off.def=T, rep=T)

## save
filename.w  = 'data/apm.wins.no.rep.rds'
filename.wr = 'data/apm.wins.with.rep.rds'
filename.g  = 'data/apm.gpm.no.rep.rds'
filename.gr = 'data/apm.gpm.with.rep.rd'
saveRDS(dw , file=filename.w )
saveRDS(dwr, file=filename.wr)
saveRDS(dg , file=filename.g )
saveRDS(dgr, file=filename.gr)