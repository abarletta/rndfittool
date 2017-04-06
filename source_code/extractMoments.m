function mom=extractMoments(varargin)

switch length(varargin)
    case 5
         c=varargin{1};
         kernelDensity=varargin{2};
         kerpar=varargin{3};
         nM=varargin{4};
         K0=varargin{5};
         mode='uncentered';
    case 6
        c=varargin{1};
        kernelDensity=varargin{2};
        kerpar=varargin{3};
        nM=varargin{4};
        K0=varargin{5};
        mode=varargin{6};        
    otherwise
        error('Incorrect numebr of input arguments.')
end

%% Getting kernel moments
kf=@(x) kernelDensity.pdf(x,kerpar);

if length(c)<nM+1
    c=[c zeros(1,nM+1-length(c))];
end
c=c(1:nM+1);
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

%% Finding uncentered moments

om=zeros(nM+1,1);
for p=1:nM+1
    Ip=KerMom(p:p+nM);
    om(p)=(c*OP)*Ip;
end
%om=OP\c';

H=zeros(nM+1,nM+1);
for k=0:nM
    for j=0:k
        H(k+1,j+1)=nchoosek(k,j)*K0^(k-j);
    end
end
um=H*om;
    
switch mode
    case 'uncentered'
        mom=um;
    case {'centered','standardized'}
        avg=um(2);
        for k=0:nM
            for j=0:k
                H(k+1,j+1)=nchoosek(k,j)*(-avg)^(k-j);
            end
        end
        H(2,1)=0;
        mom=H*um;
        %mom(2)=avg;
        if strcmp(mode,'standardized')==1
            sigma=sqrt(mom(3));
            for i=4:length(mom)
                mom(i)=mom(i)/(sigma)^(i-1);
            end
        end
    otherwise
        error(['Unknown value ' mode ' for mode']);
end


end