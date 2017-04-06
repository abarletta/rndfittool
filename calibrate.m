%% CALIBRATE - ortogonal expansions calibration
%
% [c,kerpar,estimationResults,extime,msg_log,msg_results,msgType]= ...
%     calibrate(inData, kernel, order, mode, regressionPriority, ... 
%     cuttingThreshold, PCAThreshold, msg_txt, msg_log, msg_results, msgType)
%
% This function calibrates a family of densities obtained by ortogonal 
% expansions around a fixed kernel to some call and put option prices.
% Objective function is specified in objfunc.m and target data is loaded
% from a file. 
%
%
% See also: objfunc, ortapprox, dostuff
%
% Last modified: March 2017

function [c,kerpar,estimationResults,extime,msg_log,msg_results,msgType]= ...
    calibrate(inData, kernelDensity, order, mode, regressionPriority, restrictMean,... 
    cuttingThreshold, PCAThreshold, msg_txt, msg_log, msg_results, msgType)

warning off all;
tstart=tic;

%% Checking input

if nargin==12
    if isempty(msg_log)==1
        printMode='cmd';
    else
        printMode='gui';
    end
else
    printMode='cmd';
end

if nargin<3
    error('Not enough input')
end
if length(inData)<4
    error('Input data corrupted or in wrong format')
end

%% Loading and checking data

if length(inData)>=5
    r=inData{5};
else
    r=0;
end

if length(inData)>=6
    obsDate=inData{6};
end
K=inData{1};
call=inData{2};
put=inData{3};
m=inData{4};
if exist('call','var')+exist('put','var')+exist('K','var')+exist('m','var')<4
    error('Corrupted or missing data.')
end
szK=size(K);
szput=size(put);
szcall=size(call);
szm=size(m);
if szK(2)>1
    error('K must be a column vector')
end
if sum(ne(szK,szput))+sum(ne(szK,szcall))>0
    error('K, put and call must have the same length')
end
if or(szm(1)>szm(2),ne(szm(2),2)==1)
    error('m must have two elements and be a row vector')
end

%% Adjusting input
% Change this value to rescale data (default: ratio=1)
ratio=1;
% Finding prices above threshold set by user
indCall=(call>cuttingThreshold)&(put>0);
indPut=(put>cuttingThreshold)&(call>0);
filterInd=indCall&indPut;
call=call(filterInd);
put=put(filterInd);
observedData=ratio*[call put];
% Rescaling strike interval and initializing moments
K0=K(1);
Kmax=K(end)-K0;
K=K(filterInd);
K=ratio*(K-K0);
m=[ratio ratio^2].*(m+[-K0, -2*K0*m(1)+K0^2]);

%% Graphic output

currMsg={'ESTIMATION RESULTS'; ' ';...
    ['Kernel: ' kernelDensity.name]; ...
    ['Order: ' int2str(order)]};
if strcmp(printMode,'cmd')==1
    for rnum=1:length(currMsg)
        fprintf([currMsg{rnum} '\n']);
    end 
else
    msgType='log';
    msg_log=[msg_log; '>> Running estimation'];
    msg_results=currMsg;
    if strcmp(msgType,'log')==1
        msg_txt.String=msg_log;
        msg_txt.Style='listbox';
        msg_txt.Enable='inactive';
        currPos=length(msg_txt.String);
        msg_txt.Value=currPos;
        drawnow;
    end
end
if (exist('obsDate','var'))&&(length(obsDate)==6)
    currMsg=['Data observed on: ' datestr(obsDate,'dd-mmm-yyyy')];
    if strcmp(printMode,'cmd')==1
        fprintf(currMsg);
        fprintf('\n');
    else
        msg_results=[msg_results; currMsg];
    end
end

%% Calibration of kernel parameters

currMsg='>> Determining kernel parameters   ';
if strcmp(printMode,'cmd')==1
    fprintf('\n[\b<strong>%s</strong>]\b\n',currMsg);
else
    msg_log=[msg_log; currMsg];
    if strcmp(msgType,'log')==1
        msg_txt.String=msg_log;
        msg_txt.Value=currPos+1;
        drawnow;
    end
end

% Initial condition and boundaries
kerpar0=kernelDensity.kerpar0(m);
lb=kernelDensity.kerpar0_LB(kerpar0);
ub=kernelDensity.kerpar0_UB(kerpar0);

% Objective function
fun=@(par) obfKerPar(K,kernelDensity,par,observedData,regressionPriority);

% Optimizer options
options = optimset('display', 'off', 'TolFun',ratio*1e-7, 'TolX', ratio*1e-7);

% Optimization
if (all(lb==kerpar0)&&all(ub==kerpar0))
    kerpar=kerpar0;
else
    kerpar=lsqnonlin(fun,kerpar0,lb,ub,options);
end

%% Graphic output
currMsg=[currMsg '[Done]'];
if strcmp(printMode,'cmd')==1
    fprintf(char(8*ones(1,length(currMsg)+1)));
else
    msg_log=[msg_log(1:end-1); currMsg];    
end
kerparNames=cell(length(kerpar),1);
for ip=1:length(kerparNames)
    kerparNames{ip}=kernelDensity.parameters(ip).name;
end

if strcmp(printMode,'cmd')==1
    disp(char(currMsg));
    disp(array2table(round(kerpar,2, ...
        'significant'),'VariableNames',kerparNames));
    fprintf('\n');
else
    currMsg={' '; '--- Kernel parameters ---'; ' '; ...
        ['   ' kerparNames{1} '=' num2str(round(kerpar(1),2,'significant'))]};
    for ip=2:length(kerparNames)
        currMsg{end}=[currMsg{end} ', '...
             kerparNames{ip} '=' num2str(round(kerpar(ip),2,'significant'))];
    end
    msg_results=[msg_results; currMsg];
end

%% Determination of kernel pdf, moments, and incomplete moments

currMsg='>> Determining kernel pdf and moments';
if strcmp(printMode,'cmd')==1
    fprintf('\n[\b<strong>%s</strong>]\b\n',currMsg);
else
    msg_log=[msg_log; currMsg];
    if strcmp(msgType,'log')==1
        msg_txt.String=msg_log;
        msg_txt.Value=currPos+2;
        drawnow;
    end
end

N=length(K);
NP=order;
KerMom=zeros(2*NP+1,1);

IncMom=zeros(NP+2,N);
I=zeros(NP+2,N);
IncMomL=zeros(NP+2,N);
J=zeros(NP+2,N);

% Probability density function
kf=@(x) kernelDensity.pdf(x,kerpar);

% Moments
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
    
    % Incomplete moments
    if (isfield(kernelDensity,'i_thIncUMoment')==1)&&(isfield(kernelDensity,'i_thIncLMoment')==1)
        for i=0:NP+1
            % Order i+1
            I(i+1,j)=kernelDensity.i_thIncUMoment(Kstar,i+1,kerpar);
            if Kstar==0
                J(i+1,j)=0;
            elseif NP+2<=2*NP
                J(i+1,j)=KerMom(i+2)-I(i+1,j);
            else
                J(i+1,j)=kernelDensity.i_thIncLMoment(Kstar,i+1,kerpar);
            end
            % Order i
            if i==0
                IncMom(i+1,j)=kernelDensity.i_thIncUMoment(Kstar,i,kerpar);
                if Kstar==0
                    IncMomL(i+1,j)=0;
                else
                    IncMomL(i+1,j)=kernelDensity.i_thIncLMoment(Kstar,i,kerpar);
                end
            else
                IncMom(i+1,j)=I(i,j);
                IncMomL(i+1,j)=J(i,j);
            end
        end
    else
        for i=0:NP+1
            % Order i+1
            I(i+1,j)=integral(@(x) x.^(i+1).*kernelDensity.pdf(x,kerpar),Kstar,Inf);
            if Kstar==0
                J(i+1,j)=0;
            elseif NP+2<=2*NP
                J(i+1,j)=KerMom(i+2)-I(i+1,j);
            else
                J(i+1,j)=integral(@(x) x.^(i+1).*kernelDensity.pdf(x,kerpar),0,Kstar);
            end
            % Order i
            if i==0
                IncMom(i+1,j)=integral(@(x) kernelDensity.pdf(x,kerpar),Kstar,Inf);
                if Kstar==0
                    IncMomL(i+1,j)=0;
                else
                    IncMomL(i+1,j)=integral(@(x) kernelDensity.pdf(x,kerpar),0,Kstar);
                end
            else
                IncMom(i+1,j)=I(i,j);
                IncMomL(i+1,j)=J(i,j);
            end
        end
    end
    
end

%% Residuals
estimationResults.NPC=1;
epsilon=vec(objfunc(K, KerMom, IncMom, I, IncMomL, J, 1)-observedData);
epsilon0=epsilon;

%% Graphic output
currMsg=[char(8*ones(1,length(currMsg)+2)) currMsg '   [Done]'];
if strcmp(printMode,'cmd')==1
    fprintf('\n%s',currMsg);
end

%% Calibration of expansion coefficients

switch mode;
    %% Iterative
    case 'normal'
    % Direct
        inOr=length(kerpar)+1;
        if order>=2
            x0=zeros(1, min(order-1,inOr));
            fun=@(par) (objfunc(K, KerMom, IncMom, I, IncMomL, J, [1 par])-observedData);
            %% Graphics
            if order==2
                currMsg='>> Optimization on 1st parameter     ';
            else
                currMsg=['>> Optimization first ' int2str(min(order-1,inOr)) ' parameters  '];
            end
            if strcmp(printMode,'cmd')==1
                fprintf('\n[\b<strong>%s</strong>]\b',currMsg);
            else
                msg_log=[msg_log; currMsg];
                if strcmp(msgType,'log')==1
                    msg_txt.Value=msg_txt.Value+1;    
                    msg_txt.String=msg_log;
                    drawnow;
                end
            end
            %% Optimization
            lb=[];
            ub=[];
            options = optimset('display', 'off', 'TolFun',ratio*1e-7, 'TolX', ratio*1e-7,'Algorithm','levenberg-marquardt');
            [optpar,res, res_c]=lsqnonlin(fun,x0,lb,ub,options);
            epsilon=vec(fun(optpar));
            res=sqrt(mean(epsilon.^2));
            res_c=var([res_c(:,1);res_c(:,2)],1);
            y0=[1 optpar];
            currMsg=[char(8*ones(1,length(currMsg)+1)) currMsg '[Done]'];
            if strcmp(printMode,'cmd')==1
                fprintf('\n%s',currMsg);
            else
                msg_log{end}=[msg_log{end}];
                if strcmp(msgType,'log')==1
                    msg_txt.String=msg_log;
                    msg_txt.Value=msg_txt.Value+1;
                    drawnow;
                end
            end
        else
            y0=1;
        end
        % Iterative
        
        if order>0
            i=length(y0);
            flag=0;
            while (i<=order)||(flag==0)
                %% Graphics
                if i==1
                    str=' 1st';
                elseif i==2
                    str=' 2nd';
                elseif i==3
                    str=' 3rd';
                elseif (4<=i)&&(i<=9)
                    str=[' ' num2str(i) 'th'];
                else
                    str=[num2str(i) 'th'];
                end
                currMsg=['>> Optimization on ' str ' parameter      '];
                if strcmp(printMode,'cmd')==1
                    l1=currMsg;
                    fprintf('\n[\b<strong>%s</strong>]\b',currMsg);
                else
                    msg_log=[msg_log; currMsg];
                    if strcmp(msgType,'log')==1
                        msg_txt.String=msg_log;
                        drawnow;
                    end
                end
                %% Finding boundaries for i-th optimization
                fun=@(par) (objfunc(K, KerMom, IncMom, I, IncMomL, J, [y0 par])-observedData);
                [f,p]=ortapprox(kf, KerMom, [y0 1]);
                pn=@(x) transpose([zeros(1,length(y0)) 1]*p(x));
                sumn=@(x) f(x)./transpose(kf(x))-pn(x);
                dom=K';
                sumn=sumn(dom);
                pnev=pn(dom);
                pnpos=pnev>0;
                pnneg=pnev<0;
                lb=max(-sumn(pnpos)./pnev(pnpos));
                ub=min(sumn(pnneg)./abs(pnev(pnneg)));
                %% Graphics
                if isempty(lb)
                    lbd='-Inf';
                else
                    lbd=num2str(lb, 3);
                end
                if isempty(lb)
                    ubd=' +Inf';
                else
                    ubd=num2str(ub, 3);
                end
                currMsg=['   Boundaries [' lbd ', ' ubd ']'];
                if strcmp(printMode,'cmd')==1
                    l2=currMsg;
                    fprintf('\n%s',currMsg);
                else
                    msg_log=[msg_log; currMsg];
                    if strcmp(msgType,'log')==1
                        msg_txt.String=msg_log;
                        drawnow;
                    end
                end
                %% Optimization of i-th parameter
                options = optimset('display', 'off', 'TolFun',ratio*1e-7, 'TolX', ...
                    min([ratio*1e-7,abs(ub),abs(lb)]));
                [optpar,res,res_c]=lsqnonlin(fun,0,lb,ub,options);
                epsilon=vec(fun(optpar));
                res=sqrt(mean(epsilon.^2));
                if size(res_c)>0
                    res_c=var([res_c(:,1);res_c(:,2)],1);
                end
                y0=[y0 optpar];
                if ne(optpar,0)
                    flag=1;
                end
                %% Graphics
                if strcmp(printMode,'cmd')==1
                    currMsg=[char(8*ones(1,length(l1)+length(l2)+1)) l1 '[Done]'];
                    fprintf('%s\n%s',currMsg, l2);
                else
                    msg_log{end-1}=[msg_log{end-1}];
                    if strcmp(msgType,'log')==1
                        msg_txt.String=msg_log;
                        msg_txt.Value=msg_txt.Value+4;
                        drawnow;
                    end
                end
                currMsg=['   Optimal coefficient c' int2str(i) ...
                    '=' num2str(optpar, '%.3g')];
                if strcmp(printMode,'cmd')==1
                    fprintf('\n%s',currMsg)
                else
                    msg_log=[msg_log; currMsg];
                    if strcmp(msgType,'log')==1
                        msg_txt.String=msg_log;
                        drawnow;
                    end
                end
                currMsg=['   Residual e' int2str(i) ...
                    '=' num2str(sqrt(res/(2*length(K))), '%.3g')];
                if strcmp(printMode,'cmd')==1
                    fprintf('\n%s',currMsg)
                else
                    msg_log=[msg_log; currMsg];
                    if strcmp(msgType,'log')==1
                        msg_txt.String=msg_log;
                        drawnow;
                    end
                end
                i=i+1;
                if i==26
                    flag=1;
                end

            end
        end
    %% PCA    
    case 'pca'
        if order>0
            %% Graphics
            currMsg='>> Running PCA';
            if strcmp(printMode,'cmd')==1
                fprintf('\n[\b<strong>%s</strong>]\b\n',currMsg);
            else
                msg_results=[msg_results; ' '; 'REGRESSION RESULTS'];
                msg_log=[msg_log; currMsg];
                if strcmp(msgType,'log')==1
                    msg_txt.String=msg_log;
                    msg_txt.Value=msg_txt.Value+1;
                    drawnow;
                end
            end
                
            %% Finding Y0, Y1 and X
            A=zeros(length(K),order+1);
            B=zeros(length(K),order+1);
            call0=zeros(size(K));
            put0=zeros(size(K));
                        
            % Determination of orthogonal polynomials
            pol=OrtPolCoeff(NP, KerMom);
            
            % Generating formula coefficients
            for j=1:N % Strikes loop
                Kstar=K(j);
                
                % Finding j-th column of X                
                for k=1:order+1
                    A(j,k)=sum(pol(k,:).*(I(1:end-1,j)-Kstar*IncMom(1:end-1,j))');
                    B(j,k)=sum(pol(k,:).*(Kstar*IncMomL(1:end-1,j)-J(1:end-1,j))');
                end
                
                call0(j)=A(j,1);
                put0(j)=B(j,1);
                
            end
            
            X=[A(:, 2:end); B(:, 2:end)];
            X=real(X);
            Y=[call; put];
            X0=[call0;put0];
            Y1_star=Y-X0;
            
            %% Determining Orthogonal-PC
            
            % Ruling out columns with all zero entries
            IX=abs(sum(X))>0;
            goAhead=true;
            
            % Restricting mean to fixed value
            if restrictMean
                IX(1)=0;
                c1=(m(1)-KerMom(2))/(sqrt(KerMom(3)-KerMom(2)^2));
                Y1_star=Y1_star-c1*X(:,1);
                if (order<2)
                    goAhead=false;
                    c=c1;
                    y0=[1 c];
                end       
            end
            
            if goAhead
                X=X(:,IX);
                [WEIGHTS, PRINCOMP,~, EXPLVAR, CUMR2]  = pca_KS(standardize(X));
                WEIGHTS=inv(WEIGHTS);
                
                % READ HERE!
                %
                % It is necessary to separate the case threshold=100% in pca_KS.m
                % because there might be exceptional cases for which, due to numerical
                % issues, no component explains exactly 100% of variance.
                %
                if PCAThreshold==1
                    NPC=length(EXPLVAR);
                else
                    D=CUMR2>PCAThreshold;
                    NPC=length(EXPLVAR)-sum(D)+1;
                end
                estimationResults.NPC=NPC;
                
                %% Regression
                switch regressionPriority
                    case 'fitting' % Regression without intercept
                        results_pca=ols(Y1_star,PRINCOMP(:,1:NPC));
                        beta_star_PCA=results_pca.beta;
                        beta_PCA0=WEIGHTS(:,1:NPC)*beta_star_PCA;
                        sigma=std(X);
                        % Computation of y0
                        c=zeros(1,size(X,2)+sum(IX==0));
                        c(IX)=beta_PCA0./sigma';
                        y0=[1; c']';
                        c=c';
                        if restrictMean
                            y0(2)=c1;
                            c(2)=c1;
                        end
                        % Computation of residuals
                        X_tilde=[A;B];
                        epsilon=Y-X_tilde*y0';
                    case 'robustness' % Regression with intercept
                        delta=mean(Y1_star);
                        options_PCA=optimoptions('fmincon','Display','off', ...
                            'GradObj','on');
                        PCA_u=PRINCOMP(:,1:NPC);
                        results_pca=ols(Y1_star,PRINCOMP(:,1:NPC));
                        beta0=results_pca.beta;
                        Mu=repmat(mean(X),rows(PRINCOMP),1);
                        Sigma=repmat(std(X),rows(PRINCOMP),1);
                        [beta_star_PCA]=...
                            fmincon(@(beta) fitting_PCA(beta,Y1_star,PCA_u,delta), ...
                            beta0,[],[],[],[],[],[], ...
                            @(beta)constraintintercept(X,beta,Mu,Sigma,delta,WEIGHTS(:,1:NPC),0,1e5,kf,KerMom,IX),...
                            options_PCA);
                        v_ResEst_c=Y1_star-PCA_u*beta_star_PCA;
                        F_test=((sum(epsilon0.^2)-sum(v_ResEst_c.^2))/NPC)/(sum(v_ResEst_c.^2)/(rows(v_ResEst_c)+1));
                        estimationResults.F_test=F_test;
                        beta_PCA0=WEIGHTS(:,1:NPC)*beta_star_PCA;
                        sigma=std(X);
                        c=zeros(1,size(X,2)+sum(IX==0));
                        c(IX)=beta_PCA0./sigma';
                        y0=[1; c']';
                        c=c';
                        if restrictMean
                            y0(2)=c1;
                            c(2)=c1;
                        end
                        X_tilde=[A;B];
                        if size(X_tilde,2)>1;
                            epsilon=Y-X_tilde*y0';
                        else
                            epsilon=Y-X0;
                        end
                end
                
                %% Checking boundaries on c
                lb=zeros(size(c));
                ub=zeros(size(c));
                for i=1:length(c)
                    % Finding bounds related to i-th coefficient
                    if i==1
                        ctemp=1;
                    else
                        ctemp=[1; c(1:i-1)]';
                    end
                    % Finding (i+1)-th polynomial
                    [f,p]=ortapprox(kf, KerMom, [ctemp 1]);
                    pn=@(x) transpose([zeros(1,length(ctemp)) 1]*p(x));
                    % Finding bounds
                    sumn=@(x) f(x)./transpose(kf(x))-pn(x);
                    dom=K';
                    sumn=sumn(dom);
                    pnev=pn(dom);
                    pnpos=pnev>0;
                    pnneg=pnev<0;
                    if isempty(-sumn(pnpos)./pnev(pnpos))==0
                        lb(i)=max(-sumn(pnpos)./pnev(pnpos));
                    else
                        lb(i)=-Inf;
                    end
                    if isempty(sumn(pnneg)./abs(pnev(pnneg)))==0
                        ub(i)=min(sumn(pnneg)./abs(pnev(pnneg)));
                    else
                        ub(i)=Inf;
                    end
                end
                ofb=find((c>ub)|(c<lb));
                
                %% Graphics
                if isempty(ofb)==0
                    currMsg={'--- Boundaries ---'; ' '; ...
                        '  Violations occured for'};
                    for j=1:length(ofb)
                        if j<length(ofb)
                            if strcmp(printMode,'cmd')==1
                                currMsg{end}=[currMsg{end} ' c' int2str(ofb(j)) ','];
                            else
                                currMsg{end}=[currMsg{end} ' c' int2str(ofb(j)) ','];
                            end
                        else
                            if strcmp(printMode,'cmd')==1
                                currMsg{end}=[currMsg{end} ' c' int2str(ofb(j)) '.'];
                            else
                                currMsg{end}=[currMsg{end} ' c' int2str(ofb(j)) '.'];
                            end
                        end
                    end
                    if strcmp(printMode,'cmd')==1
                        fprintf('\n\n');
                        disp(char(currMsg));
                        fprintf('\n\n');
                    else
                        msg_results=[msg_results; ' '; currMsg];
                        if strcmp(msgType,'results')
                            msg_txt.String=msg_results;
                            drawnow;
                        end
                    end
                    
                    % Tabling boundary violations
                    rows1=cell(size(ofb));
                    for i=1:length(ofb)
                        rows1{i}=['k=' int2str(ofb(i))];
                    end
                    cols={'Lower','ck','Upper'};
                    format bank;
                    if strcmp(printMode,'cmd')==1
                        disp(table(lb(ofb), c(ofb), ub(ofb), ...
                            'VariableNames',cols, 'RowNames', rows1));
                        format;
                    else
                        currMsg{1}=' ';
                        currMsg{2}='            Lower    ck    Upper';
                        currMsg{3}='            --------------------';
                        chT=num2str([lb(ofb) c(ofb) ub(ofb)],'  %.2f');
                        
                        for i=1:length(ofb)
                            currMsg{i+3}=['     c' int2str(ofb(i)) '    '...
                                chT(i,:)];
                        end
                        msg_results=[msg_results; currMsg];
                        if strcmp(msgType,'results')==1
                            msg_txt.String=msg_results;
                            drawnow;
                        end
                    end
                    
                    
                end
                
                %% Printing PCA results
                if strcmp(printMode,'gui')==1
                    if strcmp(msgType,'log')==1
                        msg_txt.String=msg_log;
                        drawnow;
                    end
                end
                currMsg={' '; ...
                    '--- Principal Components Analysis ---'; ' '; ...
                    ['  Threshold: ' num2str(floor(100*PCAThreshold)) '%']; ...
                    ['  Number of principal components: ' int2str(NPC)]};
                if strcmp(printMode,'cmd')==1
                    disp(char(currMsg));
                else
                    msg_results=[msg_results; currMsg];
                    if strcmp(msgType,'results')==1
                        msg_txt.String=msg_results;
                        drawnow;
                    end
                end
            end
        else
            y0=1;
        end
    case 'ols'
        if order>0
            %% Graphics
            currMsg='>> Running OLS';
            if strcmp(printMode,'cmd')==1
                fprintf('\n[\b<strong>%s</strong>]\b\n',currMsg);
            else
                msg_log=[msg_log; currMsg];
                if strcmp(msgType,'log')==1
                    msg_txt.String=msg_log;
                    drawnow;
                end
            end
            %% Finding Y0, Y1 and X
            A=zeros(length(K),order+1);
            B=zeros(length(K),order+1);
            call0=zeros(size(K));
            put0=zeros(size(K));
             
            % Determination of orthogonal polynomials
            pol=OrtPolCoeff(NP, KerMom);
            
            % Generating formula coefficients
            for j=1:N % Strikes loop
                Kstar=K(j);
                
                % Finding j-th column of X
                
                for k=1:order+1
                    A(j,k)=sum(pol(k,:).*(I(1:end-1,j)-Kstar*IncMom(1:end-1,j))');
                    B(j,k)=sum(pol(k,:).*(Kstar*IncMomL(1:end-1,j)-J(1:end-1,j))');
                end
                
                call0(j)=A(j,1);
                put0(j)=B(j,1);
            
            end
            
            X=[A(:, 2:end); B(:, 2:end)];
            X=real(X);
            Y=[call; put];
            X0=[call0;put0];
            Y1_star=Y-X0;
            Mu=repmat(mean(X),size(X,1),1);
            delta=mean(Y1_star);
            beta0=zeros(size(X,2),1);
            c=fmincon(@(beta) fitting_OLS(beta,Y1_star,X,delta), beta0,[], ...
                [],[],[],[],[], @(beta)constraintinterceptols(beta,Mu,delta),options);
            y_star=X*c;
            epsilon=Y1_star-y_star;
            y0=[1; c]';
        else
            y0=1;
        end
    otherwise
        error('Unrecognized calibration mode.');
end

%% Output commands
elt=toc(tstart);
extime=datestr(datenum(0,0,0,0,0,elt),'HH:MM:SS');
c=y0;
cStr=['   c=[' num2str(c,' %.4f') ']'];
currMsg={' '; '--- Estimated coefficients ---'; ' '; cStr; ' '};
if strcmp(printMode,'cmd')==0
    msg_log=[msg_log; '>> Estimation done'];
    msg_results=[msg_results; currMsg];
    if strcmp(msgType,'log')==1
        msg_txt.String=msg_log;
        drawnow;
    end
else
    disp(char(currMsg));
end

estimationResults.regressionPriority=regressionPriority;
estimationResults.epsilon=epsilon;
estimationResults.epsilon0=epsilon0;

warning on all;

end
  
