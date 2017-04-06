    function varargout = hwin(varargin)
% hwin MATLAB code for hwin.fig
%      hwin, by itself, creates a new hwin or raises the existing
%      singleton*.
%
%      H = hwin returns the handle to a new hwin or the handle to
%      the existing singleton*.
%
%      hwin('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in hwin.M with the given input arguments.
%
%      hwin('Property','Value',...) creates a new hwin or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hwin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hwin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools mainPanel.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hwin

% Last Modified by GUIDE v2.5 14-Oct-2015 01:29:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hwin_OpeningFcn, ...
                   'gui_OutputFcn',  @hwin_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before hwin is made visible.
function hwin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no outputFields args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hwin (see VARARGIN)

%% Choose default command line outputFields for hwin
err=0;
handles.output = hObject;
handles.state='default';
handles.defaultLeftPanelString=handles.leftPanel.String;
handles.defaultLeftPanelPosition=handles.leftPanel.Position;
handles.defaultRightPanelPosition=handles.menuPanel.Position;
handles.defaultFGColor=handles.outputFields.ForegroundColor;
handles.bgFooter=handles.acknowledgements.BackgroundColor;
handles.fgFooter=handles.acknowledgements.ForegroundColor;
handles.bgLogo=handles.logoPanel.BackgroundColor;
handles.fgLogo=handles.logoPanel.ForegroundColor;

currPth=mfilename('fullpath');
currPth=currPth(1:findstr(mfilename,currPth)-2);

%% Setting author information default structure

try 
    str=load([currPth '\help\author.mat']);
    str=str.str;
catch ME
    str=struct;
    str.Name='File missing or corrupted';
    str.Institution=[];
    str.Mail=[];
    str.Version='N/A';
end

if err==0
    handles.aboutLeftPanelString= ...
        {['Version ' str.Version]; ''; ...
        str.Name; str.Institution};
    handles.authorMail=str.Mail;
end

%% Setting credits information
try
    vecStr=readFields([currPth '\help\credits.txt']);
    flds=fields(vecStr);
    
    if isempty(str)==1
        handles.aboutRightPanelString=[];
    else
        cc=[];
        str={'Credited contributors:'; ''};
        for i=1:length(vecStr)
            for j=1:length(flds)
                str=[str; vecStr(i).(flds{j})];
                if strcmp(str{end},'&')==1
                    str(end-1)=[];
                end
            end
            str=[str; ' '];
            if isfield(vecStr(i), 'Mail')
                cc=[cc vecStr(i).Mail '; '];
            end
        end
        
        if length(str)<13
            ml=13-length(str);
            for i=1:ceil(ml/2);
                str=[' '; str; ' '];
            end
        end
        
        handles.aboutRightPanelString=str;
        handles.cc=cc;
    end
    
catch ME
    str={'Unable to load credit list'};
    handles.aboutRightPanelString=str;
    delete(hObject);
    handles.cc=[];
    err=1;
end

%% Setting acknowledgements information
try 
  vecStr=readFields([currPth '\help\acknowledgements.txt']);
  flds=fields(vecStr);
catch ME
    vecStr=[];
end

if isempty(str)==1
    handles.aboutRightPanelString=[];
else
    str={'CODES BY OTHER AUTHORS'; ''};
    for i=1:length(vecStr)
        for j=1:length(flds)
            str=[str; vecStr(i).(flds{j})];
            if strcmp(str{end},'&')==1
                str(end-1)=[];
            end
        end
        str=[str; ' '];
    end
    if length(str)<13
        ml=13-length(str);
        for i=1:ceil(ml/2);
            str=[' '; str; ' '];
        end
    end
    handles.acknowledgementsRightPanelString=str;
end

%% Setting supported data information
try 
  vecStr=readFields([currPth '\help\supportedData.txt']);
  flds=fields(vecStr);
catch ME
    vecStr=[];
end

if isempty(str)==1
    handles.aboutRightPanelString=[];
else
    str={'Supported data sources in current version:'; ''};
    for i=1:length(vecStr)
        for j=1:length(flds)
            str=[str; vecStr(i).(flds{j})];
            if strcmp(str{end},'&')==1
                str(end-1)=[];
            end
        end
    end
    handles.supportedDataLeftPanelString=str;
end

%% Setting tips initial structure
handles.ntips=1;
handles.tipsState=1;
handles.tipsLeftPanelString= ...
    {'The estimation technique used by this software is fully described in';
     '';
     'Barletta A, Santucci de Magistris P, Violante F';
     'A Non-Structural Investigation of VIX Risk Neutral Density (March 31, 2017)'
     'Available at SSRN.'
    };
 

%% Update handles structure
if err==0
    guidata(hObject, handles);
end
% UIWAIT makes hwin wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hwin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning outputFields args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line outputFields from handles structure
if exist('handles.output','var')==1
    varargout{1} = handles.output;
else
    varargout{1}=[];
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over outputFields.
function outputFields_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to outputFields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.outputFields.ForegroundColor=[1 1 1]-handles.defaultFGColor;
pause(.1);
handles.outputFields.ForegroundColor=handles.defaultFGColor;
currPth=mfilename('fullpath');
currPth=currPth(1:findstr(mfilename,currPth)-2);
web([currPth '/help/html/help_page1.html']);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over loadData.
function loadData_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.loadData.ForegroundColor=[1 1 1]-handles.defaultFGColor;
pause(.1);
handles.loadData.ForegroundColor=handles.defaultFGColor;
currPth=mfilename('fullpath');
currPth=currPth(1:findstr(mfilename,currPth)-2);
web([currPth '/help/html/help_page2.html']);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over clData.
function clData_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to clData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.clData.ForegroundColor=[1 1 1]-handles.defaultFGColor;
pause(.1);
handles.clData.ForegroundColor=handles.defaultFGColor;
currPth=mfilename('fullpath');
currPth=currPth(1:findstr(mfilename,currPth)-2);
web([currPth '/help/html/help_page3.html']);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over parameters.
function parameters_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.parameters.ForegroundColor=[1 1 1]-handles.defaultFGColor;
pause(.1);
handles.parameters.ForegroundColor=handles.defaultFGColor;
currPth=mfilename('fullpath');
currPth=currPth(1:findstr(mfilename,currPth)-2);
web([currPth '/help/html/help_page4.html']);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over expResults.
function expResults_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to expResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.expResults.ForegroundColor=[1 1 1]-handles.defaultFGColor;
pause(.1);
handles.expResults.ForegroundColor=handles.defaultFGColor;
currPth=mfilename('fullpath');
currPth=currPth(1:findstr(mfilename,currPth)-2);
web([currPth '/help/html/help_page5.html']);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over outputFields.
function greeksInfo_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to outputFields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.greeksInfo.ForegroundColor=[1 1 1]-handles.defaultFGColor;
pause(.1);
handles.greeksInfo.ForegroundColor=handles.defaultFGColor;
currPth=mfilename('fullpath');
currPth=currPth(1:findstr(mfilename,currPth)-2);
web([currPth '/help/html/help_page6.html']);



% --- Executes during object deletion, before destroying properties.
function supportedData_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to supportedData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over supportedData.
function supportedData_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to supportedData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch(handles.state)
    case 'default'
      %% Button highlighting
        handles.supportedDataPanel.HighlightColor=...
            [1 1 1]-handles.supportedDataPanel.HighlightColor;
        handles.supportedData.ForegroundColor=...
            [1 1 1]-handles.supportedData.ForegroundColor;
        %% Text shifting out
        originalPosition=handles.leftPanel.Position;
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[1-13*xShift 1 1 1].*originalPosition;
            pause(.01);
        end
        handles.supportedDataPanel.HighlightColor= ...
            [1 1 1]-handles.supportedDataPanel.HighlightColor;
        handles.supportedData.ForegroundColor=...
            [1 1 1]-handles.supportedData.ForegroundColor;
        %% Changing text and position
        handles.leftPanel.String=handles.supportedDataLeftPanelString;
        handles.leftPanel.HorizontalAlignment='center';
        if length(handles.leftPanel.String)>14
            handles.leftPanel.Style='edit';
            handles.leftPanel.Max=2;
        else
            handles.leftPanel.Style='text';
        end
        handles.footerLeftButton.Visible='off';
        handles.footerLeftButton.String='Download option data >>';
        %% Text shifting in
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[-12+13*xShift 1 1 1].*originalPosition;
            handles.footerLeftButton.ForegroundColor=...
                xShift*handles.fgFooter+(1-xShift)*handles.bgFooter;
            pause(.01);
        end
        %% Setting window state
        handles.state='supportedData';
        handles.supportedData.String='<<';
    case 'supportedData'
        %% Button highlighting
        handles.supportedDataPanel.HighlightColor= ...
            [1 1 1]-handles.supportedDataPanel.HighlightColor;
        handles.supportedData.ForegroundColor=...
            [1 1 1]-handles.supportedData.ForegroundColor;
        %% Text shifting out
        originalPosition=handles.leftPanel.Position;
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[1-13*xShift 1 1 1].*originalPosition;
            pause(.01);
        end
        handles.supportedDataPanel.HighlightColor= ...
            [1 1 1]-handles.supportedDataPanel.HighlightColor;
        handles.supportedData.ForegroundColor=...
            [1 1 1]-handles.supportedData.ForegroundColor;
        %% Changing text and position
        handles.leftPanel.String=handles.defaultLeftPanelString;
        handles.leftPanel.HorizontalAlignment='left';
        originalPosition=handles.defaultLeftPanelPosition;
        %% Text shifting in
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[-12+13*xShift 1 1 1].*originalPosition;
            handles.footerLeftButton.ForegroundColor=...
                (1-xShift)*handles.fgFooter+xShift*handles.bgFooter;
            pause(.01);
        end
        %% Setting window state
        handles.state='default';
        handles.supportedData.String='Supported data sources';
        handles.footerLeftButton.Visible='off';
end
guidata(hObject, handles);
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over about.

function about_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch(handles.state)
    case 'default'
        %% Button highlighting
        handles.aboutPanel.HighlightColor= ...
            [1 1 1]-handles.aboutPanel.HighlightColor;
        handles.about.ForegroundColor=...
            [1 1 1]-handles.about.ForegroundColor;
        %% Text shifting out
        originalPosition=handles.leftPanel.Position;
        originalPositionR=handles.menuPanel.Position;
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[1-13*xShift 1 1 1].*originalPosition;
            handles.menuPanel.Position=[1+xShift 1 1 1].*originalPositionR;
            pause(.01);
        end
        handles.aboutPanel.HighlightColor= ...
            [1 1 1]-handles.aboutPanel.HighlightColor;
        handles.about.ForegroundColor=...
            [1 1 1]-handles.about.ForegroundColor;
        handles.leftPanel.String=handles.aboutLeftPanelString;
        handles.leftPanel.HorizontalAlignment='center';
        handles.leftPanel.FontWeight='bold';
        handles.rightPanel.String=handles.aboutRightPanelString;
        if length(handles.rightPanel.String)>14
            handles.rightPanel.Style='edit';
        else
            handles.rightPanel.Style='text';
        end
        if isempty(handles.rightPanel.String)==0
            handles.menuPanel.Position(2)=1-0.02;
            handles.menuPanel.Position(4)=0.01;
        end
        %% Text shifting in
        handles.acknowledgements.Visible='on';
        handles.footerLeftButton.Visible='on';
        handles.footerLeftButton.String='E-mail to author >>';
        handles.rightPanel.Visible='on';
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[-12+13*xShift 1 1 1].*originalPosition;
            handles.rightPanel.Position=[2-xShift 1 1 1].*originalPositionR;
            handles.acknowledgements.ForegroundColor=...
                xShift*handles.fgFooter+(1-xShift)*handles.bgFooter;
            handles.footerLeftButton.ForegroundColor=...
                xShift*handles.fgFooter+(1-xShift)*handles.bgFooter;
            pause(.01);
        end
        %% Setting window state
        handles.state='about';
        handles.about.String='<<';
    case 'about'
        %% Button highlighting
        handles.aboutPanel.HighlightColor= ...
            [1 1 1]-handles.aboutPanel.HighlightColor;
        handles.about.ForegroundColor=...
            [1 1 1]-handles.about.ForegroundColor;
        %% Text shifting out
        originalPosition=handles.leftPanel.Position;
        originalPositionR=handles.rightPanel.Position;
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[1-13*xShift 1 1 1].*originalPosition;
            handles.rightPanel.Position=[1+xShift 1 1 1].*originalPositionR;
            pause(.01);
        end
        handles.aboutPanel.HighlightColor= ...
            [1 1 1]-handles.aboutPanel.HighlightColor;
        handles.about.ForegroundColor=...
            [1 1 1]-handles.about.ForegroundColor;
        %% Changing text and position
        handles.leftPanel.String=handles.defaultLeftPanelString;
        handles.leftPanel.HorizontalAlignment='left';
        handles.leftPanel.FontWeight='normal';
        originalPosition=handles.defaultLeftPanelPosition;
        originalPositionR=handles.defaultRightPanelPosition;
        handles.rightPanel.Position(2)=0.005;
        handles.rightPanel.Position(4)=0.01;
        handles.rightPanel.String=[];
        handles.rightPanel.Visible='off';
        handles.menuPanel.Position=handles.defaultRightPanelPosition;
        %% Text shifting in
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[-12+13*xShift 1 1 1].*originalPosition;
            handles.menuPanel.Position=[2-xShift 1 1 1].*originalPositionR;
            handles.acknowledgements.ForegroundColor=...
                (1-xShift)*handles.fgFooter+xShift*handles.bgFooter;
            handles.footerLeftButton.ForegroundColor=...
                (1-xShift)*handles.fgFooter+xShift*handles.bgFooter;
            pause(.01);
        end
        %% Setting window state
        handles.state='default';
        handles.about.String='About this software';
        handles.acknowledgements.Visible='off';
        handles.footerLeftButton.Visible='off';
end
guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over tips.
function tips_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to tips (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch(handles.state)
    case 'default'
        %% Button highlighting
        handles.tipsPanel.HighlightColor=...
            [1 1 1]-handles.tipsPanel.HighlightColor;
        handles.tips.ForegroundColor=...
            [1 1 1]-handles.tips.ForegroundColor;
        %% Text shifting out
        originalPosition=handles.leftPanel.Position;
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[1-13*xShift 1 1 1].*originalPosition;
            pause(.01);
        end
        handles.tipsPanel.HighlightColor= ...
            [1 1 1]-handles.tipsPanel.HighlightColor;
        handles.tips.ForegroundColor=...
            [1 1 1]-handles.tips.ForegroundColor;
        %% Changing text and position
        handles.leftPanel.String=handles.tipsLeftPanelString;
        handles.leftPanel.HorizontalAlignment='center';
        if length(handles.leftPanel.String)>14
            handles.leftPanel.Style='edit';
            handles.leftPanel.Max=2;
        else
            handles.leftPanel.Style='text';
        end
        handles.footerLeftButton.Visible='on';
        handles.footerLeftButton.String='Download paper >>';
        %% Text shifting in
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[-12+13*xShift 1 1 1].*originalPosition;
            handles.footerLeftButton.ForegroundColor=...
                xShift*handles.fgFooter+(1-xShift)*handles.bgFooter;
            pause(.01);
        end
        %% Setting window state
        handles.state='tips';
        handles.tips.String='<<';
    case 'tips'
        %% Button highlighting
        handles.tipsPanel.HighlightColor= ...
            [1 1 1]-handles.tipsPanel.HighlightColor;
        handles.tips.ForegroundColor=...
            [1 1 1]-handles.tips.ForegroundColor;
        %% Text shifting out
        originalPosition=handles.leftPanel.Position;
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[1-13*xShift 1 1 1].*originalPosition;
            pause(.01);
        end
        handles.tipsPanel.HighlightColor= ...
            [1 1 1]-handles.tipsPanel.HighlightColor;
        handles.tips.ForegroundColor=...
            [1 1 1]-handles.tips.ForegroundColor;
        %% Changing text and position
        handles.leftPanel.String=handles.defaultLeftPanelString;
        handles.leftPanel.HorizontalAlignment='center';
        originalPosition=handles.defaultLeftPanelPosition;
        %% Text shifting in
        for xShift=0.1:0.1:1
            handles.leftPanel.Position=[-12+13*xShift 1 1 1].*originalPosition;
            handles.footerLeftButton.ForegroundColor=...
                (1-xShift)*handles.fgFooter+xShift*handles.bgFooter;
            pause(.01);
        end
        %% Setting window state
        handles.footerLeftButton.Visible='off';
        handles.state='default';
        handles.tips.String='References';
        handles.tipsState=1;
        handles.tipsLeftPanelString=...
            {'The estimation technique used by this software is fully described in';
            '';
            'Barletta A, Santucci de Magistris P, Violante F';
            'A Non-Structural Investigation of VIX Risk Neutral Density (March 31, 2017)'
            'Available at SSRN.'
            };
end
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over acknowledgements.
function acknowledgements_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to acknowledgements (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.acknowledgements.ForegroundColor=[1 1 1]-handles.defaultFGColor;
pause(.1);
handles.acknowledgements.ForegroundColor=handles.defaultFGColor;
switch(handles.state)
    case 'about'
        %% Text shifting out
        originalPositionR=handles.rightPanel.Position;
        for xShift=0.1:0.1:1
            handles.rightPanel.Position=[1+xShift 1 1 1].*originalPositionR;
            pause(.01);
        end
        %% Changing text and position
        handles.rightPanel.String=handles.acknowledgementsRightPanelString;
        if length(handles.rightPanel.String)>14
            handles.rightPanel.Style='edit';
        else
            handles.rightPanel.Style='text';
        end
        %% Text shifting in
        for xShift=0.1:0.1:1
            handles.rightPanel.Position=[2-xShift 1 1 1].*originalPositionR;
            pause(.01);
        end
        %% Setting window state
        handles.state='acknowledgements';
        handles.acknowledgements.HorizontalAlignment='right';
        handles.acknowledgements.String='<<';
    case 'acknowledgements'
        %% Text shifting out
        originalPositionR=handles.rightPanel.Position;
        for xShift=0.1:0.1:1
            handles.rightPanel.Position=[1+xShift 1 1 1].*originalPositionR;
            pause(.01);
        end
        %% Changing text and position
        handles.rightPanel.String=handles.aboutRightPanelString;
        if length(handles.rightPanel.String)>14
            handles.rightPanel.Style='edit';
        else
            handles.rightPanel.Style='text';
        end
        %% Text shifting in
        for xShift=0.1:0.1:1
            handles.rightPanel.Position=[2-xShift 1 1 1].*originalPositionR;
            pause(.01);
        end
        %% Setting window state
        handles.state='about';
        handles.acknowledgements.HorizontalAlignment='center';
        handles.acknowledgements.String='Further acknowledgements >>';
end
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over footerLeftButton.
function footerLeftButton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to footerLeftButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.footerLeftButton.ForegroundColor=[1 1 1]-handles.defaultFGColor;
pause(.1);
handles.footerLeftButton.ForegroundColor=handles.defaultFGColor;
switch handles.state
    case 'supportedData'
        %dlhelper;
        msgbox('Invalid action');
    case 'about'
        subject='Risk-Neutral Density Fitting Tool';
        if isempty(handles.cc)==0
            if ispc==1
                dos(['start "" "mailto:' handles.authorMail '?cc=' handles.cc ...
                    '&subject=' subject '"']);
            elseif isunix==1
                try
                    unix(['mail -s "' subject '" ' handles.authorMail]);
                catch ME
                    errordlg('It was not possible to run email client.')
                end
            end
        else
            if ispc==1
                dos(['start "" "mailto:' handles.authorMail ...
                    '&subject=' subject '"']);
            elseif isunix==1
                try
                    unix(['mail -s "' subject '" ' handles.authorMail]);
                catch ME
                    errordlg('It was not possible to run email client.')
                end
            end
        end
    case 'tips'
        nt=handles.ntips;
        handles.tipsState=handles.tipsState+1;
        if handles.tipsState>nt
            handles.tipsState=1;
        end
        handles.footerLeftButton.Visible='on';
        handles.footerLeftButton.String='Download paper >>';
        % Opening paper link
        url='https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2943964';
        if ispc==1
            dos(['start ' url]);
        elseif isunix==1
            unix(['xdg-open' url]);
        end
        % Setting window state
        handles.state='tips';
        handles.tips.String='<<';
end
guidata(hObject, handles);
