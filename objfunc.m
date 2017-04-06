%% OBJFUNC - objective function
% 
% expans=objfunc(K, DistMom, IncMom, I, IncMomL, J, c)
%
% Last modified: September 2016


function expans=objfunc(K, DistMom, IncMom, I, IncMomL, J, c)

%% Standard commands
format LONG;

%% Data setting and memory allocation

N=length(K);
NP=length(c)-1;
call=zeros(N,1);
put=zeros(N,1);

% Determination of orthogonal polynomials
pol=OrtPolCoeff(NP, DistMom);

% Calculation of option prices
for j=1:N % Strikes loop
    call(j)=CallPrice(c,I(:,j),IncMom(:,j),pol,K(j));
    put(j)=PutPrice(c,J(:,j),IncMomL(:,j),pol,K(j));
end
expans=[call put];

end % END OF FUNCTION
