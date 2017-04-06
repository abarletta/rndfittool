function [e2]=fitting_OLS(beta,Y_star,X,delta);

Y_star_d=Y_star-delta;
epsilon=Y_star_d-X*beta;
e2=sum(epsilon.^2);            