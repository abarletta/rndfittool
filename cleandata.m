%% CLEANDATA
% Removes convexity and monotony inconsistencies from option prices
%
% cldata=cleandata(K, call, put)
%
% This procedure transforms call and put price curves into dereasing and
% increasing convex functions. Points violating above conditions are 
% replaced with the linear approximation obtained from neighboors. 

function cldata=cleandata(K, call, put)

if iscolumn(call)==0
    call=call';
end
if iscolumn(put)==0
    put=put';
end

for j=2:length(K)-1
    % Call Monotony
    if (call(j)>call(j-1))
        call(j)=call(j-1);
    end
    % Put Monotony
    if (put(j)<put(j-1))
        put(j)=put(j-1);
    end
    
    % Concavity
    for i=j:length(K)-1
        % Call
        ub=interp1([K(j-1) K(i+1)], [call(j-1) call(i+1)], K(j:i), 'linear', 'extrap');
        temp=call(j:i);
        ind=(temp>ub);
        if sum(ind)>0
            temp(ind)=ub(ind);
            call(j:i)=temp;
        end
        % Put
        ub=interp1([K(j-1) K(i+1)],[put(j-1) put(i+1)], K(j:i), 'linear', 'extrap');
        temp=put(j:i);
        ind=(temp>ub);
        if sum(ind)>0
            temp(ind)=ub(ind);
            put(j:i)=temp;
        end
    end
end

cldata=[call put];

end
