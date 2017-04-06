%% ORTAPPROX_FUNC - ortogonal approximation
%
% f=ortapprox_func(kf, KerMom, c, x)
%
% N.B. this function is identical to ortapprox but returns f evaluated at
%      x instead of an anonymous function.
%
% See also: calibrate, fmincon
%
% Last modified: September 2016

function f=ortapprox_func(kf, KerMom, c, x)

%% Standard commands
format LONG;

%% Data setting and memory allocation

NP=length(c)-1;

%% Determination of orthogonal polynomials
ortpol=OrtPolCoeff(NP, KerMom);
p=ones(1,length(x));
for i=1:NP
    temp=zeros(1,length(x));
    for j=0:i
        temp=temp+ortpol(i+1,j+1)*(x.^j);
    end
    p=[p;temp];
end

%% Determination of orthogonal polynomial expansion
f=kf(x)'.*(p'*c');

end % END OF FUNCTION
