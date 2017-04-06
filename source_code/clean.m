function varargout = clean(varargin)
% CLEAN MATLAB code for clean.fig
%      CLEAN, by itself, creates a new CLEAN or raises the existing
%      singleton*.
%
%      H = CLEAN returns the handle to a new CLEAN or the handle to
%      the existing singleton*.
%
%      CLEAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLEAN.M with the given input arguments.
%
%      CLEAN('Property','Value',...) creates a new CLEAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before clean_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to clean_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help clean

% Last Modified by GUIDE v2.5 02-Oct-2015 13:24:12
% Last Manually Modified 08-May-2015

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @clean_OpeningFcn, ...
                   'gui_OutputFcn',  @clean_OutputFcn, ...
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


% --- Executes just before clean is made visible.
function clean_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to clean (see VARARGIN)

%% Choose default command line output for clean
handles.output = hObject;
handles.inData=varargin{1};
handles.inDataBack={};
handles.inDataForth={};
handles.outData={};
handles.redoFlag=1;
handles.undoFlag=1;

%% Setting theme
if length(varargin)>=2
    handles.theme=varargin{2};
else
    handles.theme='light';
end

switch handles.theme
    case 'light'
        bgCol=[1 1 1];
    case 'dark'
        bgCol=[0 0 0];
end

baCol=.3+.6*sin(bgCol*(pi/2));
gridCol=[1 1 1]-bgCol;
lgdCol=gridCol;

mainFig=handles.figure1;
mainFig.Color=.2+.74*sin(bgCol*(pi/2));
set(findobj(mainFig,'-property', 'BackgroundColor'), ...
   'BackgroundColor', mainFig.Color);
set(findobj(mainFig,'-property', 'ForegroundColor'), ...
    'ForegroundColor', gridCol);
set(findobj(mainFig,'-property', 'ShadowColor'), ...
    'ShadowColor',bgCol);
set(findobj(mainFig,'-property', 'HighlightColor'), ...
    'HighlightColor', abs(bgCol-0.3));

%% Setting maturity
if length(varargin)>=3
    handles.T=varargin{3};
else
    handles.T=[];
end

%% Creating data table
s={' '; '>>'; ' '; ' ';' ';' '; ' '; ' '; ' '; ' '};
switch handles.theme
    case 'light'
        bgCol=[.25 .25 .25];
        fgCol=[1 1 1];
    case 'dark'
        fgCol=gridCol;
end
handles.data_table=uicontrol('Parent',handles.uipanel10,...
    'Units','normalized',...
    'Position',[0.025,0.05,0.6,0.9],...
    'Style','edit',...
    'Max',2,...
    'Enable','inactive',...
    'BackgroundColor', bgCol, ...
    'ForegroundColor', fgCol, ...
    'FontName', 'Courier New', ...
    'FontSize', 8, ...
    'HorizontalAlignment', 'center', ...
    'String',s);

%% Set some relevant data
inData=varargin{1};
K=inData{1};
handles.maxBound=max(K);
handles.minBound=min(K);
call=inData{2};
put=inData{3};
m=inData{4};
if isempty(m)==1
    m=[mean(call-put+K), 0];
    mWasEmpty=1;
else
    mWasEmpty=0;
end
handles.baspr=round(max(abs(call-put+K-m(1)))*1.05,2,'significant');
handles.mbox=[];
handles.vbox=[];
r=inData{5};
handles.irate_box.String=num2str(100*r);
baspr=handles.baspr;
handles.basprbox=[];

%% Updating
guidata(hObject, handles);
refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);

%% Set graphics
if mWasEmpty==0
    set(handles.mean_box, 'String', num2str(m(1),'%.2f'));
    set(handles.variance_box, 'String', num2str(m(2)-m(1)^2,'%.2f'));
else
    set(handles.mean_box, 'String', 'Insert mean');
    set(handles.variance_box, 'String', 'Insert variance');
end
set(handles.baspr_box, 'String', num2str(baspr));
set(handles.minBound_box, 'String', num2str(handles.minBound));
set(handles.maxBound_box, 'String', num2str(handles.maxBound));

% UIWAIT makes clean wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = clean_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.outData;
delete(hObject);


% --- Executes on button press in apply.
function apply_Callback(hObject, eventdata, handles)
% hObject    handle to apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=gcf;
if isequal(get(h,'waitstatus'),'waiting')
    uiresume(h)
else
    delete(h);
end
%delete(hObject);

% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.outData=[];
guidata(hObject,handles);
h=gcf;
if isequal(get(h,'waitstatus'),'waiting')
    uiresume(h)
else
    delete(h);
end
%delete(hObject);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.outData)==0
    % Construct a questdlg with two options
    choice = questdlg('Do you want apply changes before exiting?', ...
        'Exit request','Apply and exit', ...
        'Exit without applying changes', 'Apply and exit');
    % Handle response
    switch choice
        case 'Apply and exit'
            h=gcf;
            if isequal(get(h,'waitstatus'),'waiting')
                uiresume(h)
            else
                delete(h);
            end
        case 'Exit without applying changes'
            handles.outData=[];
            guidata(hObject,handles);
            h=gcf;
            if isequal(get(h,'waitstatus'),'waiting')
                uiresume(h)
            else
                delete(h);
            end
    end
else
    h=gcf;
    if isequal(get(h,'waitstatus'),'waiting')
        uiresume(h)
    else
        delete(h);
    end
end

% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (isempty(handles.outData)==0)&&(handles.undoFlag==0)
    handles.inDataForth=handles.outData;
    handles.outData=handles.inDataBack;
    handles.undoFlag=1;
    handles.redoFlag=0;
    % Set some relevant data
    inData=handles.outData;
    K=inData{1};
    handles.maxBound=max(K);
    handles.minBound=min(K);
    call=inData{2};
    put=inData{3};
    m=inData{4};
    if isempty(m)==1
        m=[mean(call-put+K), 0];
        mWasEmpty=1;
    else
        mWasEmpty=0;
    end
    handles.mbox=m(1);
    handles.vbox=m(2)-m(1)^2;
    r=inData{5};
    baspr=handles.baspr;
    % Updating
    guidata(hObject,handles);
    refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);
    % Set graphics
    if mWasEmpty==0
        set(handles.mean_box, 'String', num2str(m(1)));
        set(handles.variance_box, 'String', num2str(m(2)-m(1)^2));
    else
        set(handles.mean_box, 'String', 'Insert mean');
        set(handles.variance_box, 'String', 'Insert variance');
    end
    set(handles.minBound_box, 'String', num2str(handles.minBound));
    set(handles.maxBound_box, 'String', num2str(handles.maxBound));
end

% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outData=handles.outData;
if isempty(outData)==0
    [nam,pth] = uiputfile('*.mat','Export data');
    if ne(nam,0)==1
        K=outData{1};
        call=outData{2};
        put=outData{3};
        m=outData{4};
        r=outData{5};
        if length(outData)>=6
            obsDate=outData{6};
            if length(outData)==6
                save([pth nam],'K','call','put','r', 'm','obsDate');
            elseif length(outData)>=7
                expDate=outData{7};
                if length(outData)==7
                    save([pth nam],'K','call','put','r', 'm','obsDate','expDate');
                elseif length(outData)>=8
                    if length(outData)==11
                        call_a=outData{8};
                        call_b=outData{9};
                        put_a=outData{10};
                        put_b=outData{11};
                        save([pth nam],'K','call','put','r', 'm','obsDate','expDate', ...
                            'call_a','call_b','put_a','put_b');
                    else
                        save([pth nam],'K','call','put','r', 'm','obsDate','expDate');
                    end
                end
            end
        end    
    end
else
    choice = questdlg('Original data was not modified. Do you still want to export it?', ...
        'Export data','Yes', ...
        'No', 'Yes');
    % Handle response
    if strcmp(choice,'Yes')==1
        outData=handles.inData;
        [nam,pth] = uiputfile('*.mat','Export data');
        if ne(nam,0)==1
            K=outData{1};
            call=outData{2};
            put=outData{3};
            m=outData{4};
            r=outData{5};
            if length(outData)>=6
                obsDate=outData{6};
                if length(outData)==6
                    save([pth nam],'K','call','put','r', 'm','obsDate');
                elseif length(outData)>=7
                    expDate=outData{7};
                    if length(outData)==7
                        save([pth nam],'K','call','put','r', 'm','obsDate','expDate');
                    elseif length(outData)>=8
                        if length(outData)==11
                            call_a=outData{8};
                            call_b=outData{9};
                            put_a=outData{10};
                            put_b=outData{11};
                            save([pth nam],'K','call','put','r', 'm','obsDate','expDate', ...
                                'call_a','call_b','put_a','put_b');
                        else
                            save([pth nam],'K','call','put','r', 'm','obsDate','expDate');
                        end
                    end
                end
            end
        end
    
    end
end

% --- Executes on button press in redo.
function redo_Callback(hObject, eventdata, handles)
% hObject    handle to redo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (isempty(handles.outData)==0)&&(handles.redoFlag==0)
    handles.inDataBack=handles.outData;
    handles.outData=handles.inDataForth;
    handles.redoFlag=1;
    handles.undoFlag=0;
    % Set some relevant data
    inData=handles.outData;
    K=inData{1};
    handles.maxBound=max(K);
    handles.minBound=min(K);
    call=inData{2};
    put=inData{3};
    m=inData{4};
    if isempty(m)==1
        m=[mean(call-put+K), 0];
        mWasEmpty=1;
    else
        mWasEmpty=0;
    end
    r=inData{5};
    handles.mbox=m(1);
    handles.vbox=m(2)-m(1)^2;
    baspr=handles.baspr;
    % Updating
    guidata(hObject,handles);
    refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);

    % Set graphics
    if mWasEmpty==0
        set(handles.mean_box, 'String', num2str(m(1)));
        set(handles.variance_box, 'String', num2str(m(2)-m(1)^2));
    else
        set(handles.mean_box, 'String', 'Insert mean');
        set(handles.variance_box, 'String', 'Insert variance');
    end
    set(handles.minBound_box, 'String', num2str(handles.minBound));
    set(handles.maxBound_box, 'String', num2str(handles.maxBound));
end

% --- Executes on button press in update.
function update_Callback(hObject, eventdata, handles)
% hObject    handle to update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (isempty(handles.mbox)==0)||(isempty(handles.vbox)==0)
    if isempty(handles.outData)==0
        handles.inDataBack=handles.outData;
        inData=handles.outData;
    else
        handles.inDataBack=handles.inData;
        inData=handles.inData;
    end
    if isempty(handles.vbox)==1
        handles.vbox=inData{4}(2)-(inData{4}(1))^2;
    end
    if isempty(handles.mbox)==1
        handles.mbox=inData{4}(1);
    end
    inData{4}=[handles.mbox, handles.vbox+(handles.mbox)^2];
    handles.outData=inData;
    handles.redoFlag=1;
    handles.undoFlag=0;
    guidata(hObject,handles);
    
    % Set some relevant data
    K=inData{1};
    call=inData{2};
    put=inData{3};
    m=inData{4};
    if isempty(m)==1
        m=[mean(call-put+K), 0];
        mWasEmpty=1;
    else
        mWasEmpty=0;
    end
    r=inData{5};
    baspr=handles.baspr;
    % Plotting
    refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);

    % Set graphics
    if mWasEmpty==0
        set(handles.mean_box, 'String', num2str(m(1)));
        set(handles.variance_box, 'String', num2str(m(2)-m(1)^2));
    else
        set(handles.mean_box, 'String', 'Insert mean');
        set(handles.variance_box, 'String', 'Insert variance');
    end
end

function variance_box_Callback(hObject, eventdata, handles)
% hObject    handle to variance_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of variance_box as text
%        str2double(get(hObject,'String')) returns contents of variance_box as a double
handles.vbox=round(str2double(get(hObject,'String')),2);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function variance_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variance_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mean_box_Callback(hObject, eventdata, handles)
% hObject    handle to mean_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mean_box as text
%        str2double(get(hObject,'String')) returns contents of mean_box as a double
handles.mbox=round(str2double(get(hObject,'String')),2);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function mean_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mean_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Choose default command line output for clean
if isempty(handles.outData)==0
    handles.inDataBack={};
    handles.inDataForth={};
    handles.outData={};
    handles.redoFlag=1;
    handles.undoFlag=1;
    % Set some relevant data
    inData=handles.inData;
    K=inData{1};
    handles.maxBound=max(K);
    handles.minBound=min(K);
    call=inData{2};
    put=inData{3};
    handles.baspr=round(max(abs(call-put+K-mean(call-put+K)))*1.05,2,'significant');
    m=inData{4};
    if isempty(m)==1
        mWasEmpty=1;
        m=[mean(call-put+K), 0];
    else
        mWasEmpty=0;
    end
    handles.mbox=[];
    handles.vbox=[];
    r=inData{5};
    baspr=handles.baspr;
    handles.basprbox=[];
    % Update handles structure
    guidata(hObject, handles);
    refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);

    % Set graphics
    if mWasEmpty==0
        set(handles.mean_box, 'String', num2str(m(1)));
        set(handles.variance_box, 'String', num2str(m(2)-m(1)^2));
    else
        set(handles.mean_box, 'String', 'Insert mean');
        set(handles.variance_box, 'String', 'Insert variance');
    end
    set(handles.baspr_box, 'String', num2str(baspr));
    set(handles.minBound_box, 'String', num2str(handles.minBound));
    set(handles.maxBound_box, 'String', num2str(handles.maxBound));
end


% --- Executes on button press in concavity.
function concavity_Callback(hObject, eventdata, handles)
% hObject    handle to concavity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.outData)==0
    handles.inDataBack=handles.outData;
    inData=handles.outData;
else
    handles.inDataBack=handles.inData;
    inData=handles.inData;
end
handles.redoFlag=1;
handles.undoFlag=0;
K=inData{1};
call=inData{2};
put=inData{3};
[vc, vp]=checkPrices(K,call,put);
if (isempty(vc)==0)||(isempty(vp)==0)
    flag=0;
else
    flag=1;
end
counter=0;
while (flag==0)&&(counter<=5)
    counter=counter+1;
    cldata=cleandata(K,call,put);
    inData{2}=cldata(:,1);
    inData{3}=cldata(:,2);
    % Updating
    handles.outData=inData;
    K=inData{1};
    call=inData{2};
    put=inData{3};
    m=inData{4};
    if isempty(m)==1
        m=[mean(call-put+K), 0];
        mWasEmpty=1;
    else
        mWasEmpty=0;
    end
    handles.mbox=m(1);
    handles.vbox=m(2)-m(1)^2;
    r=inData{5};
    baspr=handles.baspr;
    guidata(hObject,handles);
    refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);
    
    % Set graphics
    if mWasEmpty==0
        set(handles.mean_box, 'String', num2str(m(1)));
        set(handles.variance_box, 'String', num2str(m(2)-m(1)^2));
    else
        set(handles.mean_box, 'String', 'Insert mean');
        set(handles.variance_box, 'String', 'Insert variance');
    end
    [vc, vp]=checkPrices(K,call,put);
    if (isempty(vc)==0)||(isempty(vp)==0)
        flag=0;
    else
        flag=1;
    end
end

% --- Executes on button press in parity.
function parity_Callback(hObject, eventdata, handles)
if isempty(handles.outData)==0
    handles.inDataBack=handles.outData;
    inData=handles.outData;
else
    handles.inDataBack=handles.inData;
    inData=handles.inData;
end
handles.redoFlag=1;
handles.undoFlag=0;
K=inData{1};
call=inData{2};
put=inData{3};
m=inData{4};
r=inData{5};
if isempty(m)==1
    mWasEmpty=1;
    m=[mean(call-put+K), 0];
else
    mWasEmpty=0;
end
baspr=handles.baspr;
cldata=setparity(K,m(1),call,put,baspr);
inData{2}=cldata(:,1);
inData{3}=cldata(:,2);
% Updating
handles.outData=inData;
K=inData{1};
call=inData{2};
put=inData{3};
handles.mbox=m(1);
handles.vbox=m(2)-m(1)^2;
guidata(hObject,handles);
refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);
% Set graphics
if mWasEmpty==0
        set(handles.mean_box, 'String', num2str(m(1)));
        set(handles.variance_box, 'String', num2str(m(2)-m(1)^2));
else
        set(handles.mean_box, 'String', 'Insert mean');
        set(handles.variance_box, 'String', 'Insert variance');
        msgbox('As no value was given for mean, then it was automatically guessed.')
end

% hObject    handle to parity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function baspr_box_Callback(hObject, eventdata, handles)
% hObject    handle to baspr_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.basprbox=str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function baspr_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baspr_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setspr.
function setspr_Callback(hObject, eventdata, handles)
% hObject    handle to setspr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.basprbox)==0
    handles.baspr=handles.basprbox;
    guidata(hObject,handles);
    if isempty(handles.outData)==0
        inData=handles.outData;
    else
        inData=handles.inData;
    end
    K=inData{1};
    call=inData{2};
    put=inData{3};
    m=inData{4};
    if isempty(m)==1
        m=[mean(call-put+K), 0];
    end
    baspr=handles.baspr;
    refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);

end


% --- Executes on button press in smooth.
function smooth_Callback(hObject, eventdata, handles)
if isempty(handles.outData)==0
    handles.inDataBack=handles.outData;
    inData=handles.outData;
else
    handles.inDataBack=handles.inData;
    inData=handles.inData;
end
handles.redoFlag=1;
handles.undoFlag=0;
m=inData{4};
if isempty(m)==1
    mWasEmpty=1;
    m=[mean(inData{2}-inData{3}+inData{1}), 0];
else
    mWasEmpty=0;
end
baspr=handles.baspr;
inData{2}=smooth(inData{2},1);
inData{3}=smooth(inData{3},1);
% Updating
handles.outData=inData;
K=inData{1};
call=inData{2};
put=inData{3};
handles.mbox=m(1);
handles.vbox=m(2)-m(1)^2;
r=inData{5};
guidata(hObject,handles);
refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);
% Set graphics
if mWasEmpty==0
    set(handles.mean_box, 'String', num2str(m(1)));
    set(handles.variance_box, 'String', num2str(m(2)-m(1)^2));
else
    set(handles.mean_box, 'String', 'Insert mean');
    set(handles.variance_box, 'String', 'Insert variance');
end
% hObject    handle to smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in estimate.
function estimate_Callback(hObject, eventdata, handles)
if isempty(handles.outData)==0
    inData=handles.outData;
else
    inData=handles.inData;
end
% Estimating mean
% if -1>0
%     T=handles.T;
%     ivcall=@(F) blsimpv(F, inData{1}, inData{5}, T, inData{2}, [], 0, 1e-6,{'call'});
%     ivput=@(F) blsimpv(F, inData{1}, inData{5}, T, inData{3}, [], 0, 1e-6,{'put'});
%     crF=@(F) nanmean(ivcall(F)-ivput(F));
%     F0=mean(inData{2}-inData{3}+inData{1});
%     options = optimoptions('lsqnonlin');
%     options.Display='off';
%     handles.mbox=lsqnonlin(crF,F0,0.95*F0,1.05*F0,options);
% else
handles.mbox=mean(inData{2}-inData{3}+inData{1});
% end

% Estimating variance
K=inData{1};
F=handles.mbox;
call=inData{2};
put=inData{3};
if ~isempty(handles.T)
    r=inData{5};
    U=exp(handles.T*r);
else
    U=1;
end
if F<0
    msgbox('Estimated mean was negative and will now be set to zero.');
    handles.mbox=0;
    F=0;
end
[K0,~]=max(K(K<=F));
P=put(K<K0);
KP=K(K<K0);
C=call(K>K0);
KC=K(K>K0);
Q=U*[C;P];
K=[KC; KP];
if ~isempty(KP)
    dKP=NaN(size(P));
    dKP(1)=KP(2)-KP(1);
    dKP(end)=KP(end)-KP(end-1);
    dKP(2:end-1)=0.5*(KP(3:end)-KP(1:end-2));
else
    dKP=[];
end
if ~isempty(KC)
    dKC=NaN(size(C));
    dKC(1)=KC(2)-KC(1);
    dKC(end)=KC(end)-KC(end-1);
    dKC(2:end-1)=0.5*(KC(3:end)-KC(1:end-2));
else
    dKC=[];
end
deltaK=[dKC; dKP];
handles.vbox=2*sum(deltaK.*Q)+3*(F-K0)^2;
if handles.vbox<0
    msgbox('Estimated variance was negative and will now be set to zero.');
    handles.vbox=0;
end
set(handles.mean_box, 'String', num2str(round(handles.mbox,2)));
set(handles.variance_box, 'String', num2str(round(handles.vbox,2)));
guidata(hObject,handles)
% hObject    handle to estimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in setBoundaries.
function setBoundaries_Callback(hObject, eventdata, handles)
% hObject    handle to setBoundaries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.outData)==0
    handles.inDataBack=handles.outData;
    inData=handles.outData;
else
    handles.inDataBack=handles.inData;
    inData=handles.inData;
end
handles.redoFlag=1;
handles.undoFlag=0;
K=inData{1};
call=inData{2};
put=inData{3};
m=inData{4};
if isempty(m)==1
    mWasEmpty=1;
    m=[mean(call-put+K), 0];
else
    mWasEmpty=0;
end
baspr=handles.baspr;
if length(inData)==11
    call_a=inData{8};
    call_b=inData{9};
    put_a=inData{10};
    put_b=inData{11};
end

% Setting boundaries
n=length(K);
maxHasChanged=0;
minHasChanged=0;
% Low boundary
K=union(K,handles.minBound);
minK=find(K==handles.minBound,1,'last');
if length(K)>n  % Point was added
    minHasChanged=1;
    if minK==1 % Point was added at beginning
        put=[0; put];
        call0=interp1(K(2:3), call(1:2), K(1:3), 'linear', 'extrap');
        call=[call0(1); call];
        if length(inData)==11
            call_a=[call(1); call_a];
            call_b=[call(1); call_b];
            put_a=[put(1); put_a];
            put_b=[put(1); put_b];
        end
    else
        put=[put(1:minK-1); 0; put(minK:end)];
        call0=interp1([K(minK-1) K(minK+1)],call(minK-1:minK),K(minK-1:minK+1), 'linear');
        call=[call(1:minK-1); call0(2); call(minK:end)];
        if length(inData)==11
            call_a=[call(minK); call_a(minK:end)];
            call_b=[call(minK); call_b(minK:end)];
            put_a=[put(minK); put_a(minK:end)];
            put_b=[put(minK); put_b(minK:end)];
        end
    end
else % Point was not added
    if length(inData)==11
        call_a=call_a(minK:end);
        call_b=call_b(minK:end);
        put_a=put_a(minK:end);
        put_b=put_b(minK:end);
    end
end
K=K(minK:end);
call=call(minK:end);
put=put(minK:end);
n=length(K);
% Up boundary
K=union(K,handles.maxBound);
maxK=find(K==handles.maxBound,1,'first');
if length(K)>n  % Point was added
    maxHasChanged=1;
    if maxK==length(K) % Point was added at the end
        call=[call; 0];
        put0=interp1(K(end-2:end-1), put(end-1:end), K(end-2:end), 'linear', 'extrap');
        put=[put; put0(end)];
         if length(inData)==11
            call_a=[call_a; call(end)];
            call_b=[call_b; call(end)];
            put_a=[put_a; put(end)];
            put_b=[put_b; put(end)];
        end
    else
        call=[call(1:maxK-1); 0; call(maxK+1:end)];
        put0=interp1([K(maxK-1) K(maxK+1)],put(maxK-1:maxK),K(maxK-1:maxK+1), 'linear');
        put=[put(1:maxK-1); put0(2); put(maxK+1:end)];
        if length(inData)==11
            call_a=[call_a(1:maxK-1); call(maxK)];
            call_b=[call_b(1:maxK-1); call(maxK)];
            put_a=[put_a(1:maxK-1); put(maxK)];
            put_b=[put_b(1:maxK-1); put(maxK)];
        end
    end
else % Point was not added
    if length(inData)==11
        call_a=call_a(1:maxK);
        call_b=call_b(1:maxK);
        put_a=put_a(1:maxK);
        put_b=put_b(1:maxK);
    end
end
K=K(1:maxK);
call=call(1:maxK);
put=put(1:maxK);
% Updating
inData{1}=K;
inData{2}=call;
inData{3}=put;
if length(inData)==11
    inData{8}=call_a;
    inData{9}=call_b;
    inData{10}=put_a;
    inData{11}=put_b;
end

% Updating
handles.outData=inData;
handles.mbox=m(1);
handles.vbox=m(2)-m(1)^2;
r=inData{5};
guidata(hObject,handles);
% Plotting
refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, ...
    handles.theme, minHasChanged, maxHasChanged);

% Set graphics
if mWasEmpty==0
        set(handles.mean_box, 'String', num2str(m(1)));
        set(handles.variance_box, 'String', num2str(m(2)-m(1)^2));
else
        set(handles.mean_box, 'String', 'Insert mean');
        set(handles.variance_box, 'String', 'Insert variance');
end

function minBound_box_Callback(hObject, eventdata, handles)
% hObject    handle to minBound_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

minBound=str2double(get(hObject,'String'));
if isempty(handles.outData)==0
    data=handles.outData;
else
    data=handles.inData;
end
if minBound<min(handles.maxBound,max(data{1}))
    handles.minBound=round(minBound,2);
    guidata(hObject,handles)
end

% Hints: get(hObject,'String') returns contents of minBound_box as text
%        str2double(get(hObject,'String')) returns contents of minBound_box as a double


% --- Executes during object creation, after setting all properties.
function minBound_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minBound_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxBound_box_Callback(hObject, eventdata, handles)
% hObject    handle to maxBound_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maxBound=str2double(get(hObject,'String'));
if isempty(handles.outData)==0
    data=handles.outData;
else
    data=handles.inData;
end
if maxBound>max(handles.minBound,min(data{1}))
    handles.maxBound=round(maxBound,2);
    guidata(hObject,handles)
end
% Hints: get(hObject,'String') returns contents of maxBound_box as text
%        str2double(get(hObject,'String')) returns contents of maxBound_box as a double


% --- Executes during object creation, after setting all properties.
function maxBound_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxBound_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in autoLowBoundaries.
function autoLowBoundaries_Callback(hObject, eventdata, handles)
if isempty(handles.outData)==0
    data=handles.outData;
else
    data=handles.inData;
end
K=data{1};
put=data{3};

% Finding min bound
if put(1)>0
    imin=find(round(put,2)==round(put(1),2),1,'last');
    m=(put(imin+1)-put(imin))/(K(imin+1)-K(imin));
    if m==0
        minBound=K(imin);
    else
        q=put(imin)-m*K(imin);
        minBound=max(-q/m,0);
    end
else
    minBound=K(1);
end

handles.minBound=round(minBound,2);
guidata(hObject,handles)
    
set(handles.minBound_box, 'String', num2str(handles.minBound));
% hObject    handle to autoLowBoundaries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in autoUpBoundaries.
function autoUpBoundaries_Callback(hObject, eventdata, handles)
if isempty(handles.outData)==0
    data=handles.outData;
else
    data=handles.inData;
end
K=data{1};
call=data{2};

% Finding max bound
if call(end)>0
    imax=find(round(call,2)==round(call(end),2),1,'first');
    m=(call(imax)-call(imax-1))/(K(imax)-K(imax-1));
    if m==0
        maxBound=K(imax);
    else
        q=call(imax)-m*K(imax);
        maxBound=-q/m;
    end
else
    maxBound=K(end);
end

handles.maxBound=round(maxBound,2);
guidata(hObject,handles)
    
set(handles.maxBound_box, 'String', num2str(handles.maxBound));
% hObject    handle to autoUpBoundaries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function irate_box_Callback(hObject, eventdata, handles)
% hObject    handle to irate_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of irate_box as text
%        str2double(get(hObject,'String')) returns contents of irate_box as a double


% --- Executes during object creation, after setting all properties.
function irate_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to irate_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in auto_irate.
function auto_irate_Callback(hObject, eventdata, handles)
% hObject    handle to auto_irate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.outData)==0
    handles.inDataBack=handles.outData;
    inData=handles.outData;
else
    handles.inDataBack=handles.inData;
    inData=handles.inData;
end
K=inData{1};
call=inData{2};
put=inData{3};
m=inData{4};
or=inData{5};
T=handles.T;

U0=exp(-or*T);
crF=@(x) (x*(call-put)+K)-mean(x*(call-put)+K);
options = optimoptions('lsqnonlin');
options.Display='off';
U=lsqnonlin(crF,1,U0,1.2,options);
nr=1/T*log(U)+or;
handles.irate_box.String=[num2str(round(100*nr,2))];



% --- Executes on button press in apply_irate.
function apply_irate_Callback(hObject, eventdata, handles)
% hObject    handle to apply_irate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.T)==0
    if isempty(handles.outData)==0
        handles.inDataBack=handles.outData;
        inData=handles.outData;
    else
        handles.inDataBack=handles.inData;
        inData=handles.inData;
    end
    handles.redoFlag=1;
    handles.undoFlag=0;
    
    
    K=inData{1};
    call=inData{2};
    put=inData{3};
    m=inData{4};
    or=inData{5};
    T=handles.T;
    nr=str2double(handles.irate_box.String)/100;
    inData{5}=nr;
    U=exp((-or+nr)*T);
    
    inData{1}=K;
    inData{2}=U*call;
    inData{3}=U*put;
    
    if length(inData)==11
        inData{8}=U*inData{8};
        inData{9}=U*inData{9};
        inData{10}=U*inData{10};
        inData{11}=U*inData{11};
    end
    
    % Updating
    handles.outData=inData;
    K=inData{1};
    call=inData{2};
    put=inData{3};
    m=inData{4};
    
    % Set graphics
    if isempty(m)==1
        m=[mean(call-put+K), 0];
    end
    handles.mbox=m(1);
    handles.vbox=m(2)-m(1)^2;
    baspr=handles.baspr;
    guidata(hObject,handles);
    refreshCLEAN(handles.figure1,K,call,put,handles.data_table,m, baspr, handles.theme);
else
    msgbox('It is not possible to edit interest rate as not value for time to maturity can be retrieved.');
end
