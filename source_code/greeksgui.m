function varargout = greeksgui(varargin)
% GREEKSGUI MATLAB code for greeksgui.fig
%      GREEKSGUI, by itself, creates a new GREEKSGUI or raises the existing
%      singleton*.
%
%      H = GREEKSGUI returns the handle to a new GREEKSGUI or the handle to
%      the existing singleton*.
%
%      GREEKSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GREEKSGUI.M with the given input arguments.
%
%      GREEKSGUI('Property','Value',...) creates a new GREEKSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before greeksgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to greeksgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help greeksgui

% Last Modified by GUIDE v2.5 06-Apr-2017 01:37:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @greeksgui_OpeningFcn, ...
                   'gui_OutputFcn',  @greeksgui_OutputFcn, ...
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


% --- Executes just before greeksgui is made visible.
function greeksgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to greeksgui (see VARARGIN)

inHandles=varargin{1};
% Choose default command line output for greeksgui
handles.output = hObject;

% Allocating data
handles.ratio=1/sqrt(2);

I0=strfind(inHandles.fname,'\');
if isempty(I0)
    I0=1;
    handles.currPath=[];
else
    handles.currPath=inHandles.fname(1:I0(end)-1);
end
IF=strfind(inHandles.fname,'.');
if isempty(IF)
    IF=length(inHandles.fname);
end
handles.currFileName=inHandles.fname(I0(end)+1:IF(1)-1);


handles.outFileText.String=[handles.currPath '\' handles.currFileName];
handles.ratioTxt.String='ISO';
handles.ratioSlider.Value=4;

% Loading data
kernelDensity=inHandles.kernelDensity;
kerPar=inHandles.glvar{3};
c=inHandles.glvar{1};
ATM=inHandles.inData{4}(1);
K=[0:min(diff(inHandles.inData{1})):0.5*ATM, ...
    0.5*ATM+0.25*min(diff(inHandles.inData{1})):0.25*min(diff(inHandles.inData{1})):1.5*ATM, ...
    1.5*ATM+min(diff(inHandles.inData{1})):1.5*max(inHandles.inData{1})];
K=union(K,inHandles.inData{1});
K=union(K,ATM);
K=sort(K);
nM=5;
% Extracting moments
[~,~,H]=extractCoefficients(kernelDensity,kerPar,nM,K,0);
momU=extractMoments(c,kernelDensity,kerPar,nM,0,'uncentered');
% Relating higher order moments to first moment
v=zeros(nM-1,1);
for ii=2:nM
    v(ii-1)=momU(ii+1)/(momU(2)^ii);
end
bt=diag(v,1);
bt=bt(1:end-1,:);
% Finding greeks
[~, Delta, Gamma]=greeks(H,momU,bt);
I0=find(round(abs(Delta),4)==0,1,'first');
if isempty(I0)
    I0=length(K);
end
I1=find(round(abs(Delta),5)==1,1,'last');
if isempty(I1)
    I1=1;
end
Delta=Delta(I1:I0);
Gamma=Gamma(I1:I0);
K=K(I1:I0);
handles.Delta=Delta;
handles.Gamma=Gamma;
handles.K=K;
handles.c=c;
handles.kernelDensity=kernelDensity;
handles.kerPar=kerPar;
handles.momU=momU;
I=find(K==ATM,1,'first');
% Plotting
h=handles.axesLeft;
plot(h,K,Delta,'LineWidth',2);
axis(h,'tight');
title(h,'Call Delta');
grid(h,'on');
box(h,'on');
axes(h);
line([ATM,ATM],[0 1],'LineStyle','--','LineWidth',2,'Color','black');
if Delta(I)<0.5
    vLoc=0.55;
else
    vLoc=0.05;
end
IT=find(h.XTick<=ATM,1,'last');
hLoc=0.9*ATM+0.1*h.XTick(IT);
text(hLoc,vLoc,'At-the-money','Rotation',90,'VerticalAlignment','bottom');
guidata(hObject,inHandles);
h=handles.axesRight;
plot(h,K,Gamma,'LineWidth',2);
axis(h,'tight');
title(h,'Call Gamma');
grid(h,'on');
box(h,'on');
axes(h);
line([ATM,ATM],[0 max(Gamma)],'LineStyle','--','LineWidth',2,'Color','black');
if Gamma(I)<0.5*abs(diff(h.YLim))
    vLoc=0.5*abs(diff(h.YLim));
else
    vLoc=0.05*abs(diff(h.YLim));
end
text(hLoc,vLoc,'At-the-money','Rotation',90,'VerticalAlignment','bottom');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes greeksgui wait for user response (see UIRESUME)
% uiwait(handles.Greeks);


% --- Outputs from this function are returned to the command line.
function varargout = greeksgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function ratioSlider_Callback(hObject, eventdata, handles)
% hObject    handle to ratioSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fmtVec=sort([3/7,1/2,9/16,1/sqrt(2),3/4]);
fmtStr={'7:3','2:1','16:9','ISO','4:3'};
pos=floor(handles.ratioSlider.Value);
handles.ratio=fmtVec(pos);
handles.ratioTxt.String=fmtStr{pos};
% Update handles structure
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function ratioSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ratioSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in outFileButton.
function outFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to outFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path=uigetdir(handles.currPath, 'Choose output folder');
if ne(path,0)
    handles.currPath=path;
    handles.outFileText.String=[path '\' handles.currFileName];
    % Update handles structure
    guidata(hObject, handles);
end
% --- Executes on button press in exportPlotButton.
function exportPlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportPlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

outFile=handles.outFileText.String;
hDelta=figure;
hDelta.WindowStyle='normal';
copyobj(handles.axesLeft,hDelta);
hDelta.Children.Units='normalized';
hDelta.Children.Position=[0.13,0.11,0.775,0.815];
hGamma=figure;
hDelta.WindowStyle='normal';
copyobj(handles.axesRight,hGamma);
hGamma.Children.Units='normalized';
hGamma.Children.Position=[0.13,0.11,0.775,0.815];

if handles.pngFmtButton.Value==1
    format='png';
elseif handles.pdfFmtButton.Value==1
    format='pdf';
elseif handles.epsFmtButton.Value==1
    format='eps';
else
    format='fig';
end

switch format
    case 'fig'
        hDelta.Position(4)=handles.ratio*hDelta.Position(3);
        hGamma.Position(4)=handles.ratio*hGamma.Position(3);
        savefig(hDelta,[outFile '_delta.fig']);
        savefig(hGamma,[outFile '_gamma.fig']);
    case 'pdf'
        hDelta.Children.Position=[0.065,0.082,0.92,0.84];
        hGamma.Children.Position=[0.065,0.082,0.92,0.84];
        hDelta.Children.FontSize=18;
        hDelta.Children.Children(1).FontSize=18;
        hGamma.Children.FontSize=18;
        hGamma.Children.Children(1).FontSize=18;
        cf2pdf(handles.ratio,[outFile '_delta.pdf'],hDelta);
        cf2pdf(handles.ratio,[outFile '_gamma.pdf'],hGamma);
    case 'eps'
        hDelta.Children.Position=[0.065,0.082,0.92,0.84];
        hGamma.Children.Position=[0.065,0.082,0.92,0.84];
        hDelta.Children.FontSize=18;
        hDelta.Children.Children(1).FontSize=18;
        hGamma.Children.FontSize=18;
        hGamma.Children.Children(1).FontSize=18;
        cf2eps(handles.ratio,[outFile '_delta.eps'],hDelta);
        cf2eps(handles.ratio,[outFile '_gamma.eps'],hGamma);        
    case 'png'
        hDelta.Children.Position=[0.065,0.082,0.92,0.84];
        hGamma.Children.Position=[0.065,0.082,0.92,0.84];
        hDelta.Children.FontSize=18;
        hDelta.Children.Children(1).FontSize=18;
        hGamma.Children.FontSize=18;
        hGamma.Children.Children(1).FontSize=18;
        cf2png(handles.ratio,[outFile '_delta.png'],hDelta);
        cf2png(handles.ratio,[outFile '_gamma.png'],hGamma);
    otherwise
        msgbox('Unrecognized file format');
end
close(hDelta);
close(hGamma);
msgbox({'Exported: '; ... 
    [outFile '_delta.' format]; ...
    [outFile '_gamma.' format]});


% --- Executes on button press in exportDataButton.
function exportDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to exportDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outFile=handles.outFileText.String;
Delta=handles.Delta;
Gamma=handles.Gamma;
K=handles.K;
c=handles.c;
kernelDensity=handles.kernelDensity;
kerpar=handles.kerPar;
momU=handles.momU;
save([outFile '_greeks'],'K','Delta','Gamma','c','kernelDensity','kerpar', ...
    'momU');
msgbox(['Exported ' outFile '_greeks.mat']);
