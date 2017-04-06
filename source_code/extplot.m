%% EXTPLOT - automatizes some routines
%
% See also: dostuff
%
% Last update: September 2016

function [hd,hc,hp]=extplot(c, kerpar, handles)

%% Checking input
if nargin<3
    error('Not enough input')
end

inData=handles.inData;
if length(inData)>=5
    r=inData{5};
else
    r=0;
end

if length(inData)>=6
    obsDate=inData{6};
end

%% Getting strikes and option prices
K=inData{1};
call=inData{2};
put=inData{3};
K0=K(1);
KK=K;
K=K-K0;
observedData=[call put];

%% Getting information on kernel
kernelDensity=handles.kernelDensity;
kernel=kernelDensity.name;
kf=@(x) kernelDensity.pdf(x,kerpar);

N=length(K);
NP=length(c)-1;
KerMom=zeros(2*NP+1,1);

IncMom1=zeros(1,N);
I1=zeros(1,N);
IncMomL1=zeros(1,N);
J1=zeros(1,N);

if isfield(kernelDensity,'i_thMoment')==1
    for i=0:2*NP
        KerMom(i+1)=kernelDensity.i_thMoment(i,kerpar);
    end
else
    for i=0:2*NP
        KerMom(i+1)=integral(@(x) x.^i.*kf(x),0,Inf);
    end
end

% Incomplete moments
for j=1:N % Strikes loop
    Kstar=K(j);
    if (isfield(kernelDensity,'i_thIncUMoment')==1)&&(isfield(kernelDensity,'i_thIncLMoment')==1)
        I1(j)=kernelDensity.i_thIncUMoment(Kstar,1,kerpar);
        if Kstar==0
            J1(j)=0;
        else
            J1(j)=kernelDensity.i_thIncLMoment(Kstar,1,kerpar);
        end
        IncMom1(j)=kernelDensity.i_thIncUMoment(Kstar,0,kerpar);
        if Kstar==0
            IncMomL1(j)=0;
        else
            IncMomL1(j)=kernelDensity.i_thIncLMoment(Kstar,0,kerpar);
        end
    else
        I1(j)=integral(@(x) x.*kernelDensity.pdf(x,kerpar),Kstar,Inf);
        if Kstar==0
            J1(j)=0;
        else
            J1(j)=integral(@(x) x.*kernelDensity.pdf(x,kerpar),0,Kstar);
        end
        IncMom1(j)=integral(@(x) kernelDensity.pdf(x,kerpar),Kstar,Inf);
        if Kstar==0
            IncMomL1(j)=0;
        else
            IncMomL1(j)=integral(@(x) kernelDensity.pdf(x,kerpar),0,Kstar);
        end
    end
    
end

% Retrieving Bid and Ask prices
if length(inData)==11
    
    inData=handles.inData;
    call_a=inData{8};
    call_b=inData{9};
    put_a=inData{10};
    put_b=inData{11};
    a=[call_a;put_a];
    b=[call_b;put_b];
    BA=median(a-b);
else
    BA=[];
end
m=inData{4};
r=inData{5};
estimationType=handles.mode;
mode=handles.plotScale;
plotType=handles.plotType;
theme=handles.theme;
alreadyComputed=handles.DoStuff;
historyEl=handles.historyEl;
history=handles.history(historyEl);
msg_txt=handles.msg_txt;
log_txt=handles.log_txt;
results_txt=handles.results_txt;
epsilon=handles.epsilon;
msgType=handles.msgType;
cuttingThreshold=handles.cuttingThresholdPlots;
method=handles.method.String{handles.method.Value};
clear handles inData;

if isempty(alreadyComputed.obsCall)==1
    alreadyComputed.obsCall=call;
end
if isempty(alreadyComputed.obsPut)==1
    alreadyComputed.obsPut=put;
end
if strcmp(plotType,'ivols')==1
    T=alreadyComputed.maturity;
    D=exp(-r*T);
    F=m(1);
    if isempty(alreadyComputed.obsIVCall)==1
        alreadyComputed.obsIVCall=blsimpv(D*F, KK, r, T, D*call, [], 0, 1e-6,{'call'});
    end
    obsivcall=alreadyComputed.obsIVCall;
    if isempty(alreadyComputed.obsIVPut)==1
        alreadyComputed.obsIVPut=blsimpv(D*F, KK, r, T, D*put, [], 0, 1e-6,{'put'});
    end
    obsivput=alreadyComputed.obsIVPut;
end

mess=[];
bgCol=[1 1 1];
baCol=.3+.65*sin(bgCol*(pi/2));
gridCol=[1 1 1]-bgCol;
lgdCol=gridCol;
co=[0 0 0;                 % Black
    0.8500 0.3250 0.0980;  % Red 
    0 0.4470 0.7410;       % Blue 
    0.4660 0.6740 0.1880;  % Green  
    0.9290 0.6940 0.1250;  % Yellow
    0.4940 0.1840 0.5560;  % Violet
    0.3010 0.7450 0.9330;  % Light Blue
    0.6350 0.0780 0.1840]; % Dark Red
set(groot,'defaultAxesColorOrder',co);

%% Finding RND

%KK(end)=KK(end-1)+3;
[f,~]=ortapprox(kf, KerMom, c);
if (integral(@(x) f(x-K0)',K0,KK(end))>1-1e-6)&& ...
       (integral(@(x) f(x-K0)',K0,KK(end))<1+1e-5)
    maxK=KK(end);
else
    maxK=KK(end);
    dK=10^(floor(log10(m(1)))-1);
    supK=m(1)+60*sqrt(m(2)-m(1)^2);
    exit=0;
    while exit==0
        maxK=maxK+dK;
        if ((integral(@(x) f(x-K0)',K0,maxK)>1-1e-6)&& ...
           (integral(@(x) f(x-K0)',K0,maxK)<1+1e-5))|| ...
           (maxK>=supK)
          exit=1;
        end
    end
end
%KK(end)=maxK;
dmn=0:min(0.05,min(diff(KK))/10):maxK;
f=@(x) real(f(x-K0)'.*(x<=max(dmn)));
kf=@(x) real(kf(x-K0));
if min(f(dmn))<0
    mess=['>> Magnitude of truncated neg. mass is < 1e' ...
         int2str(ceil(log10(abs(integral(@(x) abs(f(x)),K0,maxK)-1))))];
    f=@(x) max(f(x),0);
else
    mess=[];
end

lgdTxt=[];

%% Computing prices

% Call
if isempty(alreadyComputed.appCall)==1
    appcall=zeros(size(KK));
    for j=1:length(KK)
        appcall(j)=integral(@(x) (x-KK(j)).*f(x), KK(j), KK(end));
    end
    
    alreadyComputed.appCall=appcall;
else
    appcall=alreadyComputed.appCall;
end

% Put
if isempty(alreadyComputed.appPut)==1
    appput=zeros(size(KK));
    for j=1:length(K)
        if K0==KK(j)
            appput(j)=0;
        else
            appput(j)=integral(@(x) (KK(j)-x).*f(x), K0, KK(j));
        end
    end
    alreadyComputed.appPut=appput;
else
    appput=alreadyComputed.appPut;
end

% Order 0
if (isempty(alreadyComputed.appCall0)==1)||...
        (isempty(alreadyComputed.appPut0)==1)
    expans=objfunc(K, KerMom(1), IncMom1, I1, IncMomL1, J1, c(1));
    appcall0=real(expans(:,1));
    alreadyComputed.appCall0=appcall0;
    appput0=real(expans(:,2));
    alreadyComputed.appPut0=appput0;
else
    appcall0=alreadyComputed.appCall0;
    appput0=alreadyComputed.appPut0;
end

%% Density plots
if exist('call_a','var')==0
    ind=(appcall0>0)&(appput0>0)&(appcall>0)&(appput>0)& ...
        (observedData(:,1)>0)&(observedData(:,2)>0);
else
    ind=(appcall0>0)&(appput0>0)&(appcall>0)&(appput>0)& ...
        (call_b>0)&(put_b)>0;
end
          
plDmn=min(K0,ceil(.9*min(KK(ind)))):min(diff(KK(ind)))/20:1.25*max(KK(ind));
hd=figure;
if strcmp(mode,'plain')==1 
    plot(plDmn,kf(plDmn),'-',plDmn,f(plDmn),'LineWidth',1);
elseif strcmp(mode,'square')==1
    plot(plDmn.^2,.5*kf(plDmn)./plDmn,':',plDmn.^2,.5*f(plDmn)./plDmn,'LineWidth',1);
elseif strcmp(mode,'semilog')==1
    semilogy(plDmn,kf(plDmn),':',plDmn,f(plDmn),'LineWidth',1);
else
    mess=[mess; {'>> Error: Density scale not recognized'}];
end

lgdTxt=cell(1,length(history)+2);

if length(history)>=1
    hold on;
    for i=length(history):-1:1
        try
            hNP=length(history(i).c)-1;
            hKerMom=zeros(2*hNP+1,1);
            hkerpar=history(i).kerpar;
            
            % Probability density function
            hkf=@(x) history(i).kernelDensity.pdf(x,hkerpar);
                       
            % Moments
            if isfield(kernelDensity,'i_thMoment')==1
                for j=0:2*hNP
                    hKerMom(j+1)=history(i).kernelDensity.i_thMoment(j,hkerpar);
                end
            else
                for j=0:2*hNP
                    hKerMom(j+1)=integral(@(x) x.^j.*hkf(x),0,Inf);
                end
            end
            
            [ft,~]=ortapprox(hkf, hKerMom, history(i).c);
            ft=@(x) real(ft(x-history(i).K0)'.*(x<=history(i).Km));
            %kft=@(x) real(kft(x-K0));
            if min(ft(0:history(i).K0/200:history(i).Km))<0
                ft=@(x) max(ft(x),0);
            end           
            if strcmp(mode,'plain')==1
                plot(plDmn,ft(plDmn),'-.','LineWidth',3);
            elseif strcmp(mode,'square')==1
                plot(plDmn.^2,.5*ft(plDmn)./plDmn,'-.','LineWidth',3);
            elseif strcmp(mode,'semilog')==1
                semilogy(plDmn,ft(plDmn),'-.','LineWidth',3);
            else
                error('Density scale not recognized.')
            end
            
            lgdTxt{i+2}=['Expansion (' history(i).kernelDensity.name ', ' char(history(i).method) ...
                ', order ' int2str(length(history(i).c)-1) ')'];
        catch ME
            mess=[mess; {' '; '> Warning: strikes of history element are not matching current data.'}];
        end
    end
    lgdTxt(3:end)=lgdTxt(end:-1:3);
end

hold off;
grid on;
h=gca;
h.FontSize=18;
[val,pos]=min(abs(h.XTick-K0));
if val<=0.2*min(diff(h.XTick));
    h.XTick(pos)=K0;
else
    h.XTick=union(h.XTick,K0);
end

h.XTickLabel{find(strcmp(h.XTickLabel,num2str(K0))==1)}='K_0';
h.Color=bgCol;
h.XColor=gridCol;
h.YColor=gridCol;
hold off;
lgdTxt{1}=['Kernel (' kernel ')'];
lgdTxt{2}=['Expansion (' kernel ', ' method ', order ' int2str(length(c)-1) ')'];
hl=legend(lgdTxt);
hl.TextColor=lgdCol;
hl.Location='best';
axis tight;
xlim([0.75*min(KK(ind)), 1.25*max(KK(ind))]);

%% Computing ivols
if strcmp(plotType,'ivols')==1
    if isempty(alreadyComputed.appIVCall)
        appivcall=blsimpv(D*F, KK, r, T, D*appcall, [], 0, 1e-6,{'call'});
        alreadyComputed.appIVCall=appivcall;
    else
        appivcall=alreadyComputed.appIVCall;
    end
    
    if isempty(alreadyComputed.appIVPut)
        appivput=blsimpv(D*F, KK, r, T, D*appput, [], 0, 1e-6,{'put'});
        alreadyComputed.appIVPut=appivput;
    else
        appivput=alreadyComputed.appIVPut;
    end
    
    if isempty(alreadyComputed.appIVCall0)
        appivcall0=blsimpv(D*F, KK, r, T, D*appcall0, [], 0, 1e-6,{'call'});
        alreadyComputed.appIVCall0=appivcall0;
    else
        appivcall0=alreadyComputed.appIVCall0;
    end
    
    if isempty(alreadyComputed.appIVPut0)
        appivput0=blsimpv(D*F, KK, r, T, D*appput0, [], 0, 1e-6,{'put'});
        alreadyComputed.appIVPut0=appivput0;
    else
        appivput0=alreadyComputed.appIVPut0;
    end
end

%% Plotting

% Re-determining strictly positive prices
ind=(appcall0>0)&(appput0>0)&(appcall>0)&(appput>0)& ...
   (observedData(:,1)>0)&(observedData(:,2)>0);

if strcmp(plotType,'prices')==1
    hc=figure;
    plot(KK(ind),appcall0(ind),'--',KK(ind),appcall(ind),KK(ind), observedData((ind),1),'*','LineWidth',3);
    h=gca;
    h.FontSize=18;
    h.Color=bgCol;
    h.XColor=gridCol;
    h.YColor=gridCol;
    grid on;
    hl=legend('Induced by kernel',['Approximation order ' num2str(length(c)-1)],'Market');
    hl.TextColor=lgdCol;
    hl.Location='best';
    hl.Orientation='vertical';
    hp=figure;
    plot(KK(ind),appput0(ind),'--',KK(ind),appput(ind),KK(ind),observedData((ind),2),'*','LineWidth',3);
    grid on;
    h=gca;
    h.FontSize=18;
    h.Color=bgCol;
    h.XColor=gridCol;
    h.YColor=gridCol;
    hl=legend('Induced by kernel',['Approximation order ' num2str(length(c)-1)],'Market');
    hl.TextColor=lgdCol;
    hl.Location='best';
    hl.Orientation='vertical';
elseif strcmp(plotType, 'ivols')==1
    sLim=1.25*max([obsivcall(ind); obsivput(ind)]);
    iLim=0.75*min([obsivcall(ind); obsivput(ind)]);
    hc=figure;
    plot(KK(ind),appivcall0(ind),'--',KK(ind),appivcall(ind),KK(ind), obsivcall(ind),'*','LineWidth',3);
    axis([-inf inf iLim sLim]);
    h=gca;
    h.FontSize=18;
    h.Color=bgCol;
    h.XColor=gridCol;
    h.YColor=gridCol;
    grid on;
    hl=legend('Induced by kernel',['Approximation order ' num2str(length(c)-1)],'Market');
    hl.TextColor=lgdCol;
    hl.Location='best';
    hl.Orientation='vertical';
    hp=figure;
    plot(KK(ind),appivput0(ind),'--',KK(ind),appivput(ind),KK(ind),obsivput(ind),'*','LineWidth',3);
    axis([-inf inf iLim sLim]);
    grid on;
    h=gca;
    h.FontSize=18;
    h.Color=bgCol;
    h.XColor=gridCol;
    h.YColor=gridCol;
    hl=legend('Induced by kernel',['Approximation order ' num2str(length(c)-1)],'Market');
    hl.TextColor=lgdCol;
    hl.Location='best';
    hl.Orientation='vertical';
elseif strcmp(plotType,'residuals')==1
    if isempty(epsilon)==0
        indCall=(observedData(:,1)>cuttingThreshold)&(observedData(:,2)>0);
        indPut=(observedData(:,2)>cuttingThreshold)&(observedData(:,1)>0);
        filteringInd=indCall&indPut;
        if length(epsilon)==2*sum(filteringInd);
            eC=epsilon(1:sum(filteringInd));
            eP=epsilon(sum(filteringInd)+1:end);
        else
            eC=epsilon(1:length(epsilon)/2);
            eP=epsilon(length(epsilon)/2+1:end);
            eC=eC(filteringInd);
            eP=eP(filteringInd);
        end
        sLim=max([eC; eP]);
        if sLim>=0
            sLim=1.25*sLim;
        else
            sLim=0.75*sLim;
        end
        iLim=min([eC; eP]);
        if iLim>=0
            iLim=0.75*iLim;
        else
            iLim=1.25*iLim;
        end
        hc=figure;
        hold on;
        plot(KK(filteringInd),eC,'*-');
        avgPlot=plot(KK(filteringInd),mean(eC)*ones(size(eC)),'--','LineWidth',3);
        axis([-inf inf iLim sLim]);
        hold off;
        h=gca;
        h.FontSize=18;
        h.Color=bgCol;
        h.XColor=gridCol;
        h.YColor=gridCol;
        grid on;
        box on;
        %hl=legend(avgPlot,'Average error');
        hl.TextColor=lgdCol;
        hl.Location='best';
        hl.Orientation='vertical';
        hp=figure;
        hold on;
        plot(KK(filteringInd),eP,'*-');
        avgPlot=plot(KK(filteringInd),mean(eP)*ones(size(eP)),'--','LineWidth',3);
        axis([-inf inf iLim sLim]);
        hold off;
        grid on;
        box on;
        h=gca;
        h.FontSize=18;
        h.Color=bgCol;
        h.XColor=gridCol;
        h.YColor=gridCol;
        %hl=legend(avgPlot,'Average error');
        hl.TextColor=lgdCol;
        hl.Location='best';
        hl.Orientation='vertical';
    end
else
    error('Plot type was not recognized. Please check code in gui.m');
end

end