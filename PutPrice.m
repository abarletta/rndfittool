%% PUTPRICE - Put option price by orthogonal expansions
% P=PutPrice(c,J,IncMomL,a,K)
%                                                                       
% Computes the price P of an european put option by expanding
% the pdf of the underline around a fixed kernel. The
% approximation is made by arresting at the k-th order, where k is the
% length of the vector m of known moments of the distribution of the underline.
%
% Output:                                                                
%         P -  MAT: approximated integral of P wtr to the real measure of
%                   the underline. This is an approximation made in the
%                   space of square integrable functions.
%              FIN: approximated price of the option with payoff P.      
%
% Input:                                                                
%         m  - moments vector of the dynamics of the underline              
%         I  - vector of polynomial quadratures of VIX, wtr to the kernel
%    IncMom  - vector of kernel incomplete moments of order i and ratio K 
%         a  - matrix of coefficients of orthogonal polynomials
%              === warning === 
%              size(a)=size(IncMom)=size(m)
%              ===============
%         K  - strike
%         r  - free risk annualized interest rate
%         T  - maturity (in years)
%
% Last update: September 2016

function P=PutPrice(c,J,IncMomL,a,K)

%% Setting parameters

n=length(c);                             % order of the approximation
A=zeros(n+1,1);                          % vector of the approx.coeff.
P=0;

%% Evaluating formula coefficients

for k=0:n-1                              % evaluation of A(k)
    for i=0:k
        A(k+1)=A(k+1)+a(k+1,i+1)*(K*IncMomL(i+1)-J(i+1));
    end
end
%c*gamma(alpha+1)

%% Evaluating price

for k=1:n
    P=P+c(k)*A(k);
end

end