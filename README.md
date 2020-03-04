# Code-For-A-Bayesian-Adjusted-Plus-Minus-Analysis-for-the-Esport-Dota2

This repo contains code for obtaining Dota 2 data in order to replicate the results for the manuscript *A Bayesian Adjusted Plus-Minus Analysis for the Esport Dota 2*

The following R libraries are required:
`tidyverse`, `RDota2`, `Matrix`, `rstan`

The repo contains the following files:

- ObtainingDat: Code For Obtaining Game Details using RDota2
- PreparePlayerStats:  Code for preparing data to compute player statistics as in Section 4.2
- PrepareTeamStats: Code for preparing data to compute team statistics as in Section 4.1
- PrepareAPMData: Code for preparing data to be used in APM Models in Section 5
