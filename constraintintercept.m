%% CONSTRINTINTERCEPT - Constraint function to ensure positive RND
% [cineq,ceq]=constraintintercept(X,beta,Mu,Sigma,delta,W,K0,Kmax,kernelDensity,kerpar)
% 
% This function is used in fmincon to constraint the estimated RND to be
% positive on its entire domain. For more information, see the code section
% in calibrate.m concerning regression based on PCA with option 'robustness'
% being enforced.
%
% See also: fmincon, calibrate
%
% Last update: September 2016

function [cineq,ceq]=constraintintercept(X,beta,Mu,Sigma,delta,W,K0,Kmax,kf,KerMom,IX)

MS=Mu./Sigma;
thresh=1e-5;
ceq=delta-mean(MS*(W*beta));
NPC=length(beta);
beta_PCA0=W(:,1:NPC)*beta;
sigma=std(X);
c=zeros(1,size(X,2)+sum(IX==0));
c(IX)=beta_PCA0./sigma';
c=[1;c']';
cineq=abs(real(integral(@(x) transpose(abs(ortapprox_func(kf, KerMom, c ,x) ...
)), K0, Kmax))-1)-thresh;


end