%% ORTAPPROX - ortogonal approximation
%
% f=ortapprox(kf, KerMom, c)
%
% Last modified: September 2016

function [f,p]=ortapprox(kf, KerMom, c)

%% Standard commands
format LONG;

%% Data setting and memory allocation

NP=length(c)-1;

%% Determination of orthogonal polynomials
ortpol=OrtPolCoeff(NP, KerMom);
p=@(x) ones(1,length(x));
for i=1:NP
    temp=@(x) 0;
    for j=0:i
        temp=@(x) temp(x)+ortpol(i+1,j+1)*(x.^j);
    end
    p=@(x) [p(x);temp(x)];
end

%% Determination of orthogonal polynomial expansion
f=@(x) kf(x)'.*(p(x)'*c');

end % END OF FUNCTION
