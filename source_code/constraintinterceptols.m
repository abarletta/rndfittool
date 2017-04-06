function [c,ceq]=constraintinterceptols(beta,Mu,delta)
MS=Mu;
ceq=delta-mean(MS*beta);
c=[];
end