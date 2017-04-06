function status=refreshGUI(hObject, handles)
%% REFRESHGUI 
% Refresh graphics after changes are made to data
% structure


%% Set theme colour here
theme=handles.theme;

switch theme
    case 'dark'
        bgCol=[0 0 0];
    case 'light'
        bgCol=[1 1 1];
end

baCol=.3+.65*sin(bgCol*(pi/2));
gridCol=[1 1 1]-bgCol;
lgdCol=gridCol;

co=[0 0.4470 0.7410;       % Blue
    0.8500 0.3250 0.0980;  % Red
    0.4660 0.6740 0.1880;  % Green  
    0.9290 0.6940 0.1250;  % Yellow
    0.4940 0.1840 0.5560;  % Violet
    0.3010 0.7450 0.9330;  % Light Blue
    0.6350 0.0780 0.1840]; % Dark Red
set(groot,'defaultAxesColorOrder',co);


%% Main code
try
    %% Reading data
    inData=handles.inData;
    K=inData{1};
    call=inData{2};
    put=inData{3};
    m=inData{4};
    r=inData{5};
    alreadyComputed=handles.DoStuff;
    cT=handles.cuttingThreshold;
    indCall=(call>cT)&(put>0);
    indPut=(put>cT)&(call>0);
    filteringInd=indCall&indPut;
    
    %% Updating text fields
    if isempty(m)==0
        set(handles.mean, 'String', ['Mean:  ' num2str(m(1),'%.3f')]);
        set(handles.var, 'String', ['Variance:  ' num2str(m(2)-m(1)^2,'%.3f')]);
        pcpR=sum((call(filteringInd)-put(filteringInd)+K(filteringInd)-m(1)).^2);
    else
        set(handles.mean, 'String', 'Mean:  N/A');
        set(handles.var, 'String', 'Variance:  N/A');
        pcpR=var(call(filteringInd)-put(filteringInd)+K(filteringInd),1)*length(K(filteringInd));
    end
    
  
    set(handles.pcpRes, 'String', ['P-C parity res:  ' num2str(sqrt(pcpR/(length(K(filteringInd)))))]);
    
    switch handles.plotType
        case 'prices'
            arg1=call;
            arg2=put;
            if length(inData)==11
                arg1_a=inData{8};
                arg1_b=inData{9};
                LB1=arg1-arg1_b;
                UB1=arg1_a-arg1;
                arg2_a=inData{10};
                arg2_b=inData{11};
                LB2=arg2-arg2_b;
                UB2=arg2_a-arg2;
            end
        case 'ivols'
            % Maturity
            T=alreadyComputed.maturity;
            % Discounting factor
            D=exp(-r*T);
            % Future
            if isempty(m)==1
                F=mean(call-put+K);
            else
                F=m(1);
            end
            % Ivols on mid prices
            if isempty(alreadyComputed.obsIVCall)==1
                alreadyComputed.obsIVCall=blsimpv(D*F, K, r, T, D*call, [], 0, 1e-6,{'call'});
            end
            arg1=alreadyComputed.obsIVCall;
            if isempty(alreadyComputed.obsIVPut)==1
                alreadyComputed.obsIVPut=blsimpv(D*F, K, r, T, D*put, [], 0, 1e-6,{'put'});
            end
            arg2=alreadyComputed.obsIVPut;
            % Ivols on bid and ask prices
            if (length(inData)==11)
                if isempty(alreadyComputed.obsIVCall_a)==1
                    alreadyComputed.obsIVCall_a=blsimpv(D*F, K, r, T, D*inData{8}, [], 0, 1e-6,{'call'});
                    alreadyComputed.obsIVPut_a=blsimpv(D*F, K, r, T, D*inData{10}, [], 0, 1e-6,{'put'});
                    alreadyComputed.obsIVCall_b=blsimpv(D*F, K, r, T, D*inData{9}, [], 0, 1e-6,{'call'});
                    alreadyComputed.obsIVPut_b=blsimpv(D*F, K, r, T, D*inData{11}, [], 0, 1e-6,{'put'});
                    handles.DoStuff=alreadyComputed;
                end
                arg1_a=alreadyComputed.obsIVCall_a;
                arg2_a=alreadyComputed.obsIVPut_a;
                arg1_b=alreadyComputed.obsIVCall_b;
                arg2_b=alreadyComputed.obsIVPut_b;
                LB1=arg1-arg1_b;
                UB1=arg1_a-arg1;
                LB2=arg2-arg2_b;
                UB2=arg2_a-arg2;
                yLim=[min([arg1_a; arg1_b; arg2_a; arg2_b]), max([arg1_a; arg1_b; arg2_a; arg2_b])];
            end
        otherwise
            arg1=[];
    end
    
    guidata(hObject,handles);
    
    %% Plotting
    if isempty(arg1)==0
        subplot(2,1,1,'position',[.04,.65,.93,.3]);
        if length(inData)==11
            h1=area(K,arg1+UB1, 'FaceColor', baCol, ...
                'LineStyle', '--', 'EdgeColor', gridCol);
            %h(1).FaceColor = [.95 .95 .95];
            hold all;
            h=area(K,arg1-LB1, 'FaceColor', bgCol, ...
                'LineStyle', '--', 'EdgeColor', gridCol);
            %h(1).FaceColor = [.95 .95 .95];
            hold on;
            h=gca;
            h.Layer = 'top';
            h.ColorOrderIndex=1;
            %errorbar(K,call,LB,UB,'*b')
                
        end
        h2=plot(K,arg1,'*--','LineWidth',2);
        h=gca;
        h.Color=bgCol;
        h.XColor=gridCol;
        h.YColor=gridCol;
        hold off;
        if strcmp(handles.plotType,'prices')==1
            title('Undiscounted call prices', 'Color', gridCol);
        else
            title('Call imp. volatilities', 'Color', gridCol);
        end
        grid on;
        if length(inData)==11
            hl=legend([h1 h2],{'Bid-Ask interval','Mid-price'}, ...
                'Location','bestoutside', 'Orientation', 'horizontal');
            hl.TextColor=lgdCol;
        end
        xlim([min(K),max(K)]);
        if strcmp(handles.plotType,'ivols')==1
            if length(inData)==1
                ylim(yLim);
            else
                axis tight;
            end
        end
        subplot(2,1,2,'position',[.04,.29,.93,.3]);
        if length(inData)==11          
            h1=area(K,arg2+UB2, 'FaceColor', baCol, ...
                'LineStyle', '--', 'EdgeColor', gridCol);
            %h(1).FaceColor = [.95 .95 .95];
            hold all;
            h=area(K,arg2-LB2, 'FaceColor', bgCol, ...
                'LineStyle', '--', 'EdgeColor', gridCol);
            %h(1).FaceColor = [.95 .95 .95];
            hold on;
            h=gca;
            h.Layer = 'top';
            h.ColorOrderIndex=1;
            %errorbar(K,call,LB,UB,'*b')
        end
        h2=plot(K,arg2,'*--','LineWidth',2);
        h=gca;
        h.Color=bgCol;
        h.XColor=gridCol;
        h.YColor=gridCol;
        hold off;
        grid on;
        if(length(inData)==11)
            hl=legend([h1 h2],{'Bid-Ask interval','Mid-price'}, ...
                'Location','bestoutside', 'Orientation', 'horizontal');
            newPosition = [0 0 1 0.03];
            hl.TextColor=lgdCol;
        end
        xlim([min(K),max(K)]);
        if strcmp(handles.plotType,'ivols')==1
            if length(inData)==1
                ylim(yLim);
            else
                axis tight;
            end
        end
        if strcmp(handles.plotType,'prices')==1
            title('Undiscounted put prices', 'Color', gridCol);
        else
            title('Put imp. volatilities', 'Color', gridCol);
        end
        
        %% Adjusting text fields
        
        handles.irate.String=['Annualized Int. Rate:  ' num2str(100*r) '%'];
        if length(inData)==11
            call_a=inData{8};
            call_b=inData{9};
            put_a=inData{10};
            put_b=inData{11};
            baRes=sum((call_a(filteringInd)-call_b(filteringInd)).^2) ...
                +sum((put_a(filteringInd)-put_b(filteringInd)).^2);
            set(handles.avBAspread, 'String', ['Bid-Ask res:  ' ...
                num2str(sqrt(baRes/(2*length(K(filteringInd)))))]);
        end
        set(groot,'defaultAxesColorOrder','remove');
        status=1;
    end
catch ME
    status=0;
end