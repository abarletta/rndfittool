function varargout = selsrc(varargin)
% SELSRC MATLAB code for selsrc.fig
%      SELSRC, by itself, creates a new SELSRC or raises the existing
%      singleton*.
%
%      H = SELSRC returns the handle to a new SELSRC or the handle to
%      the existing singleton*.
%
%      SELSRC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELSRC.M with the given input arguments.
%
%      SELSRC('Property','Value',...) creates a new SELSRC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selsrc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selsrc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selsrc

% Last Modified by GUIDE v2.5 01-Sep-2015 18:30:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selsrc_OpeningFcn, ...
                   'gui_OutputFcn',  @selsrc_OutputFcn, ...
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


% --- Executes just before selsrc is made visible.
function selsrc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selsrc (see VARARGIN)

% Choose default command line output for selsrc
handles.output = hObject;
handles.outData = 'optMetrics';

% Input arguments
if length(varargin)==1
    close(varargin{1});
end

if length(varargin)==2
    Source=varargin{2};
    q=handles.sourceSelection;
    q.String=Source;
end

if length(varargin)==3
    q=handles.sourceSelection;
    q.Value=varargin{3};
end

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes selsrc wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = selsrc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
q=handles.sourceSelection;
str=get(q,'String');
src=get(q,'Value');
switch str{src};
    case 'OptionMetrics'
        varargout{2}='optMetrics';
    case 'CBOE'
        varargout{2}='cboe';
    otherwise
        varargout{2}='error';
end

%varargout{2} = handles.outData;
delete(hObject);

% --- Executes on selection change in sourceSelection.
function sourceSelection_Callback(hObject, eventdata, handles)
% hObject    handle to sourceSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sourceSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sourceSelection

str=get(hObject,'String');
src=get(hObject,'Value');
switch str{src};
    case 'OptionMetrics'
        handles.outData='optMetrics';
    case 'CBOE'
        handles.outData='cboe';
    otherwise
        msgbox('Unrecognized source','Error','error');
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sourceSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sourceSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in confirm.
function confirm_Callback(hObject, eventdata, handles)
% hObject    handle to confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=gcf;
if isequal(get(h,'waitstatus'),'waiting')
    uiresume(h)
else
    delete(h);
end

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.outData='cancelRequest';
guidata(hObject, handles);
h=gcf;
if isequal(get(h,'waitstatus'),'waiting')
    uiresume(h)
else
    delete(h);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.outData='cancelRequest';
guidata(hObject, handles);
h=gcf;
if isequal(get(h,'waitstatus'),'waiting')
    uiresume(h)
else
    delete(h);
end
