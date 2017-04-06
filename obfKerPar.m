%% obfKerPar - Kernel parameters objective function
% y=obfKerPar(K, kernelDensity, par, observedData, regressionPriority)
%
% Objective function to find optimal kernel parameters in calibrate.m
%
% Last update: September 2016

function y=obfKerPar(K, kernelDensity, par, observedData, regressionPriority)


%% Getting kernel information

N=length(K);

IncMom1=zeros(1,N);
I1=zeros(1,N);
IncMomL1=zeros(1,N);
J1=zeros(1,N);
call=zeros(N,1);
put=zeros(N,1);

% Incomplete moments
for j=1:N % Strikes loop
    Kstar=K(j);
    if (isfield(kernelDensity,'i_thIncUMoment')==1)&&(isfield(kernelDensity,'i_thIncLMoment')==1)
        I1(j)=kernelDensity.i_thIncUMoment(Kstar,1,par);
        if Kstar==0
            J1(j)=0;
        else
            J1(j)=kernelDensity.i_thIncLMoment(Kstar,1,par);
        end
        IncMom1(j)=kernelDensity.i_thIncUMoment(Kstar,0,par);
        if Kstar==0
            IncMomL1(j)=0;
        else
            IncMomL1(j)=kernelDensity.i_thIncLMoment(Kstar,0,par);
        end
    else
        I1(j)=integral(@(x) x.*kernelDensity.pdf(x,par),Kstar,Inf);
        if Kstar==0
            J1(j)=0;
        else
            J1(j)=integral(@(x) x.*kernelDensity.pdf(x,par),0,Kstar);
        end
        IncMom1(j)=integral(@(x) kernelDensity.pdf(x,par),Kstar,Inf);
        if Kstar==0
            IncMomL1(j)=0;
        else
            IncMomL1(j)=integral(@(x) kernelDensity.pdf(x,par),0,Kstar);
        end
    end
    call(j)=I1(j)-Kstar*IncMom1(j);
    put(j)=Kstar*IncMomL1(j)-J1(j);
end

pricesRes=[call put]-observedData;

switch regressionPriority
    case 'robustness'
        meanRes=mean(vec(pricesRes));
        weight=sqrt(length(K))*meanRes;
        y=[pricesRes; ones(1,2)*weight];
    case 'fitting'
        meanRes=mean(vec(pricesRes));
        weight=sqrt(length(K))*meanRes;
        y=pricesRes;
    otherwise
        y=NaN*ones(size(observedData));
end