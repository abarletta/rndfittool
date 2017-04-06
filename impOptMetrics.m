function matlabData=impOptMetrics(varargin)
%% IMPOPTMETRICS
% matlabData=impOptMetrics(varargin);

%% Determining file extension

fname=varargin{1};
ext=fname(strfind(fname,'.')+1:end);
tot=6;
if nargin==1
    waitMessage=waitbar(0, 'Importing data from Option Metrics format...');
end
switch ext
    case {'xls','xlsx'}
        try
            [data,txt]=xlsread(fname);
            matlabData=[];
            
            %% Finding call and put labels
            err=0;
            N=size(txt);
            i=0;
            callPutHeader=[];
            while (i<N(1))&&(isempty(callPutHeader)==1)
                i=i+1;
                j=0;
                while (j<N(2))&&(isempty(callPutHeader)==1)
                    j=j+1;
                    if isempty(strfind(lower(char(txt(i,j))), 'c=call, p=put'))==0
                        callPutHeader=[i j];
                    end
                end
            end
            
            if isempty(callPutHeader)==0
                callPutLabels=char(txt{callPutHeader(1)+1:end,callPutHeader(2)});
            else
                err=1;
            end
            if nargin==1
                waitbar(1/tot);
            end
            
            %% Finding expiration dates
            
            % Finding corresponding column
            expDatePos=[];
            i=0;
            while (i<N(1))&&(isempty(expDatePos)==1)
                i=i+1;
                j=0;
                while (j<N(2))&&(isempty(expDatePos)==1)
                    j=j+1;
                    if isempty(strfind(lower(char(txt(i,j))), 'expiration'))==0
                        expDatePos=[i j];
                    end
                end
            end
            
            expDate=[];
            expDateInd=[];
            
            % Finding number of different expiration dates
            N=size(data);
            if isempty(expDatePos)==0

                expDate=datevec(int2str(unique(data(:,expDatePos(2)))),'yyyymmdd');

                if rows(expDate)>1
                    % User selects desired expiration date
                    if nargin==1
                        [~, ind]=selmat(expDate);
                    else
                        ind=1;
                    end

                else
                    ind=1;
                end
                
                 expDateInd=datenum(int2str(data(:,expDatePos(2))),'yyyymmdd')==datenum(expDate(ind,:));
                 expDate=expDate(ind,:);
                 
            else
                if nargin==1
                    msgbox('Expiration date was not found. Possible file corruption.', ...
                        'Importing data', 'error');
                end
            end
            
            if nargin==1
                waitbar(2/tot);
            end
            
            %% Reading observation date
            
            obsDatePos=[];
            
            % Finding observation date

            i=0;
            while (i<N(1))&&(isempty(obsDatePos)==1)
                i=i+1;
                j=0;
                while (j<N(2))&&(isempty(obsDatePos)==1)
                    j=j+1;
                    if isempty(strfind(lower(char(txt(i,j))), 'date of this price'))==0
                        obsDatePos=[i j];
                    end
                end
            end
            
            obsDate=datevec(int2str(unique(data(expDateInd,obsDatePos(2)))),'yyyymmdd');
           
            % If several observation dates are found user selects one
            if rows(obsDate)>1 
                if nargin==1
                    WTitle='Observation date';
                    WMsg=['More than one observation date was detected.' ...
                        'Please select a date and confirm. '];
                    [~, ind]=selmat(obsDate,WTitle,WMsg);
                else
                    ind=1;
                end
            else
                ind=1;
            end
            
            obsDateInd=datenum(int2str(data(:,obsDatePos(2))),'yyyymmdd')==datenum(obsDate(ind,:));
            obsDate=obsDate(ind,:);
            
            if isempty(obsDate)==1
                if nargin==1
                    msgbox('No observation date was not found. Possible file corruption.', ...
                        'Importing data', 'error');
                end
            end
            
            if nargin==1
                waitbar(3/tot);
            end
            
            %% Determining columns of strikes and bid and ask prices
            strikePos=[];
            askPos=[];
            bidPos=[];
            keepOn=1;
            i=0;
            while (keepOn==1)&&(i<N(1))
                i=i+1;
                j=0;
                while (keepOn==1)&&(j<N(2))
                    j=j+1;
                    if isempty(strfind(lower(char(txt(i,j))), 'ask'))==0
                        askPos=[i j];
                    end
                    if isempty(strfind(lower(char(txt(i,j))), 'bid'))==0
                        bidPos=[i j];
                    end
                    if isempty(strfind(lower(char(txt(i,j))), 'strike'))==0
                        strikePos=[i j];
                        tmp=strfind(lower(char(txt(i,j))), 'times');
                        if isempty(tmp)==0
                            ratio=str2num(char(txt{i,j}(tmp+5:end)));
                        end
                    end
                    keepOn=(isempty(askPos)==1)||(isempty(bidPos)==1) ...
                        ||(isempty(strikePos)==1);
                end
            end
            
            if (isempty(askPos)==1)||(isempty(bidPos)==1)||(isempty(strikePos)==1)
                if nargin==1
                    msgbox('Data on option prices was not found. Possible file corruption.', ...
                        'Importing data', 'error');
                end
                err=1;
                error('Data on option prices was not found. Possible file corruption.');
            end
            
            if nargin==1
                waitbar(4/tot);
            end
            
            %% Reading call and put prices
            if err==0
                arg=(expDateInd)&(obsDateInd);
                callPutLabels=callPutLabels(arg);
                data=data(arg,:);
                C_b=data(callPutLabels=='C',bidPos(2));
                C_a=data(callPutLabels=='C',askPos(2));
                K_C=data(callPutLabels=='C',strikePos(2));
                C=(C_a+C_b)/2;
                P_b=data(callPutLabels=='P',bidPos(2));
                P_a=data(callPutLabels=='P',askPos(2));
                K_P=data(callPutLabels=='P',strikePos(2));
                P=(P_a+P_b)/2;
            end
            
            if nargin==1
                waitbar(5/tot);
            end
            
            %% Setting final structure
            
            if err==1
                if nargin==1
                    msgbox('Data on option prices was not found. Possible file corruption.', ...
                        'Importing data', 'error');
                    error('Data on option prices was not found. Possible file corruption.');
                end
            else
                % Finding common strikes
                [K,ia,ib] = intersect(K_C,K_P);
                C=C(ia);
                P=P(ib);
                % VI_p=VI_p(ib);
                % VI_c=VI_c(ia);
                
                P_a=P_a(ib);
                P_b=P_b(ib);
                C_a=C_a(ia);
                C_b=C_b(ia);
                
                % Sorting data
                [K,index]=sort(K/ratio);
                call=C(index);
                
                put=P(index);
                call_a=C_a(index);
                call_b=C_b(index);
                put_a=P_a(index);
                put_b=P_b(index);
                
                %max_K=find(call_b==min(call_b),1);
                max_K=length(K);
                
                K=K(1:max_K);
                call=call(1:max_K);
                put=put(1:max_K);
                call_a=call_a(1:max_K);
                call_b=call_b(1:max_K);
                put_a=put_a(1:max_K);
                put_b=put_b(1:max_K);
                
                % Moment vector (empty)
                m=[];
                
                % Interest rate (set to zero)
                r=0;
                
                %% Exporting data
                matlabData=struct;
                matlabData.K=K;
                matlabData.call=call;
                matlabData.put=put;
                matlabData.call_a=call_a;
                matlabData.call_b=call_b;
                matlabData.put_a=put_a;
                matlabData.put_b=put_b;
                matlabData.obsDate=obsDate;
                matlabData.expDate=expDate;
                matlabData.r=r;
                matlabData.m=m;
                if nargin==1
                    waitbar(6/tot);
                end
            end
        catch ME
            matlabData=[];
        end
    case 'csv'
        
        %% Reading data
        fileID=fopen(fname);
        try
            headers=textscan(fileID, '%s',1,'delimiter', '\b');
            fclose(fileID);
        catch ME
            fclose(fileID);
        end
        headers=textscan(headers{1}{1},'%s','delimiter',',');
        headers=headers{1};
        data=importdata(fname,',');
        txt=cell(length(data),length(headers));
        for i=1:length(txt)
            a=textscan(data{i},'%s','delimiter',',');
            a=a{1}';
            txt(i,:)=a;
        end
        if nargin==1
            waitbar(1/tot);
        end
        
        %% Handling data
        try
            err=0;
            %% Finding call and put labels
            callPutHeader=find(strcmp(headers', 'cp_flag'));
            if isempty(callPutHeader)==0
                callPutLabels=char(txt{1:end,callPutHeader});
            else
                err=1;
            end
            if nargin==1
                waitbar(2/tot);
            end
            
            %% Finding expiration dates
            
            % Finding corresponding column
            expDatePos=find(strcmp(headers', 'exdate'));
            
            expDate=[];
            expDateInd=[];
            %prDate='null';
            
            % Finding number of different expiration dates
            N=rows(txt);
            
            if isempty(expDatePos)==0
                expDate=datevec(unique(txt(:,expDatePos)),'yyyymmdd');
                
                if rows(expDate)>1
                    % User selects desired expiration date
                    if nargin==1
                        [~, ind]=selmat(expDate);
                    else
                        ind=1;
                    end

                else
                    ind=1;
                end
                
                 expDateInd=datenum(txt(:,expDatePos),'yyyymmdd')==datenum(expDate(ind,:));
                 expDate=expDate(ind,:);
            else
                if nargin==1
                    msgbox('Expiration date was not found. Possible file corruption.', ...
                        'Importing data', 'error');
                end
            end
            if nargin==1
                waitbar(3/tot);
            end
            
            %% Reading observation date
            
            obsDate=[];
            
            % Finding corresponding column
            obsDatePos=find(strcmp(headers', 'date'));
            
            obsDate=datevec(unique(txt(expDateInd,obsDatePos)),'yyyymmdd');
           
            % If several observation dates are found user selects one
            if rows(obsDate)>1 
                if nargin==1
                    WTitle='Observation date';
                    WMsg=['More than one observation date was detected.' ...
                        'Please select a date and confirm. '];
                    [~, ind]=selmat(obsDate,WTitle,WMsg);
                else
                    ind=1;
                end
            else
                ind=1;
            end
            
            obsDateInd=datenum(txt(:,obsDatePos),'yyyymmdd')==datenum(obsDate(ind,:));
            obsDate=obsDate(ind,:);
            
            if isempty(obsDate)==1
                if nargin==1
                    msgbox('No observation date was not found. Possible file corruption.', ...
                        'Importing data', 'error');
                end
            end
            
            
            if nargin==1
                waitbar(4/tot);
            end
            
            %% Reading call and put prices
            bidPos=find(strcmp(headers', 'best_bid'));
            askPos=find(strcmp(headers', 'best_offer'));
            strikePos=find(strcmp(headers', 'strike_price'));
            
            if err==0
                %arg=(expDateInd(ind):expDateInd(ind+1)-1);
                arg=(expDateInd)&(obsDateInd);
                callPutLabels=callPutLabels(arg);
                txt=txt(arg,:);
                C_b=str2num(char(txt(callPutLabels=='C',bidPos)));
                C_a=str2num(char(txt(callPutLabels=='C',askPos)));
                K_C=str2num(char(txt(callPutLabels=='C',strikePos)));
                C=(C_a+C_b)/2;
                P_b=str2num(char(txt(callPutLabels=='P',bidPos)));
                P_a=str2num(char(txt(callPutLabels=='P',askPos)));
                K_P=str2num(char(txt(callPutLabels=='P',strikePos)));
                P=(P_a+P_b)/2;
                ratio=10^(round(log10(K_C(1)/C_a(1))));
            end
            
            if nargin==1
                waitbar(5/tot);
            end
            
            %% Setting final structure
            if err==1
                if nargin==1
                    msgbox('Data on option prices was not found. Possible file corruption.', ...
                        'Importing data', 'error');
                    error('Data on option prices was not found. Possible file corruption.');
                end
            else
                % Finding common strikes
                [K,ia,ib] = intersect(K_C,K_P);
                C=C(ia);
                P=P(ib);
                % VI_p=VI_p(ib);
                % VI_c=VI_c(ia);
                
                P_a=P_a(ib);
                P_b=P_b(ib);
                C_a=C_a(ia);
                C_b=C_b(ia);
                
                % Sorting data
                [K,index]=sort(K/ratio);
                call=C(index);
                
                put=P(index);
                call_a=C_a(index);
                call_b=C_b(index);
                put_a=P_a(index);
                put_b=P_b(index);
                
                %max_K=find(call_b==min(call_b),1);
                max_K=length(K);
                
                K=K(1:max_K);
                call=call(1:max_K);
                put=put(1:max_K);
                call_a=call_a(1:max_K);
                call_b=call_b(1:max_K);
                put_a=put_a(1:max_K);
                put_b=put_b(1:max_K);
                
                % Moment vector (empty)
                m=[];
                
                % Interest rate (set to zero)
                r=0;
                
                %% Exporting data
                matlabData=struct;
                matlabData.K=K;
                matlabData.call=call;
                matlabData.put=put;
                matlabData.call_a=call_a;
                matlabData.call_b=call_b;
                matlabData.put_a=put_a;
                matlabData.put_b=put_b;
                matlabData.obsDate=obsDate;
                matlabData.expDate=expDate;
                matlabData.r=r;
                matlabData.m=m;
                if nargin==1
                    waitbar(6/tot);
                end
            end
            
        catch ME
            matlabData=[];
            if nargin==1
                close(waitMessage);
            end
        end
    otherwise
        matlabData=[];
        EM=['File extension ''' ext ''' is not supported'];
        if nargin==1
            msgbox(EM,'Error','error');
        end
end

if nargin==1
    close(waitMessage);
end