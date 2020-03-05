# Code For *A Bayesian Adjusted Plus Minus Analysis for the Esport Dota2* by Clark, MacDonald, Kloo

This repo contains code for obtaining Dota 2 data in order to replicate the results for the manuscript *A Bayesian Adjusted Plus-Minus Analysis for the Esport Dota 2*

The following R libraries are required:
`tidyverse`, `RDota2`, `Matrix`, `rstan`, `jsonlite`

The repo contains the following files:

- GameIDs.csv: Game IDs for professional games obtained from opendota.com
- ObtainingDat.R: Code For Obtaining Game Details using RDota2
- CreatePlayerData.R:  Code for preparing data to compute player statistics as in Section 4.2
- CreateTeamData.R: Code for preparing data to compute team statistics as in Section 4.1
- CreateAPMData.R: Code for preparing data to be used in APM Models in Section 5
- WLAPMStan.stan: Code for building the Stan model for WL APM model in Section 5.1
- FitBayesWLAPM.R: Code for fitting the WL APM Model in Section 5.1
- GPMAPMStan.stan: Code for building the Stan model for GPM APM model in Section 5.2
- FitBayesGPMAPM.R: Code for fitting the GPM APM Model in Section 5.2

