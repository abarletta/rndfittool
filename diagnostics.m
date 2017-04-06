%% DIAGNOSTICS - Performs diagnostics tests

function currMsg=diagnostics(inData, cuttingThreshold, estimationResults, epsilonGlob)

currMsg={' ';'--- Diagnostics ---'; ' '};

%% Filtering data

indCall=(inData{2}>cuttingThreshold)&(inData{3}>0);
indPut=(inData{3}>cuttingThreshold)&(inData{2}>0);
filteringInd=indCall&indPut;
clear indCal indPut;
KK=inData{1}(filteringInd);
call=inData{2}(filteringInd);
put=inData{3}(filteringInd);
m=inData{4};

% Retrieving Bid and Ask prices
if length(inData)==11
    call_a=inData{8}(filteringInd);
    call_b=inData{9}(filteringInd);
    put_a=inData{10}(filteringInd);
    put_b=inData{11}(filteringInd);
    a=[call_a;put_a];
    b=[call_b;put_b];
    BA=median(a-b);
else
    BA=[];
end

%% Computing residuals
% Global residuals
vecResGl=vec(epsilonGlob);
% Estimation residuals
vecResEst=vec(estimationResults.epsilon);
% Average of est. residuals
avgErrEst=mean(vecResEst);
% Average of gl. residuals
sqErrGl=mean(vecResGl.^2);
% Mean of PCP
avgPCP=std(call-put+KK-m(1));

%% t-test and p-value

% Relative mean of residuals
relAvgErr=100*mean(vecResEst)/mean([call; put]);
% t-test
results=nwest_extras(vecResEst,ones(length(vecResEst),1), ...
    floor(0.75*length(vecResEst)^(1/3)));
glTT=results.tstat;
% Retrieving p-value intercept
switch estimationResults.regressionPriority
    case 'fitting'
        currMsg=[currMsg; ['  t-test on est. res.: ', num2str(glTT,'%3.2f')];...
            ['  p-value of t-test on est. res.: ', num2str((1-normcdf(abs(glTT)))*2,'%3.2f')]; ...
            ['  Mean of est. residuals: ', num2str(avgErrEst,'%3.4f'),...
            ' (', num2str(relAvgErr,'%3.2f'), '% of average price)']];
end

%% Bootstrap

CC=2000;
blkSz=3;
mu_starEst=zeros(CC,1);
mu_starEst2=zeros(CC,1);
mu_a_starEst=zeros(CC,1);
v_ResEst_c=vecResEst-avgErrEst;
av_ResEst=abs(vecResEst);
st_a_starEst=zeros(CC,1);
for i=1:CC
    RR=0;
    r_starEst=[];
    a_r_starEst=[];
    while RR<=rows(vecResEst);
        B=rand(1,1);
        U=floor(B*(rows(vecResEst)-blkSz+1))+1;
        U=[U; U+[1:blkSz-1]'];
        r_starEst=[r_starEst; v_ResEst_c(U)];
        a_r_starEst=[a_r_starEst; av_ResEst(U)];
        RR=rows(r_starEst);
    end
    r_starEst=r_starEst(1:rows(vecResEst));  
    a_r_starEst=a_r_starEst(1:rows(vecResEst));
    mu_starEst(i)=mean(r_starEst)+avgErrEst;
    mu_starEst2(i)=mean((r_starEst+avgErrEst).^2);
    mu_a_starEst(i)=mean(a_r_starEst);
    st_a_starEst(i)=std(r_starEst);
 end

%% Computing probabilities

switch estimationResults.regressionPriority
    case 'fitting'
        
        smu_starEst=sort(mu_starEst);
        l_smu_starEst=smu_starEst(round(CC*0.005));
        u_smu_starEst=smu_starEst(round(CC*0.995));
        iTestMu=(l_smu_starEst<0) && (u_smu_starEst>0);
        if iTestMu==1
            currMsg=[currMsg; '  mean(res.est)=0: TRUE'];
        else
            currMsg=[currMsg; '  mean(res.est)=0: FALSE'];
        end
        
        
        if isempty(BA)==0
            Perc_BA=mean((mu_starEst>-BA/2).*(mu_starEst<=BA/2));
            currMsg=[currMsg;
             ['  Probability that |mean(res.est.)|<(Ask-Bid)/2: ' ...
                num2str(100*Perc_BA,'%3.2f') '%']];
        end
        Perc_PC=mean(abs(mu_a_starEst)<avgPCP);
        currMsg=[currMsg;
            ['  Probability that mean(|res.est.|)|<mean(|call-put+K-F|): ' ...
            num2str(100*Perc_PC,'%3.2f') '%']];
 end;       
        
smu_starEst2=sort(mu_starEst2);
l_smu_starEst2=smu_starEst2(round(CC*0.005));
u_smu_starEst2=smu_starEst2(round(CC*0.995));
iTestGL=(sqErrGl>l_smu_starEst2) && (sqErrGl<u_smu_starEst2);
if iTestGL==1
    currMsg=[currMsg; '  mean(res.est.^2)=mean(res.gl.^2): TRUE'];
else
    currMsg=[currMsg; '  mean(res.est.^2)=mean(res.gl.^2): FALSE'];
end
Perc_PC=mean(st_a_starEst<avgPCP);
        currMsg=[currMsg;
            ['  Probability that std(|res.est.|)|<std(P-C parity): ' ...
            num2str(100*Perc_PC,'%3.2f') '%']];
    switch estimationResults.regressionPriority
    case 'robustness'
        if (estimationResults.NPC>1)&(isfield(estimationResults,'F_test_b'))
            currMsg=[currMsg;
                ['  p-value F test: ' ...
                num2str(100*(1-mean( estimationResults.F_test> estimationResults.F_test_b)),'%3.2f') '%']];
        end
     end

currMsg=[currMsg; ' '];


