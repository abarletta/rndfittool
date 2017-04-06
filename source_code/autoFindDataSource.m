function srcType=autoFindDataSource(fname)
%% AUTOFINDDATASOURCE
% Automatically finding data source type

srcType=[];
supportedTypes={'cboe','optMetrics'};


%% Excluding types by file extensions
ext=fname(end-2:end);
if strcmp(ext,'dat')==1
    rmTypesExt={'optMetrics'};
elseif strcmp(ext,'csv')==1
    rmTypesExt={'cboe'};
else
    rmTypesExt=[];
end

if isempty(rmTypesExt)==0
    for i=1:length(rmTypesExt)
        ind=find(strcmp(supportedTypes,rmTypesExt{i}));
        supportedTypes{ind}=[];
    end
end

%% Determining type among chosen file

currPth=mfilename('fullpath');
currPth=currPth(1:findstr(mfilename,currPth)-2);

wPth=pwd;
cd(currPth);

files=ls('*.m');
R=[];
i=0;
arg='(fname,[])';


while (i<=length(supportedTypes)-1)&&(isempty(R)==1)
    i=i+1;
    if isempty(supportedTypes{i})==0
        ind=find(strcmp(cellstr(lower(files)),['imp' lower(supportedTypes{i}) '.m']));
        funcname=files(ind,1:find(files(ind,:)=='.')-1);
        R=eval([funcname arg]);
    end
end

cd(wPth);

if isempty(R)==0
    srcType=supportedTypes{i};
end