function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 05-Apr-2017 12:00:11
% Last Manually Modified 27-Sep-2016

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user fcont (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

%% Choose default handles values for gui
handles.output = hObject;
handles.fname='No file name';
% Fetching kernelMenu list
[kernelList, kernelLabels, ~, ~] = findKernels('kernels');
handles.kernelMenu.String=kernelList;
handles.kernelLabels=kernelLabels;
% Default algorithm parameters
handles.order=10;
handles.mode='normal';
handles.kernel=handles.kernelLabels{1};
load(['kernels\' handles.kernel '.mat']);
handles.kernelDensity=kernelDensity;
handles.threshold=0.99;
handles.cuttingThreshold=0;
handles.cuttingThresholdPlots=0;
handles.regressionPriority='fitting';
handles.restrictMean=false;
% Setting output and backup data to void as default value
handles.glvar=[];
handles.inData=[];
handles.backData=[];
handles.cleanRunning=0;
% Theme default settings
handles.theme='light';
bgCol=[1 1 1];
handles.lightBlue=[0  0.372549019607843  0.807843137254902];
% Plot default options
handles.plotScale='plain';
handles.plotType='prices';
% Structure to function dostuff.m
handles.DoStuff=struct;
handles.DoStuff.obsCall=[];
handles.DoStuff.obsPut=[];
handles.DoStuff.obsIVCall=[];
handles.DoStuff.obsIVCall_a=[];
handles.DoStuff.obsIVCall_b=[];
handles.DoStuff.obsIVPut=[];
handles.DoStuff.obsIVPut_a=[];
handles.DoStuff.obsIVPut_b=[];
handles.DoStuff.appCall=[];
handles.DoStuff.appPut=[];
handles.DoStuff.appCall0=[];
handles.DoStuff.appPut0=[];
handles.DoStuff.appIVCall=[];
handles.DoStuff.appIVPut=[];
handles.DoStuff.appIVCall0=[];
handles.DoStuff.appIVPut0=[];
handles.DoStuff.maturity=[];
handles.epsilon=[];
% History
handles.history=[];
handles.last=[];
handles.historyMenu.String={'History is empty'};
handles.historyMenu.Enable='off';
handles.historyEl=[];
handles.uipanel25rl=handles.uipanel1.Position(1)+handles.uipanel1.Position(3);
handles.showHistory=0;
rl=handles.uipanel1.Position(1)+handles.uipanel1.Position(3);
w=0.06;
x=rl-w;
handles.uipanel25.Position=[x 0.215 w 0.03];
handles.text35.FontSize=9;
handles.text35.Position=[.1 .1 .8 .8];
handles.text35.String='< History';
guidata(hObject,handles);
handles.historyMenu.Position=[0.072 0.215 0.001 0.03];
handles.historyMenu.Visible='off';
% Initializing default load path
handles.lastLoadPath=pwd;
% Getting right button panel initial position


%% Setting theme
if (length(varargin)>=1)&&(ischar(varargin{1})==1)
    switch varargin{1}
        case 'light'
            handles.theme='light';
            bgCol=[1 1 1];
        case 'dark'
            handles.theme='dark';
            bgCol=[0 0 0];        
    end
end

baCol=.3+.65*sin(bgCol*(pi/2));
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

%% Creating message box
if length(varargin)>=2
    handles.msg_txt=[];
    handles.log_txt=[];
    handles.results_txt=[];
else
    s={' '; '>>'; ' '; ' ';' ';' '; ' '; ' '; ' '; ' '};
    switch handles.theme
        case 'light'
            bgCol=[.25 .25 .25];
            fgCol=[1 1 1];
        case 'dark'
            fgCol=gridCol;
    end     
    handles.msg_txt=uicontrol('Parent',handles.msg_panel,...
        'Units','normalized',...
        'Position',[0.025,0.05,0.95,0.9],...
        'Style','edit',...
        'Max',2,...
        'Enable','inactive',...
        'BackgroundColor', bgCol, ...
        'ForegroundColor', fgCol, ...
        'FontName', 'Courier New', ...
        'HorizontalAlignment', 'left', ...
        'String',s);
    
    handles.msgType='log';
    handles.msgButtonLog.ForegroundColor=handles.lightBlue;
    
    handles.log_txt={[ '>> Session started on ' datestr(now,'dd-mmm-yyyy, HH:MM')]};
    handles.msg_txt.String=handles.log_txt;
    handles.msgButtonResults.ForegroundColor=gridCol;
    handles.results_txt={};
    handles.results_txt=[handles.results_txt; '>>'];
end

%% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Executes on button press in open.
function open_Callback(hObject, eventdata, handles)
[fname, fpath]=uigetfile({'*.mat', 'MAT-file (*.mat)'; ...
                          '*.xls;*.xlsx','Excel spreadsheet (*.xls, *.xlsx)'; ...
                          '*.dat','Data file (*.dat)'; ...
                          '*.csv','Comma-separated value (*.csv)'; ...
                          '*.mat;*.xls;*.xlsx;*.dat;*.csv','All supported types (*.mat, *.xls, *.xlsx, *.dat)'}, ...
                          'Select the file containing data', ...
                          handles.lastLoadPath);
if ne(fname,0)
    handles.lastLoadPath=[fpath fname];
    handles.fname=[fpath fname];
    ext=fname(strfind(fname,'.')+1:end);
    %% User selected a MAT-file
    if strcmp(ext,'mat')==1
        inData=load(handles.fname);
        err=0;
    %% User selected an Excel file
    elseif (strcmp(ext,'xls')==1)||(strcmp(ext,'xlsx')==1)
        % Getting source type
        % Try to guess source type
        type=autoFindDataSource(handles.fname);
        if isempty(type==1)
            [h, sourceType]=selsrc([],type);
        else
            sourceType=type;
        end
        switch sourceType
            case 'cancelRequest'
                err=2;
            case 'optMetrics'
                inData=impOptMetrics(handles.fname);
                if isempty(inData)==1
                    msgbox('Wrong source type or corrupted data.', ...
                           'Importing data','error')
                    err=1;
                else
                    err=0;
                end
            case 'cboe'
                inData=impCBOE(handles.fname);
                if isempty(inData)==1
                    msgbox('Wrong source type or corrupted data.', ...
                        'Importing data','error')
                    err=1;
                else
                    err=0;
                end
            otherwise
                err=1;
        end
    %% User selected a DAT-file    
    elseif strcmp(ext,'dat')==1
        % Getting source type
        type=autoFindDataSource(handles.fname);
        if isempty(type)==1
            [h, sourceType]=selsrc([],{'CBOE'});
        else
            sourceType=type;
        end
        switch sourceType
            case 'cancelRequest'
                err=2;
            case 'optMetrics'
                inData=impOptMetrics(handles.fname);
                if isempty(inData)==1
                    msgbox('Wrong source type or corrupted data.', ...
                        'Importing data','error')
                    err=1;
                else
                    err=0;
                end
            case 'cboe'
                inData=impCBOE(handles.fname);
                if isempty(inData)==1
                    msgbox('Wrong source type or corrupted data.', ...
                        'Importing data','error')
                    err=1;
                else
                    err=0;
                end
            otherwise
                err=1;
        end
    %% User selected a comma-separeted value
    elseif strcmp(ext,'csv')==1
        % Getting source type
        type=autoFindDataSource(handles.fname);
        if isempty(type)==1
            [h, sourceType]=selsrc([],{'OptionMetrics'});
        else
            sourceType=type;
        end
        switch sourceType
            case 'cancelRequest'
                err=2;
            case 'optMetrics'
                inData=impOptMetrics(handles.fname);
                if isempty(inData)==1
                    msgbox('Wrong source type or corrupted data.', ...
                        'Importing data','error')
                    err=1;
                else
                    err=0;
                end
            case 'cboe'
                inData=impCBOE(handles.fname);
                if isempty(inData)==1
                    msgbox('Wrong source type or corrupted data.', ...
                        'Importing data','error')
                    err=1;
                else
                    err=0;
                end
            otherwise
                err=1;
        end
    else
        err=1;
    end
    
    if err==0
        %% Needed parameters
        if (isfield(inData,'K')==1)
            if (isrow(inData.K)==0)
                K=inData.K;
            else
                err=1;
            end
        else
            err=1;
        end
        if (isfield(inData,'m')==1)
            if (length(inData.m)==2)||(isempty(inData.m)==1)
                m=inData.m;
            else
                err=1;
            end
        else
            err=1;
        end
        if (isfield(inData,'call')==1)
            if (isrow(inData.call)==0)
                call=inData.call;
            else
                err=1;
            end
        else
            err=1;
        end
        if (isfield(inData,'put'))
            if (isrow(inData.put)==0)
                put=inData.put;
            else
                err=1;
            end
        else
            err=1;
        end
        
        %% Undiscounting prices
        if err==0
            if (isfield(inData,'obsDate')==1)&& ...
                    (isfield(inData,'expDate')==1) && ...
                    (datenum(inData.obsDate)<datenum(inData.expDate)) && ...
                    (isfield(inData,'r')==1) && ...
                    (inData.r>0)
                
                T=(datenum(inData.expDate)-datenum(inData.obsDate))/365;
                r=inData.r;
                U=exp(r*T);
            else
                U=1;
            end
            call=U*call;
            put=U*put;
            
            %% Optional data
            
            % Field r
            if (isfield(inData,'r')==1)
                if isscalar(inData.r)==1
                    r=inData.r;
                else
                    err=1;
                end
            else
                r=0;
            end
            
            % Field obsDate
            if (isfield(inData,'obsDate')==1)&&(err==0)
                if (isrow(inData.obsDate)==1)&&(length(inData.obsDate)==6)
                    obsDate=inData.obsDate;
                    set(handles.obsdate, 'String', ['Observation Date:  ' datestr(obsDate)]);
                    handles.inData={K,call,put,m,r,obsDate};
                else
                    err=1;
                end
            elseif (isfield(inData,'obsDate')==0)&(err==0)
                handles.inData={K,call,put,m,r};
            else
                err=1;
            end
            
            % TO BE REMOVED IN FUTURE VERSIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Field scadDate
            if (isfield(inData,'scadDate')==1)&&(err==0)
                    inData.expDate=inData.scadDate;
                    inData=rmfield(inData,'scadDate');
            end
            % TO BE REMOVED IN FUTURE VERSIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Field expDate
            if (isfield(inData,'expDate')==1)&&(err==0)
                if (isrow(inData.expDate)==1)&&(length(inData.expDate)==6)
                    expDate=inData.expDate;
                    set(handles.expdate, 'String', ['Expiry Date:  ' datestr(expDate)]);
                    % Updating temporary structure
                    str=handles.inData;
                    newEl=expDate;
                    tstr=cell(1,length(str)+1);
                    for i=1:length(str)
                        tstr{i}=str{i};
                    end
                    tstr{length(str)+1}=newEl;
                    handles.inData=tstr;
                else
                    err=1;
                end
            end
            
            % Field call_a
            if (isfield(inData,'call_a')==1)&&(err==0)
                if (isrow(inData.call_a)==0)&&(length(inData.call_a)==length(call))
                    call_a=U*inData.call_a;
                    % Updating temporary structure
                    str=handles.inData;
                    newEl=call_a;
                    tstr=cell(1,length(str)+1);
                    for i=1:length(str)
                        tstr{i}=str{i};
                    end
                    tstr{length(str)+1}=newEl;
                    handles.inData=tstr;
                else
                    err=1;
                end
            end
            
            % Field call_b
            if (isfield(inData,'call_b')==1)&&(err==0)
                if (isrow(inData.call_b)==0)&&(length(inData.call_b)==length(call))
                    call_b=U*inData.call_b;
                    % Updating temporary structure
                    str=handles.inData;
                    newEl=call_b;
                    tstr=cell(1,length(str)+1);
                    for i=1:length(str)
                        tstr{i}=str{i};
                    end
                    tstr{length(str)+1}=newEl;
                    handles.inData=tstr;
                else
                    err=1;
                end
            end
            
            % Field put_a
            if (isfield(inData,'put_a')==1)&&(err==0)
                if (isrow(inData.put_a)==0)&&(length(inData.put_a)==length(put))
                    put_a=U*inData.put_a;
                    % Updating temporary structure
                    str=handles.inData;
                    newEl=put_a;
                    tstr=cell(1,length(str)+1);
                    for i=1:length(str)
                        tstr{i}=str{i};
                    end
                    tstr{length(str)+1}=newEl;
                    handles.inData=tstr;
                else
                    err=1;
                end
            end
            
            % Field put_b
            if (isfield(inData,'put_b')==1)&&(err==0)
                if (isrow(inData.put_b)==0)&&(length(inData.put_b)==length(put))
                    put_b=U*inData.put_b;
                    % Updating temporary structure
                    str=handles.inData;
                    newEl=put_b;
                    tstr=cell(1,length(str)+1);
                    for i=1:length(str)
                        tstr{i}=str{i};
                    end
                    tstr{length(str)+1}=newEl;
                    handles.inData=tstr;
                else
                    err=1;
                end
            end
        end
    end
    guidata(hObject,handles);
    
    %% Updating graphics
    if err==0
        % Setting values to default
        handles.glvar=[];
        handles.backData=[];
        % Structure to dostuff.m
        handles.DoStuff.obsCall=[];
        handles.DoStuff.obsPut=[];
        handles.DoStuff.obsIVCall=[];
        handles.DoStuff.obsIVCall_a=[];
        handles.DoStuff.obsIVCall_b=[];
        handles.DoStuff.obsIVPut=[];
        handles.DoStuff.obsIVPut_a=[];
        handles.DoStuff.obsIVPut_b=[];
        handles.DoStuff.appCall=[];
        handles.DoStuff.appPut=[];
        handles.DoStuff.appCall0=[];
        handles.DoStuff.appPut0=[];
        handles.DoStuff.appIVCall=[];
        handles.DoStuff.appIVPut=[];
        handles.DoStuff.appIVCall0=[];
        handles.DoStuff.appIVPut0=[];
        handles.epsilon=[];
        % Setting history to default
        handles.history=[];
        guidata(hObject,handles);
        handles.historyMenu.String={'History is empty'};
        handles.historyMenu.Enable='off';
        handles.historyEl=[];
        mess={};
        % Setting maturity
        if (isfield(inData,'obsDate')==1)&&(isfield(inData,'expDate')==1)
            if datenum(inData.obsDate)<datenum(inData.expDate)
                handles.DoStuff.maturity=(datenum(inData.expDate)-datenum(inData.obsDate))/365;
            else
                mess={'>> Obs. and exp. dates are inconsistent!' 
                      '   Maturity was set to 21/251'};
                handles.DoStuff.maturity=30/365;
            end
        else
            mess={'>> Unable to read obs. or exp. date!'
                  '   Maturity was set to 21/251'};
            handles.DoStuff.maturity=30/365;
        end
        % Setting cutting thresholds list
        handles.cuttingThreshold=0;
        handles.cuttingThresholdPlots=0;
        thresholdsList=sort(union(inData.call,inData.put));
        infList=find(thresholdsList==max([min(inData.call) min(inData.put)]))+1;
        supList=find(thresholdsList==min([max(inData.call) max(inData.put)]))-1;
        thresholdsList=sort(union(0, thresholdsList(infList:supList)));
        handles.cuttingThresholdMenu.String= ...
            cellstr(num2str(thresholdsList,'% 10.2f'));
        % Setting graphics
        handles.plotType='prices';
        handles.plotType_menu.Value=1;
        refreshGUI(hObject, handles);
        set(handles.filename, 'String', fname);
        if length(fname)>20;
            fnameSh=[fname(1:14) '..' fname(end-3:end)];
        else
            fnameSh=fname;
        end
        mess=[mess; ['>> Loaded ' fnameSh]];
    elseif err==1
        handles.inData=[];
        set(handles.filename, 'String', 'Invalid file');
        mess='>> Error in loading input file';
    end
    
    %% Returning exit message
    if isempty(mess)==0
        if isempty(handles.log_txt)
            disp(char(mess));
        else
            handles.log_txt=[handles.log_txt; mess];
            handles.msg_txt.String=handles.log_txt;
        end
    end
    
    guidata(hObject,handles);
end

% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
inData=handles.inData;
if isempty(inData)==0
    %% Structure to dostuff.m
    handles.DoStuff.appCall=[];
    handles.DoStuff.appPut=[];
    handles.DoStuff.appCall0=[];
    handles.DoStuff.appPut0=[];
    handles.DoStuff.appIVCall=[];
    handles.DoStuff.appIVPut=[];
    handles.DoStuff.appIVCall0=[];
    handles.DoStuff.appIVPut0=[];
    %% Algorithm parameters
    kernelDensity=handles.kernelDensity;
    order=handles.order;
    mode=handles.mode;
    cuttingThreshold=handles.cuttingThreshold;
    handles.cuttingThresholdPlots=handles.cuttingThreshold;
    PCAThreshold=handles.threshold;
    %% Running estimation and plotting
    if isempty(inData{4})==0
        handles.msgType='log';
        handles.msgButtonResults.ForegroundColor=handles.msg_panel.ForegroundColor;
        handles.msgButtonLog.ForegroundColor=handles.lightBlue;
        regressionPriority=handles.regressionPriority;
        restrictMean=handles.restrictMean;
        try
            [c,kerpar,estResults,extime, msg_l,msg_r,msgT]= ...
                calibrate(inData, kernelDensity, order, mode, regressionPriority, ...
                restrictMean, cuttingThreshold, PCAThreshold, handles.msg_txt,handles.log_txt, ...
                handles.results_txt,handles.msgType);
            epsilon=estResults.epsilon;
            if ~isempty(handles.log_txt)
                handles.msg_txt.String{end+1}='>> Plotting...';
                handles.msg_txt.Value=length(handles.msg_txt.String);
                drawnow;
            end
            handles.results_txt=msg_r;
            handles.msgType=msgT;
            handles.epsilon=epsilon;
            guidata(hObject,handles);
            [f, kf, ~, appm, glRes, mess, AC, msg_t, msg_r]=dostuff(c, kerpar, handles);
            handles.glvar={c, kernelDensity, kerpar, inData, f, kf};
            handles.DoStuff=AC;
            if ~isempty(handles.log_txt)
                handles.log_txt=[msg_l; '>> Plotting...[Done]'];
                handles.msg_txt=msg_t;
                handles.msg_txt.String{end}=[handles.msg_txt.String{end} '[Done]'];
            end
            handles.results_txt=msg_r;
            set(handles.appmean, 'String', ['Mean:  ' num2str(appm(1),'%.3f')]);
            set(handles.appvar, 'String', ['Variance:  ' num2str(appm(2)-appm(1)^2,'%.3f')]);
            set(handles.est_residual, 'String', ['Estimation:  ' num2str(sqrt(mean(epsilon.^2)),'%.5f')]);
            set(handles.est_residual_c, 'String', ['Estimation:  ' num2str(std(epsilon,1),'%.5f')]);
            set(handles.residual, 'String', ['Global:  ' num2str(sqrt(mean(glRes.^2)),'%.5f')]);
            set(handles.residual_c, 'String', ['Global:  ' num2str(std(glRes,1),'%.5f')]);
            set(handles.ctime, 'String', extime);
            %% History
            last=handles.last;
            if isempty(last)==0
                if length(handles.history)<4
                    handles.history=[handles.history; last];
                else
                    handles.history(1:3)=handles.history(2:end);
                    handles.history(end)=last;
                end
                or=int2str(length(last.c)-1);
                knl=last.kernelDensity;
                newentry=[knl.name ' (method ' ...
                    char(last.method) ', order ' or ')'];
                if length(handles.history)==1
                    fl={'Plot only current density'};
                    ll={'Plot all densities saved in the history'};
                    handles.historyMenu.String=[fl; newentry; ll];
                else
                    handles.historyMenu.String=[handles.historyMenu.String(1); ...
                        newentry; handles.historyMenu.String(2:end)];
                end
                if length(handles.historyMenu.String)>6
                    handles.historyMenu.String=[handles.historyMenu.String(1:5); ...
                        handles.historyMenu.String(end)];
                end
                clear last newentry knl;
                handles.historyMenu.Enable='on';
                guidata(hObject,handles);
            end
            last=struct;
            last.c=c;
            last.kernelDensity=kernelDensity;
            last.kerpar=kerpar;
            last.method=handles.method.String(handles.method.Value);
            last.K0=min(inData{1});
            last.Km=max(inData{1});
            handles.last=last;
            guidata(hObject,handles);
            clear last;
        catch ME
            mess='>> Failure. ';
            switch ME.identifier
                case 'MATLAB:eig:matrixWithNaNInf'
                    mess=[mess, 'Try a lower order in PCA.'];
                case 'optimlib:snls:UsrObjUndefAtX0'
                    mess=[mess, 'Optimizer returned undefined values.'];
                otherwise
                    mess=[mess, 'Unknown cause.'];
            end
            handles.msg_txt.Style='edit';
        end        
    else
        mess=[];
        msgbox('Incomplete input.')
    end
    if isempty(mess)==0
        if isempty(handles.log_txt)
            if iscell(mess)
                for cnt=1:length(mess)
                    fprintf(mess{cnt});
                    fprintf('\n')
                end
            else
                fprintf(mess);
                fprintf('\n');
            end
        else
            handles.log_txt=[handles.log_txt; mess];
        end
    end
    if ~isempty(handles.log_txt)
        handles.msg_txt.Style='edit';
        handles.msg_txt.String=handles.log_txt;
        handles.msg_txt.Value=1;
    end
    guidata(hObject,handles);
else
    msgbox('No input file was loaded.')
end

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
varargout{2} = handles.fname;


% --- Executes on slider movement.
function ord_Callback(hObject, eventdata, handles)
order=floor(get(hObject,'Value'));
handles.order=order;
set(handles.orderdisp, 'String', int2str(order));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function ord_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in kernelMenu.
function kernelMenu_Callback(hObject, eventdata, handles)
kn=get(hObject,'Value');
handles.kernel=handles.kernelLabels{kn};
load(['kernels\' handles.kernel '.mat']);
handles.kernelDensity=kernelDensity;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function kernelMenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in exportPlot.
function exportPlot_Callback(hObject, eventdata, handles)
glvar=handles.glvar;
if isempty(glvar)==0
    i1=strfind(handles.fname,'\');
    if isempty(i1)==0
        fname.String=[handles.fname(i1(end)+1:strfind(handles.fname,'.')-1) '_' ...
            handles.kernel '_' int2str(handles.order)];
    else
        fname.String=[handles.fname(1:strfind(handles.fname,'.')-1) '_' ...
            handles.kernel '_' int2str(handles.order)];
    end
    [plPath,plNam,format,ratio]=figureExport(fname,handles.lastLoadPath);
%     [plNam,plPath] = uiputfile({'*.fig', 'MATLAB figure'; ...
%                                 '*.png', 'Portable Network Graphics'; ...
%                                 '*.pdf', 'Portable Document Format'}, ...
%                                 'Export plots', ...
%                                 [handles.fname(1:strfind(handles.fname,'.')-1) ...
%                                 '_' handles.kernel '_' int2str(handles.order)]);
    
    if isempty(plPath)==0
        plPath=[plPath '\'];
        c=glvar{1};
        kerpar=glvar{3};
        if ~isempty(handles.log_txt)
            handles.log_txt=[handles.log_txt; '>> Exporting current plots...'];
            if strcmp(handles.msgType,'log')==1
                handles.msg_txt.String=handles.log_txt;
            end
            drawnow;
        else
            fprintf('>> Exporting current plots...\n');
        end
        [hd,hc,hp]=extplot(c,kerpar,handles);
        if strcmp(format,'fig')==0
            for i=2:length(hd.Children)
                hd.Children(i).Position=[0.08 0.08 .87 .87];
            end
            for i=2:length(hc.Children)
                hc.Children(i).Position=[0.08 0.08 .87 .87];
            end
            for i=2:length(hp.Children)
                hp.Children(i).Position=[0.08 0.08 .87 .87];
            end
        end
        plotType=handles.plotType;
        switch format
            case 'fig'
                savefig(hd,[plPath plNam '_density.fig']);
                savefig(hc,[plPath plNam '_' plotType '_call.fig']);
                savefig(hp,[plPath plNam '_' plotType '_put.fig']);
            case 'png'
                cf2png(ratio,[plPath plNam '_density.png'],hd);
                cf2png(ratio,[plPath plNam '_' plotType  '_call.png'],hc);
                cf2png(ratio,[plPath plNam '_' plotType '_put.png'],hp);
            case 'pdf'
                cf2pdf(ratio,[plPath plNam '_density.pdf'],hd);
                cf2pdf(ratio,[plPath plNam '_' plotType '_call.pdf'],hc);
                cf2pdf(ratio,[plPath plNam '_' plotType '_put.pdf'],hp);
            case 'eps'
                cf2eps(ratio,[plPath plNam '_density.eps'],hd);
                cf2eps(ratio,[plPath plNam '_' plotType '_call.eps'],hc);
                cf2eps(ratio,[plPath plNam '_' plotType '_put.eps'],hp);
        end
        close(hd);
        close(hc);
        close(hp);
        if length(plNam)>30
            plNam=[plNam(1:15) '...' plNam(end-12:end)];
        end
        currMsg={'   Exported files:'; ... 
            ['   ' plNam '_density.' format]; ...
            ['   ' plNam '_call.' format];
            ['   ' plNam '_put.' format]};
        if ~isempty(handles.log_txt)
            handles.log_txt=[handles.log_txt; currMsg];
            if strcmp(handles.msgType,'log')==1
                handles.msg_txt.String=handles.log_txt;
            end
            drawnow;
        else
            disp(currMsg);
            fprintf('\n');
        end
        guidata(hObject,handles)
    end
else
    msgbox('You must run the main function at least once before exporting plots.')
end

% --- Executes on button press in exportData.
function exportData_Callback(hObject, eventdata, handles)
glvar=handles.glvar;
if isempty(glvar)==0
    [nam,pth] = uiputfile('*.mat','Save output', ...
    [handles.fname(1:strfind(handles.fname,'.')-1) '_' handles.kernel '_' int2str(handles.order)]);
    if ne(nam,0)==1
        if ~isempty(handles.log_txt)
            handles.log_txt=[handles.log_txt;'>> Exporting current results...'];
            if strcmp(handles.msgType,'log')==1
                handles.msg_txt.String=handles.log_txt;
            end
            drawnow;
        else
            fprintf('>> Exporting current results...\n');
        end
        inData=glvar{4};
        K=inData{1};
        obsCall=inData{2};
        obsPut=inData{3};
        c=glvar{1};
        kerPar=glvar{3};
        f=glvar{5};
        kf=glvar{6};
        order=handles.order;
        kernel=handles.kernel;
        save([pth nam],'c','kerPar','f','kf','order','kernel', 'K', 'obsCall', 'obsPut');
        if ~isempty(handles.log_txt)
            handles.log_txt=[handles.log_txt; '   Exported file:'; ['   ' nam]];
        else
            disp({'>> Exported file:'; ['   ' nam]});
            fprintf('\n');
        end
        
        if strcmp(handles.msgType,'log')==1
            handles.msg_txt.String=handles.log_txt;
            drawnow;
        end
        guidata(hObject,handles)
    end
else
    msgbox('There is no data to be saved!');
end

% --- Executes on button press in clean.
function clean_Callback(hObject, eventdata, handles)
inData=handles.inData;
if (isempty(inData)==0)&&(handles.cleanRunning==0)
    handles.cleanRunning=1;
    guidata(hObject,handles);
    [h,inData]=clean(handles.inData,handles.theme,handles.DoStuff.maturity);
    if isempty(inData)==0
        % Setting values to default
        handles.cleanRunning=0;
        handles.glvar=[];
        handles.backData=[];
        handles.DoStuff.obsCall=[];
        handles.DoStuff.obsPut=[];
        handles.DoStuff.obsIVCall=[];
        handles.DoStuff.obsIVCall_a=[];
        handles.DoStuff.obsIVCall_b=[];
        handles.DoStuff.obsIVPut=[];
        handles.DoStuff.obsIVPut_a=[];
        handles.DoStuff.obsIVPut_b=[];
        handles.DoStuff.appCall=[];
        handles.DoStuff.appPut=[];
        handles.DoStuff.appCall0=[];
        handles.DoStuff.appPut0=[];
        handles.DoStuff.appIVCall=[];
        handles.DoStuff.appIVPut=[];
        handles.DoStuff.appIVCall0=[];
        handles.DoStuff.appIVPut0=[];
        handles.epsilon=[];
        handles.inData=inData;
        handles.plotType='prices';
        handles.plotType_menu.Value=1;
        % Setting cutting thresholds list
        handles.cuttingThreshold=0;
        handles.cuttingThresholdPlots=0;
        thresholdsList=sort(union(inData{2},inData{3}));
        infList=find(thresholdsList==max([min(inData{2}) min(inData{3})]))+1;
        supList=find(thresholdsList==min([max(inData{2}) max(inData{3})]))-1;
        thresholdsList=sort(union(0, thresholdsList(infList:supList)));
        handles.cuttingThresholdMenu.String= ...
            cellstr(num2str(thresholdsList,'% 10.2f'));
        handles.cuttingThresholdMenu.Value=1;
        % Refreshing GUI
        refreshGUI(hObject, handles);
        guidata(hObject,handles);
    else
        handles.cleanRunning=0;
        guidata(hObject,handles);
    end
elseif isempty(inData)==1
    msgbox('No input has been loaded yet.')
else
    msgbox('Cleaning data tool is already running.')
end

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=gcf;
hsize=h.Position(3);
guidata(hObject,handles);

function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
    
% --- Executes on selection change in plotScale_menu.
function plotScale_menu_Callback(hObject, eventdata, handles)
% hObject    handle to plotScale_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.historyMenu.Value=1;
kn=get(hObject,'Value');
switch kn;
    case 1
        handles.plotScale='plain';
    case 2
        handles.plotScale='square';
    case 3
        handles.plotScale='semilog';
end

guidata(hObject,handles);
glvar=handles.glvar;
if isempty(glvar)==0
    c=glvar{1};
    kerpar=glvar{3};
    dostuff(c, kerpar, handles);
end

% --- Executes during object creation, after setting all properties.
function plotScale_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotScale_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in method.
function method_Callback(hObject, eventdata, handles)
% hObject    handle to method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
mtd=get(hObject,'Value');
switch str{mtd};
    case 'Iterative'
        handles.mode='normal';
        u=handles.uipanel19;
        u.Visible='off';
        u=handles.uipanel1;
        u.Position=[0.015 0.15 0.292 0.063];
        handles.lockmean.Visible='off';
    case 'PCA'
        handles.mode='pca';
        u=handles.uipanel19;
        u.Visible='on';
        u=handles.priorityPanel;
        u.Visible='on';
        u=handles.uipanel1;
        u.Position=[0.015 0.15 0.168 0.063];
        handles.lockmean.Visible='on';
    case 'OLS'
        handles.mode='ols';
        u=handles.priorityPanel;
        u.Visible='off';
        u=handles.uipanel19;
        u.Visible='off';
        u=handles.uipanel1;
        u.Position=[0.015 0.15 0.292 0.063];
        handles.lockmean.Visible='off';
        %u.Position=[0.015 0.15 0.230 0.063];
    otherwise
        msgbox('Unrecognized estimation method','Error','error');
end

guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from method


% --- Executes during object creation, after setting all properties.
function method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hwin;

function thr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to thr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thr_edit as text
%        str2double(get(hObject,'String')) returns contents of thr_edit as a double


% --- Executes during object creation, after setting all properties.
function thr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in thr_menu.
function thr_menu_Callback(hObject, eventdata, handles)
% hObject    handle to thr_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str=get(hObject,'String');
choice=get(hObject,'Value');
str=str{choice};
str=str(1:end-1);
handles.threshold=str2num(str)/100;
%fprintf('Threshold changed to %d%%\n',handles.threshold*100);
guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns thr_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from thr_menu


% --- Executes during object creation, after setting all properties.
function thr_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thr_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plotType_menu.
function plotType_menu_Callback(hObject, eventdata, handles)
% hObject    handle to plotType_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotType_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotType_menu

AC=[];
kn=get(hObject,'Value');
switch kn;
    case 1
        handles.plotType='prices';
        if isempty(handles.DoStuff.appCall)==0
            glvar=handles.glvar;
            c=glvar{1};
            kerpar=glvar{3};
            if strcmp(handles.msgType,'log')==1
                if ~isempty(handles.log_txt)
                    handles.log_txt=[handles.log_txt;'>> Plotting prices...'];
                    handles.msg_txt.String=handles.log_txt;
                    drawnow;
                else
                    fprintf('>> Plotting prices...\n');
                end
                guidata(hObject,handles);    
                
            end
            [~, ~, ~, ~, ~, ~, AC, ~, ~]=dostuff(c, kerpar, handles);
        else
            guidata(hObject,handles);
            refreshGUI(hObject, handles);
        end
    case 2
        handles.plotType='ivols';
        if isempty(handles.DoStuff.appCall)==0
            glvar=handles.glvar;
            c=glvar{1};
            kerpar=glvar{3};
            if strcmp(handles.msgType,'log')==1
                if ~isempty(handles.log_txt)
                    handles.log_txt=[handles.log_txt;'>> Plotting implied volatilities...'];
                    handles.msg_txt.String=handles.log_txt;
                    drawnow;
                else
                    fprintf('>> Plotting implied volatilities...\n')
                end
                guidata(hObject,handles);
            end
            [~, ~, ~, ~, ~, ~, AC, ~, ~]=dostuff(c, kerpar, handles);
        else
            guidata(hObject,handles);
            refreshGUI(hObject, handles);
        end
    case 3
        handles.plotType='residuals';
        if isempty(handles.DoStuff.appCall)==0
            glvar=handles.glvar;
            c=glvar{1};
            kerpar=glvar{3};
            if strcmp(handles.msgType,'log')==1
                if ~isempty(handles.log_txt)
                    handles.log_txt=[handles.log_txt;'>> Plotting residuals...'];
                    handles.msg_txt.String=handles.log_txt;
                    drawnow;
                else
                    fprintf('>> Plotting residuals...\n');
                end
                guidata(hObject,handles);
            end
            [~, ~, ~, ~, ~, ~, AC, ~, ~]=dostuff(c, kerpar, handles);
            %dostuff(c, kernelMenu, kerpar, inData, handles.plotScale, 'ivols', handles.theme, handles);
        end
end
if isempty(AC)==0
    handles.DoStuff=AC;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function plotType_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotType_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function msg_text_Callback(hObject, eventdata, handles)
% hObject    handle to msg_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of msg_text as text
%        str2double(get(hObject,'String')) returns contents of msg_text as a double


% --- Executes during object creation, after setting all properties.
function msg_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msg_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in historyMenu.
function historyMenu_Callback(hObject, eventdata, handles)
% hObject    handle to historyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=hObject.Value;
switch choice
    case 1
        handles.historyEl=[];
    case length(hObject.String);
        handles.historyEl=1:length(hObject.String)-2;
    otherwise
        handles.historyEl=length(hObject.String)-choice;
end

guidata(hObject,handles);

glvar=handles.glvar;
c=glvar{1};
kerpar=glvar{3};
[~, ~, ~, ~, ~, mess, ~, msg_txt,results_txt]=dostuff(c, kerpar, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns historyMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from historyMenu


% --- Executes during object creation, after setting all properties.
function historyMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to historyMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text35.
function text35_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rl=handles.uipanel25rl;
if handles.showHistory==0
    handles.uipanel25.HighlightColor=[1 1 1]-handles.uipanel25.HighlightColor;
    pause(0.1);
    handles.uipanel25.HighlightColor=[1 1 1]-handles.uipanel25.HighlightColor; 
    hObject.String='<<';
    handles.uipanel25.Position=[.076 0.216 0.03 0.03];
    x=0.11;
    w=rl-x;
    handles.historyMenu.Position=[x 0.215 w 0.03];
    handles.historyMenu.Visible='on';
    handles.showHistory=1;
else
    handles.uipanel25.HighlightColor=[1 1 1]-handles.uipanel25.HighlightColor;
    pause(0.1);
    handles.uipanel25.HighlightColor=[1 1 1]-handles.uipanel25.HighlightColor; 
    hObject.String='< History';
    %hObject.FontSize=10;
    w=0.06;
    x=rl-w;
    handles.uipanel25.Position=[x 0.215 w 0.03];
    guidata(hObject,handles);
    handles.historyMenu.Position=[0.072 0.215 0.001 0.03];
    handles.historyMenu.Visible='off';
    handles.showHistory=0;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function text35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over msgButtonLog.
function msgButtonLog_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to msgButtonLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.msgType,'log')==0
    handles.msgType='log';
    handles.msgButtonResults.ForegroundColor=handles.msgButtonLog.ForegroundColor;
    handles.msgButtonLog.ForegroundColor=handles.lightBlue;
    handles.msg_txt.String=handles.log_txt;
    drawnow;
    guidata(hObject,handles);
end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over msgButtonResults.
function msgButtonResults_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to msgButtonResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.msgType,'results')==0
    handles.msgType='results';
    handles.msgButtonLog.ForegroundColor=handles.msgButtonResults.ForegroundColor;
    handles.msgButtonResults.ForegroundColor=handles.lightBlue;
    handles.msg_txt.String=handles.results_txt;
    drawnow;
    guidata(hObject,handles);
end


% --- Executes on button press in msgButtonClear.
function msgButtonClear_Callback(hObject, eventdata, handles)
% hObject    handle to msgButtonClear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.msg_txt)==0
    handles.results_txt={'>>'};
    handles.log_txt=handles.log_txt(1);
    if strcmp(handles.msgType,'results')==1
        handles.msg_txt.String=handles.results_txt;
    else
        handles.msg_txt.String=handles.log_txt;
    end
    guidata(hObject,handles);
end


% --- Executes on selection change in cuttingThresholdMenu.
function cuttingThresholdMenu_Callback(hObject, eventdata, handles)
% hObject    handle to cuttingThresholdMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cuttingThresholdMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cuttingThresholdMenu
handles.cuttingThreshold= ...
    str2double(handles.cuttingThresholdMenu.String{handles.cuttingThresholdMenu.Value});

% Updating PCP and BA residuals
cT=handles.cuttingThreshold;
inData=handles.inData;
K=inData{1};
call=inData{2};
put=inData{3};
m=inData{4};
indCall=(call>cT)&(put>0);
indPut=(put>cT)&(call>0);
filteringInd=indCall&indPut;

if isempty(m)==0
    set(handles.mean, 'String', ['Mean:  ' num2str(m(1),'%.3f')]);
    set(handles.var, 'String', ['Variance:  ' num2str(m(2)-m(1)^2,'%.3f')]);
    pcpR=sum((call(filteringInd)-put(filteringInd)+K(filteringInd)-m(1)).^2);
else
    set(handles.mean, 'String', 'Mean:  N/A');
    set(handles.var, 'String', 'Variance:  N/A');
    pcpR=var(call(filteringInd)-put(filteringInd)+K(filteringInd),1)*length(K(filteringInd));
end

handles.pcpRes.String=['P-C parity RMSE:  ' num2str(sqrt(pcpR/(length(K(filteringInd)))))];

if length(inData)==11
    call_a=inData{8};
    call_b=inData{9};
    put_a=inData{10};
    put_b=inData{11};
    baRes=sum((call_a(filteringInd)-call_b(filteringInd)).^2) ...
        +sum((put_a(filteringInd)-put_b(filteringInd)).^2);
    handles.avBAspread.String=['Bid-Ask res:  ' num2str(sqrt(baRes/(2*length(K(filteringInd)))))];
end

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function cuttingThresholdMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cuttingThresholdMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in priorityMenu.
function priorityMenu_Callback(hObject, eventdata, handles)
% hObject    handle to priorityMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch hObject.Value
    case 1
        handles.regressionPriority='fitting';
    case 2
        handles.regressionPriority='robustness';
end
%handles.regressionPriority=lower(hObject.String{hObject.Value});
guidata(hObject,handles);

% Hints: contents = cellstr(get(hObject,'String')) returns priorityMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from priorityMenu


% --- Executes during object creation, after setting all properties.
function priorityMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to priorityMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in lockmean.
function lockmean_Callback(hObject, eventdata, handles)
% hObject    handle to lockmean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.restrictMean
    handles.restrictMean=false;
else
    handles.restrictMean=true;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of lockmean


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over lockmean.
function lockmean_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to lockmean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in findGreeks.
function findGreeks_Callback(hObject, eventdata, handles)
% hObject    handle to findGreeks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.glvar)==0
    if ~isempty(handles.log_txt)
        handles.log_txt=[handles.log_txt; '>> Plotting greeks...'];
        if strcmp(handles.msgType,'log')==1
            handles.msg_txt.String=handles.log_txt;
        end
        drawnow;
        greeksgui(handles);
    else
        fprintf('>> Plotting greeks...\n');
    end
else
    msgbox('You must estimate the RND before computing the greeks.')
end
