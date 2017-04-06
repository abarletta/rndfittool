%% GREEKS - Option greeks by orthogonal polynomials

function [Call, Delta, Gamma] = greeks(H,m,bt)

%% Call prices
Call=H*m;
%% Deltas
HK=H(:,2:end);
Delta=HK(:,1);
if isempty(bt)==0
    p=size(bt,2);
    n=size(bt,1)+1;
    m1=m(2);
    for j=1:p
        Dj=0;
        for i=1:n-1
            Dj=Dj+HK(:,i+1)*bt(i,j);
        end
        Dj=Dj*j*m1^(j-1);
        Delta=Delta+Dj;
    end
end
%% Gammas
Gamma=zeros(size(Delta));
if isempty(bt)==0
    for j=1:p-1
        Dj=0;
        for i=1:n-1
            Dj=Dj+HK(:,i+1)*bt(i,j+1);
        end
        Dj=Dj*(j+1)*j*m1^(j-1);
        Gamma=Gamma+Dj;
    end
end
