filename = 'rawdata/player.data.by.game.rds'
d = readRDS(file=filename)
head(d,2)
d$slot = gsub('home|away', '', d$slot)

## compute team totals
stat.cols = c('k', 'd', 'a', 'st', 'lh', 'dn', 'gpm','xpm', 'lev', 'w', 'l', 'gp')
dt = d %>% group_by(game, ha) %>% 
  summarise_at(stat.cols, sum) %>%
  mutate(w=w/5, l=l/5, gp=gp/5) ## w, l and gp are already team totals, so don't need to add 1 for each player
head(dt,2)

## get all players for each game
## get all heroes   for each game
dp = d %>% select(game, game.num, slot, player, ha) %>% spread(key=slot, value=player)
dh = d %>% select(game, game.num, slot, hero  , ha) %>% spread(key=slot, value=hero  )
head(dp,2)
head(dh,2)

## rename columns
player.cols = paste0('p', 1:5)
hero.cols   = paste0('h', 1:5)
colnames(dp) = c('game', 'game.num', 'ha', player.cols)
colnames(dh) = c('game', 'game.num', 'ha', hero.cols  )

## get unique teams
ordered.player.cols = gsub('p', 'o', player.cols)
ordered.player.cols
dp[,ordered.player.cols]=NA
head(dp)
## sort players so that we can find unique 5-player combos where order doesn't matter.
for(j in 1:nrow(dp)){
  dp[j,ordered.player.cols] = sort(dp[j,player.cols])
}

## find rows that aren't duplicated, and number them.
rows = which(!duplicated(dp[,ordered.player.cols]))
team.ids = dp[rows,ordered.player.cols]
team.ids$team.id=1:nrow(team.ids)

dp = merge(dp, team.ids, by=ordered.player.cols, all=T, sort=F)
dp = dp[order(dp$game.num),]

head(dp)

## rearrange columns, remove ordered.player.cols
cols = c('game', 'game.num', 'ha', 'team.id', player.cols)
dp = dp[,cols]
head(dp)
#### end of temporary code for adding team.id ####

## merge players, team, heroes, and team stats
head(dt,2)
head(dp,2)
head(dh,2)
d = merge(dp, dh, by=c('game', 'game.num', 'ha'), all=T)
head(d)
d = merge(d, dt, by=c('game', 'ha'), all=T)
head(d,2)

## for and against.  
## Copy the 'for' stats for the *home* team to the 'against' columns for the *away* team.
## Copy the 'for' stats for the *away* team to the 'against' columns for the *home* team.
## create a column that is the opposite of ha.
## Then merge on ha and ha.against.
d$ha.against = NA 
d$ha.against[d$ha=='away'] = 'home'
d$ha.against[d$ha=='home'] = 'away' 
head(d)
d = merge(select(d,-ha.against   ), 
          select(d,-ha, -game.num), 
          by.x=c('game', 'ha'        ), 
          by.y=c('game', 'ha.against'), suffixes=c('.f', '.a'))
head(d)

## save team data
filename = 'data/team.data.by.game.rds'
saveRDS(d, file=filename)
