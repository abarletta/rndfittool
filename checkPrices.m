function [vc,vp]=checkPrices(K,call,put)
%% [vc,vp]=checkPrices(K,call,put)
% Check integrity of call and put price curves
%
% This function returns the domain points where call and put price curves
% reveal monotony or concavity issues.
%
% Input:
%
%          K - strike domain
%       call - call prices
%        put - put prices
%
% Output:
%
%         vc - violations indexes related to call prices
%         vp - violations indexes related to put prices

vc=[];
vp=[];

for j=2:length(K)-1
    % Call Monotony
    if (call(j)>call(j-1))
            vc=sort(union(vc,j));
    end
    % Put Monotony
    if (put(j)<put(j-1))
            vp=sort(union(vp,j));
    end

    % Concavity
    for i=j:length(K)-1
        % Call
        ub=interp1([K(j-1) K(i+1)], [call(j-1) call(i+1)], K(j:i), 'linear', 'extrap');
        if sum(call(j:i)>ub)>0
            vc=sort(union(vc, j-1:i+1));
        end
        % Put
        ub=interp1([K(j-1) K(i+1)],[put(j-1) put(i+1)], K(j:i), 'linear', 'extrap');
        if sum(put(j:i)>ub)>0
            vp=sort(union(vp, j-1:i+1));
        end
    end
end