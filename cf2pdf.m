%% CF2PDF - Exports current figure into pdf file
% This function exports the current figure into a pdf file by matching a
% user defined ratio.
% 
% Usage:
%
%  CF2PDF(ratio,tgtFile)       
%
% Input:
%
%       ratio  -  indicates the ratio to be used in the exported pdf file
%                 'ISO216l'   w/h=sqrt(2) (landscape)
%                 'ISO216p'   h/w=sqrt(2) (portrait)
%                  custom     insert any number indicating h/w
%     tgtFile  -  name of target file
%           h  -  OPTIONAL: handle to figure 
%                 DEFAULT: current figure
%
% Example:
%
%  plot(1:1000,randn(1000,1));
%  CF2PDF('ISO216l','test.pdf');

function status=cf2pdf(varargin)

if nargin<2
    error('Not enough input.');
else
    ratio=varargin{1};
    tgtFile=varargin{2};
end

if nargin>=3
    h=varargin{3};
else
    h=gcf;
end

if ischar(ratio)
    switch ratio
        case 'ISO216l'
            ratio=1/sqrt(2);
        case 'ISO216p'
            ratio=sqrt(2);
        otherwise
            s=[ratio ' is not a valid format.'];
            error(s);
    end
elseif isnumeric(ratio)==1
    if ratio<=0
        error('Ratio must be positive.')
    end
else
    error('Bad input specification.')
end
    
X=25;
Y=ratio*X;
set(h, 'Units','centimeters', 'Position',[0,0,X,Y])

set(h, 'PaperUnits','centimeters')
set(h,'PaperSize', [X Y]);
set(h, 'PaperPosition',[0 0 X Y])
set(h, 'PaperOrientation','portrait')
print(h, '-dpdf', tgtFile)
status=1;