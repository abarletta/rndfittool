function varargout = selmat(varargin)
% SELMAT MATLAB code for selmat.fig
%      SELMAT, by itself, creates a new SELMAT or raises the existing
%      singleton*.
%
%      H = SELMAT returns the handle to a new SELMAT or the handle to
%      the existing singleton*.
%
%      SELMAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELMAT.M with the given input arguments.
%
%      SELMAT('Property','Value',...) creates a new SELMAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selmat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selmat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selmat

% Last Modified by GUIDE v2.5 11-May-2016 12:41:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selmat_OpeningFcn, ...
                   'gui_OutputFcn',  @selmat_OutputFcn, ...
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


% --- Executes just before selmat is made visible.
function selmat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selmat (see VARARGIN)

% Choose default command line output for selmat
handles.output = hObject;
handles.outData = 1;
handles.ischild=0;

if isempty(varargin)==0
    source=datestr(varargin{1});
    q=handles.sourceSelection;
    q.String=source;
    if length(varargin)>=3
        handles.figure1.Name=varargin{2};
        handles.sourceText.String=varargin{3};
        if length(varargin)==4
            handles.ischild=1;
        end
    end
    
    if length(varargin)==2
        handles.ischild=1;
    end
        
%     for i=1:rows(source)
%         fprintf(source(i,:));
%         fprintf('\n');
%     end
else
    msgbox('No date was detected.','Error','error');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selmat wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = selmat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.outData;
    
delete(hObject);

if (strcmp(handles.outData,'cancelRequest')==1)&&(handles.ischild==1)
    selsrc;
end

% --- Executes on selection change in sourceSelection.
function sourceSelection_Callback(hObject, eventdata, handles)
% hObject    handle to sourceSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sourceSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sourceSelection

src=get(hObject,'Value');
handles.outData=src;

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
    uiresume(h);
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
    uiresume(h);
else
    delete(h);
end
