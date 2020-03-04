//
// This Stan program defines the Gold Per Minute APM Model from
//Section 5.2
data{
int<lower=1> n; //Number of Observations
int<lower=1> p; //Number of Players
int<lower=1> hp;
int<lower=1> tot;
real y[n]; //Vector of gpm
int W_sparse[tot];
int<lower=-5, upper=5> coef[tot];
int counter[n];  //Number of Replacement Players
int countsum[n];
int<lower=0, upper=1> radflag[n];
}
parameters {
vector[hp] offbeta;
vector[hp] defbeta;
real<lower=0> sigoff;
real<lower=0> sigw;
real<lower=0> sigdef;
real radavg;
real inter;
real muoff;
real mudef;
}
transformed parameters {
vector[n] mu; //Linear Predictor for Gaussian response
vector[p] beta;
vector[hp] offaboverep;
vector[hp] defaboverep;
beta = append_row(offbeta,defbeta);
for(i in 1:n) {
mu[i] = 0;
for(k in 1:counter[i]){
mu[i] += beta[W_sparse[countsum[i]+k]]*coef[countsum[i]+k];
}
mu[i] += radflag[i]*radavg;
}
for(j in 1:hp){
offaboverep[j]=offbeta[j]-offbeta[hp];
defaboverep[j]=defbeta[hp]-defbeta[j];
}

}
model{
offbeta~normal(0,sigoff);
defbeta~normal(0,sigdef);
y~normal(mu,sigw);
sigoff~student_t(5,0,5);
sigdef~student_t(5,0,5);
sigw~student_t(5,0,5);
radavg~normal(0,100);

}
generated quantities{
  vector[n] y_rep;
for(i in 1:n){
  y_rep[i]=normal_rng(mu[i],sigw);
}
}