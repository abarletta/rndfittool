%% RNDFITTOOL - caller for gui.m
% Auxiliary script to call 'gui'

function varargout=rndfittool(varargin)

try
    currPath=mfilename('fullpath');
    I=strfind(currPath,mfilename);
    currPath=currPath(1:I-1);
    cd(currPath);
    if nargin==0
        h=gui;
    else
        thInd=find(strcmp(varargin,'dark'),1,'first');
        if isempty(thInd)==1
            cmd='light';
        else
            cmd='dark';
        end
        thDeb=find(strcmp(varargin,'debug'),1,'first');
        if isempty(thDeb)==0
            h=gui(cmd,[]);
        else
            h=gui(cmd);
        end
    end
catch ME
    if nargout
        varargout{1}=[];
    end
    msgbox(ME.message);
end

if nargout
    varargout{1}=h;
end

end