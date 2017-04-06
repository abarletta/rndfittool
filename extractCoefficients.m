function [A,W,H]=extractCoefficients(kernelDensity,kerpar,nM,K,K0)

%% Getting kernel moments
kf=@(x) kernelDensity.pdf(x,kerpar);

KerMom=zeros(2*nM+1,1);

if isfield(kernelDensity,'i_thMoment')==1
    for i=0:2*nM
        KerMom(i+1)=kernelDensity.i_thMoment(i,kerpar);
    end
else
    for i=0:2*nM
        KerMom(i+1)=integral(@(x) x.^i.*kf(x),0,Inf);
    end
end

%% Getting orthogonal polynomials
OP=OrtPolCoeff(nM, KerMom(1:2*nM+1));
G=zeros(nM+1,nM+1);
for k=0:nM
    for j=0:k
        G(k+1,j+1)=nchoosek(k,j)*K0^(k-j);
    end
end
W=OP*G^(-1);
    
%% Determination of kernel pdf, moments, and incomplete moments

N=length(K);

IncMom=zeros(nM+2,N);
I=zeros(nM+2,N);
IncMomL=zeros(nM+2,N);
J=zeros(nM+2,N);

% Probability density function
kf=@(x) kernelDensity.pdf(x,kerpar);

% Incomplete moments
for j=1:N % Strikes loop
    Kj=K(j);
    
    % Incomplete moments
    if (isfield(kernelDensity,'i_thIncUMoment')==1)&&(isfield(kernelDensity,'i_thIncLMoment')==1)
        for i=0:nM+1
            % Order i+1
            I(i+1,j)=kernelDensity.i_thIncUMoment(Kj,i+1,kerpar);
            if Kj==0
                J(i+1,j)=0;
            elseif nM+2<=2*nM
                J(i+1,j)=KerMom(i+2)-I(i+1,j);
            else
                J(i+1,j)=kernelDensity.i_thIncLMoment(Kj,i+1,kerpar);
            end
            % Order i
            if i==0
                IncMom(i+1,j)=kernelDensity.i_thIncUMoment(Kj,i,kerpar);
                if Kj==0
                    IncMomL(i+1,j)=0;
                else
                    IncMomL(i+1,j)=kernelDensity.i_thIncLMoment(Kj,i,kerpar);
                end
            else
                IncMom(i+1,j)=I(i,j);
                IncMomL(i+1,j)=J(i,j);
            end
        end
    else
        for i=0:nM+1
            % Order i+1
            I(i+1,j)=integral(@(x) x.^(i+1).*kernelDensity.pdf(x,kerpar),Kj,Inf);
            if Kj==0
                J(i+1,j)=0;
            elseif nM+2<=2*nM
                J(i+1,j)=KerMom(i+2)-I(i+1,j);
            else
                J(i+1,j)=integral(@(x) x.^(i+1).*kernelDensity.pdf(x,kerpar),0,Kj);
            end
            % Order i
            if i==0
                IncMom(i+1,j)=integral(@(x) kernelDensity.pdf(x,kerpar),Kj,Inf);
                if Kj==0
                    IncMomL(i+1,j)=0;
                else
                    IncMomL(i+1,j)=integral(@(x) kernelDensity.pdf(x,kerpar),0,Kj);
                end
            else
                IncMom(i+1,j)=I(i,j);
                IncMomL(i+1,j)=J(i,j);
            end
        end
    end
    
end

%% Finding X
A=zeros(length(K),nM+1);

% Generating formula coefficients
for j=1:N % Strikes loop
    Kj=K(j);    
    % Finding j-th column of X
    for k=1:nM+1
        A(j,k)=sum(OP(k,:).*(I(1:end-1,j)-Kj*IncMom(1:end-1,j))');
    end
end

H=A*W;
