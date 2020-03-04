data{
int<lower=1> n; //Number of Observations
int<lower=1> p; //Number of Players
int<lower=1> tot;
int<lower=0, upper=1> y[n]; //Vector of Wins/Losses
int W_sparse[tot];
int<lower=-5, upper=5> coef[tot];
int counter[n];  //Number of Replacement Players
int countsum[n];
}
parameters {
vector[p] beta; //Covariate vector
real mu;
real<lower=0> sig;
}
transformed parameters {
vector[n] logitpi;    //linear predictor
vector[n] pi;
for(i in 1:n) {
  logitpi[i] = 0;
  for(k in 1:counter[i]){
    logitpi[i] += beta[W_sparse[countsum[i]+k]]*coef[countsum[i]+k];
  }
  logitpi[i] +=mu;
}
pi=inv_logit(logitpi);
}
model{
beta~normal(0,sig);
mu~normal(0,2);     //sig~normal(0,1);
y~bernoulli(pi);
sig~normal(0,1);
}
