%% SETPARITY -  fix violations of P-C parity
%
% clprices=setparity(K, F, call, put, bidask)
%
% This procedure checks and removes violations of P-C parity that exceed 
% tolerance level settled by bid-ask spread. 
%
% Each couple of prices p,c verifying one of the
% following violating conditions
%
% c-p < F-K-bidask
% c-p > F-K+bidask
%
% is replaces by new values (1+delta)*c and (1-delta)*p where delta is such
% that
%
% (1+delta)*c-(1-delta)*p=F-K +/- bidask


function clprices=setparity(K, F, call, put, bidask)

indp=find((call-put+K-F)>bidask);
indn=find((call-put+K-F)<-bidask);

%% Over-priced
if isempty(indp)==0
    delta=(F-K(indp)+bidask+put(indp)-call(indp))./(call(indp)+put(indp));
    call(indp)=(1+delta).*call(indp);
    put(indp)=(1-delta).*put(indp);
end
%% Under-priced

if isempty(indn)==0
    delta=(F-K(indn)-bidask+put(indn)-call(indn))./(call(indn)+put(indn));
    call(indn)=(1+delta).*call(indn);
    put(indn)=(1-delta).*put(indn);
end

%% Output
clprices=[call put];

end