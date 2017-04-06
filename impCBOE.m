function matlabData=impCBOE(varargin)

fname=varargin{1};

%% Reading data according to file extension
if strcmp(fname(end-2:end),'dat')==1
    fileID=fopen(fname);
    C = textscan(fileID, ...
        '%s %s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter',',');
    fclose(fileID);
    try
        txt=cell(length(C{1}),length(C));
    catch ME
        matlabData=[];
    end
    for i=1:14
        txt(:,i)=C{i};
    end
else
    try
        [data,txt]=xlsread(fname);
    catch ME
        matlabData=[];  
    end
end
tot=6;
N=size(txt);
if nargin==1
    waitMessage=waitbar(0, 'Importing data from CBOE format...');
end

%% Main Code
try
    %% Reading observation date
    obsDatePos=[];
    i=0;
    while (isempty(obsDatePos)==1)&&(i<N(1))
        i=i+1;
        j=0;
        while (isempty(obsDatePos)==1)&&(j<N(2))
            j=j+1;
            if sum(char(txt(i,j))=='@')==1
                obsDatePos=[i j];
            end
        end
    end
    
    if isempty(obsDatePos)==1
        if nargin==1
            msgbox('Observation date was not found. Possible file corruption.', ...
                'Importing data', 'error');
        end
    else
        obsDate=datevec(txt(obsDatePos(1),obsDatePos(2)),'mmm dd yyyy');
    end
    
    if nargin==1
        waitbar(1/tot);
    end
    
    %% Determining columns of call and put options
    callPos=[];
    putPos=[];
    keepOn=1;
    i=0;
    while (keepOn==1)&&(i<N(1))
        i=i+1;
        j=0;
        while (keepOn==1)&&(j<N(2))
            j=j+1;
            if strcmp(lower(char(txt(i,j))),'calls')==1
                callPos=[i j];
            end
            if strcmp(lower(char(txt(i,j))),'puts')==1
                putPos=[i j];
            end
            keepOn=(isempty(callPos)==1)||(isempty(putPos)==1);
        end
    end
    
    if (isempty(callPos)==1)||(isempty(putPos)==1)
        if nargin==1
            msgbox('Data on option prices was not found. Possible file corruption.', ...
                'Importing data', 'error');
            error('Data on option prices was not found. Possible file corruption.');
        end
    end
     
    %% Reading expiration dates
    expDate=[];
    expDateInd=[];
    obsY=obsDate(1);
    months={'jan','feb','mar','apr','jun','jul','aug','sep','oct','nov','dec'};
    prMth=0;
    for i=1:N(1)
        tmp=lower(char(txt(i,callPos(2))));
        if isempty(tmp)==0
            mthNum=find(strcmp(tmp(min(length(tmp),4):min(6,length(tmp))),months));
            if (isempty(mthNum)==0)&&(ne(mthNum,prMth)==1)
                prMth=mthNum;
                expDate=[expDate; datevec(tmp(1:6),'dd mmm')];
                expDateInd=[expDateInd; i];
            end
        end
    end
    
    expDate(:,1)=obsY;
    chY=find(expDate(:,2)==12);
    if isempty(chY)==0
        chY=[chY; rows(expDate)];
        for i=1:length(chY)-1
            expDate(chY(i)+1:chY(i+1),1)=obsY+i;
        end
    end
    
    if rows(expDate)>1
        % User selects desired expiration date
        if nargin==1
            [h, ind]=selmat(expDate);
        else
            ind=1;
        end
        expDateInd=[expDateInd; N(1)+1];
        expDate=expDate(ind,:);
    else
        ind=1;
        expDateInd=[1; rows(txt)];
    end

    errFlag=0;
    if nargin==1
        waitbar(2/tot);
    end
    
    %% Reading call options
    
    % Discharging call options marked with other suffixes
    labels=txt(expDateInd(ind):expDateInd(ind+1)-1,callPos(2));
    strInd=[];
    for i=1:length(labels)
        tmp=labels{i};
        if isempty(tmp)==0
            if (ne(tmp(end-2),'-')==1)&&ne(tmp(end-2),'.')
                strInd=[strInd;i];
            end
        end
    end
    
    % Finding strikes related to call options
    K_C=txt(expDateInd(ind):expDateInd(ind+1)-1,callPos(2));
    for i=1:length(K_C)
        K_C{i}=K_C{i}(8:12);
    end
    K_C=str2num(char(K_C));
    K_C=K_C(strInd);
    
    if nargin==1
        waitbar(3/tot);
    end
    
    % Finding bid and ask prices
    if strcmp(lower(char(txt(callPos(1),callPos(2)+3))),'bid')==1
        C_b=str2num(char(txt(expDateInd(ind):expDateInd(ind+1)-1,callPos(2)+3)));
        C_b=C_b(strInd);
    else
        errFlag=1;
    end
    
    if (errFlag==0)&&(strcmp(lower(char(txt(callPos(1),callPos(2)+4))),'ask')==1)
        C_a=str2num(char(txt(expDateInd(ind):expDateInd(ind+1)-1,callPos(2)+4)));
        C_a=C_a(strInd);
    else
        errFlag=1;
    end
    
    % Setting mid-prices
    if (errFlag==0)
        if isequal(C_a,C_b)==1
            C_a=[];
            C_b=[];
            if (strcmp(lower(char(txt(callPos(1),callPos(2)+1))),'last sale')==1)
                C=str2num(char(txt(expDateInd(ind):expDateInd(ind+1)-1,callPos(2)+1)));
                C=C(strInd);
            else
                errFlag=1;
            end
        else
            C=(C_a+C_b)/2;
        end
    end
    
    if nargin==1
        waitbar(4/tot);
    end
    
    %% Reading put options
    
    % Discharging put options marked with other suffixes and/or 
    % with different maturities
    labels=txt(expDateInd(ind):expDateInd(ind+1)-1,putPos(2));
    strInd=[];
    for i=1:length(labels)
        tmp=labels{i};
        currMat=datevec(tmp(1:6),'dd mmm');
        if isempty(tmp)==0
            if (ne(tmp(end-2),'-')==1)&&ne(tmp(end-2),'.')&& ...
                    (isequal(currMat(2:end),expDate(2:end))==1)
                strInd=[strInd;i];
            end
        end
    end
    
    % Finding strikes related to call options
    K_P=txt(expDateInd(ind):expDateInd(ind+1)-1,putPos(2));
    for i=1:length(K_P)
        K_P{i}=K_P{i}(8:12);
    end
    K_P=str2num(char(K_P));
    K_P=K_P(strInd);
    
    % Finding put options
    
    if (errFlag==0)&&strcmp(lower(char(txt(putPos(1),putPos(2)+3))),'bid')==1
        P_b=str2num(char(txt(expDateInd(ind):expDateInd(ind+1)-1,putPos(2)+3)));
        P_b=P_b(strInd);
    else
        errFlag=1;
    end
    
    if (errFlag==0)&&(strcmp(lower(char(txt(putPos(1),putPos(2)+4))),'ask')==1)
        P_a=str2num(char(txt(expDateInd(ind):expDateInd(ind+1)-1,putPos(2)+4)));
        P_a=P_a(strInd);
    else
        errFlag=1;
    end
    
    % Setting mid-prices
    if (errFlag==0)
        if isequal(P_a,P_b)==1
            P_a=[];
            P_b=[];
            if (strcmp(lower(char(txt(putPos(1),putPos(2)+1))),'last sale')==1)
                P=str2num(char(txt(expDateInd(ind):expDateInd(ind+1)-1,putPos(2)+1)));
                P=P(strInd);
            else
                errFlag=1;
            end
        else
            P=(P_a+P_b)/2;
        end
    end
    
    if nargin==1
        waitbar(5/tot);
    end
    
    %% Setting final structure
    
    if errFlag==1
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
        if isempty(P_a)==0
            P_a=P_a(ib);
        end
        if isempty(P_b)==0
            P_b=P_b(ib);
        end
        if isempty(C_a)==0
            C_a=C_a(ia);
        end
        if isempty(C_b)==0
            C_b=C_b(ia);
        end
        
        % Sorting data
        [K,index]=sort(K);
        call=C(index);
        
        put=P(index);
        if isempty(C_a)==0
            call_a=C_a(index);
        else
            call_a=[];
        end
        if isempty(C_b)==0
            call_b=C_b(index);
        else
            call_b=[];
        end
        if isempty(P_a)==0
            put_a=P_a(index);
        else
            put_a=[];
        end      
        if isempty(P_b)==0
            put_b=P_b(index);
        else
            put_b=[];
        end
        
%         max_K=find(call_b==min(call_b),1);
%         max_K=length(K);
%         K=K(1:max_K);
%         call=call(1:max_K);
%         put=put(1:max_K);
%         call_a=call_a(1:max_K);
%         call_b=call_b(1:max_K);
%         put_a=put_a(1:max_K);
%         put_b=put_b(1:max_K);
%         
        % Moment vector (empty)
        m=[];
        
        % Interest rate (set to zero)
        r=0;
        
        % Exporting data
        matlabData=struct;
        matlabData.K=K;
        matlabData.call=call;
        matlabData.put=put;
        matlabData.m=m;
        if isempty(call_a)==0
            matlabData.call_a=call_a;
        end
        if isempty(call_b)==0
            matlabData.call_b=call_b;
        end
        if isempty(put_a)==0
            matlabData.put_a=put_a;
        end
        if isempty(put_b)==0
            matlabData.put_b=put_b;
        end
        matlabData.obsDate=obsDate;
        matlabData.expDate=expDate;
        matlabData.r=r;
        if nargin==1
            waitbar(6/tot);
        end
    end

catch ME
    matlabData=[];
end

if nargin==1
    close(waitMessage);
end