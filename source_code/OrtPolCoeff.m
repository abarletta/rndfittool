function a=OrtPolCoeff(n, DistMom)

% 
% ank=OrtPolCoeff(n,k,DistMom)

%                                                                       
% Author:
%          Andrea Barletta
% 
% Computes inductively coefficients of orthogonal polynomials with respect 
% to a general kernel
%
% Output:                                                                
%       a   -   matrix of coefficients [(n+1)x(n+1)]
%               a(i,j) = (j-1)-th coefficient of polynomial of order i-1
% Input:                                                                
%
%         n -   number of polynomials to be computed
%   DistMom -   vector containing moments of the kernel until order 2n
%               
%

a=zeros(n+1,n+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Polynomial of order 0

a(1,1)=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Polynomial of order 1
if(n>=1)
    a(2,1)=-DistMom(2);
    a(2,2)=1;
    a(2,:)=a(2,:)/sqrt(DistMom(3)-DistMom(2)^2);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Polynomial of order n
%
% pn(x) = (x-cn)*pn-1(x)-dn*pn-2(x)
%

if(n>=2)
    for p=2:n
        % Computation of cp and dp
        cp=0;
        for i=0:p-1
            for j=0:p-1
                cp=cp+a(p,i+1)*a(p,j+1)*DistMom(i+j+2);
            end
        end
        dp=0;
        for i=0:p-1
            for j=0:p-2
                dp=dp+a(p,i+1)*a(p-1,j+1)*DistMom(i+j+2);
            end
        end
        
        % Computation of not normalized coefficients
        a(p+1,1)=-cp*a(p,1)-dp*a(p-1,1);
        for i=1:p-2
            a(p+1,i+1)=a(p,i)-cp*a(p,i+1)-dp*a(p-1,i+1);
        end
        a(p+1,p)=a(p,p-1)-cp*a(p,p);
        a(p+1,p+1)=a(p,p);

        % Normalization of coefficients
        norm=-(cp^2)-(dp^2);
        for i=0:p-1
            for j=0:p-1
                norm=norm+a(p,i+1)*a(p,j+1)*DistMom(i+j+3);
            end
        end
        norm=sqrt(norm);
        
        a(p+1,:)=a(p+1,:)/norm;
        
    end
end


