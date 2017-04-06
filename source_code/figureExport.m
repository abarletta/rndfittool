function varargout = figureExport(varargin)
% FIGUREEXPORT MATLAB code for figureExport.fig
%      FIGUREEXPORT, by itself, creates a new FIGUREEXPORT or raises the existing
%      singleton*.
%
%      H = FIGUREEXPORT returns the handle to a new FIGUREEXPORT or the handle to
%      the existing singleton*.
%
%      FIGUREEXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGUREEXPORT.M with the given input arguments.
%
%      FIGUREEXPORT('Property','Value',...) creates a new FIGUREEXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before figureExport_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to figureExport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figureExport

% Last Modified by GUIDE v2.5 03-Feb-2016 22:25:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figureExport_OpeningFcn, ...
                   'gui_OutputFcn',  @figureExport_OutputFcn, ...
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


% --- Executes just before figureExport is made visible.
function figureExport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figureExport (see VARARGIN)

% Choose default command line output for figureExport
handles.rootname=varargin{1}.String;
handles.format='fig';
handles.ratio=1/sqrt(2);
handles.wSizeSldr.Value=4;
I=strfind(varargin{2},'\');
if isempty(I)
    handles.outputDir=[];
else
    handles.outputDir=varargin{2}(1:I(end)-1);
end

handles.outputDirTag.String=handles.outputDir;
handles.rootnameTag.String=handles.rootname;
handles.hw=handles.axes1.Position;
handles.axes1.XTick=[];
handles.axes1.XTickLabel=[];
handles.axes1.XTickMode='manual';
handles.axes1.YTick=[];
handles.axes1.YTickLabel=[];
handles.axes1.YTickMode='manual';
handles.axes1.XLim=[-Inf Inf];
handles.axes1.Position(4)=handles.ratio*handles.hw(4);
handles.axes1.Position(2)=handles.hw(2)+0.5*(1-handles.ratio)*handles.hw(4);
text(0.33, 0.5,'ISO','FontSize',36);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes figureExport wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = figureExport_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if handles.buttonPNG.Value==1
    handles.format='png';
elseif handles.buttonPDF.Value==1
    handles.format='pdf';
elseif handles.buttonEPS.Value==1
    handles.format='eps';
else
    handles.format='fig';
end
guidata(hObject, handles);
varargout{1} = [handles.outputDir];
varargout{2} = handles.rootname;
varargout{3} = handles.format;
varargout{4} = handles.ratio;
delete(hObject);

% --- Executes on button press in exportBtn.
function exportBtn_Callback(hObject, eventdata, handles)
% hObject    handle to exportBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=gcf;
if isequal(get(h,'waitstatus'),'waiting')
    uiresume(h)
else
    delete(h);
end

% --- Executes on button press in cancelBtn.
function cancelBtn_Callback(hObject, eventdata, handles)
% hObject    handle to cancelBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.outputDir=[];
guidata(hObject, handles);
h=gcf;
if isequal(get(h,'waitstatus'),'waiting')
    uiresume(h)
else
    delete(h);
end


function rootnameTag_Callback(hObject, eventdata, handles)
% hObject    handle to rootnameTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rootname=hObject.String;
handles.rootnameTag.String=handles.rootname;
guidata(hObject, handles);


% Hints: get(hObject,'String') returns contents of rootnameTag as text
%        str2double(get(hObject,'String')) returns contents of rootnameTag as a double


% --- Executes during object creation, after setting all properties.
function rootnameTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rootnameTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectBtn.
function selectBtn_Callback(hObject, eventdata, handles)
% hObject    handle to selectBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newPath=uigetdir(handles.outputDir);
if ne(newPath,0)
    handles.outputDir=newPath;
    handles.outputDirTag.String=handles.outputDir;
    guidata(hObject, handles);
end

% --- Executes on slider movement.
function wSizeSldr_Callback(hObject, eventdata, handles)
% hObject    handle to wSizeSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pos=round(handles.wSizeSldr.Value);
ratioList=sort([3/7,1/2,9/16,1/sqrt(2),3/4]);
ratioString={'7:3','2:1','16:9','ISO','4:3'};
ratio=ratioList(pos);
h=handles.axes1;
h.Position(4)=ratio*handles.hw(4);
h.Position(2)=handles.hw(2)+0.5*(1-ratio)*handles.hw(4);
h.Children.String=ratioString{pos};
handles.ratio=ratio;
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function wSizeSldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wSizeSldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.outputDir=[];
guidata(hObject, handles);
h=gcf;
if isequal(get(h,'waitstatus'),'waiting')
    uiresume(h)
else
    delete(h);
end

% Hint: delete(hObject) closes the figure
