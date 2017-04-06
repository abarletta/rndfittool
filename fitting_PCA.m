%% FITTING_PCA - Objective function for fmincon with PCA
% [e2,grd]=fitting_PCA(beta,Y_star,PCA,delta)
%
% This function returns the objective function to be passed in fmincon when
% performing the estimation based on PCA with "robustness" option being
% enforced. The gradient of the objective function is also returned as
% optional output argument. 
%
% N.B. Avoiding passing the exact gradient in fmincon will harshly affect
%      the efficiency of fmincon.
%
% Last update: September 2016

function [e2,grd]=fitting_PCA(beta,Y_star,PCA,delta)

Y_star_d=Y_star-delta;
epsilon=Y_star_d-PCA*beta;
e2=sum(epsilon.^2);  

if nargout>1 % gradient
    grd=NaN(size(beta));
    for k=1:length(beta)
        grd(k)=2*PCA(:,k)'*(PCA*beta-Y_star); 
    end
end