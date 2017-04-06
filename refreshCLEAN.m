    function status=refreshCLEAN(varargin)

%% Checking input
if nargin>=8
    mainFig=varargin{1};
    K=varargin{2};
    call=varargin{3};
    put=varargin{4};
    table=varargin{5};
    m=varargin{6}; 
    baspr=varargin{7};
    theme=varargin{8};
    minHasChanged=0;
    maxHasChanged=0;
end

if nargin>=10
    minHasChanged=varargin{9};
    maxHasChanged=varargin{10};
end
status=0;

%% Setting theme
switch theme
    case 'light'
        bgCol=[1 1 1];
    case 'dark'
        bgCol=[0 0 0];
end

gridCol=[1 1 1]-bgCol;
lgdCol=gridCol;

blue=[0 0.4470 0.7410];       % Blue
red=[0.8500 0.3250 0.0980];   % Red

%% Checking prices inconsistencies
[vc, vp]=checkPrices(K,call,put);

%% Plotting call prices

h=subplot_tight(4,2,1,[.06 .06]);
plot(K,call, 'Color', blue,'LineWidth',1.5);

% Setting plots properties
h=gca;
h.Color=bgCol;
h.XColor=gridCol;
h.YColor=gridCol;
title('Price curves','Color', gridCol);
xlabel('Strike', 'Color', gridCol);
ylabel('Call price', 'Color', gridCol);
grid on;

hold on;

% Showing possible inconsistencies
if isempty(vc)==0
    h=plot(K(vc),call(vc),'Color',red,'Linestyle','none','Marker','.','LineWidth',1.5);
    hl=legend(h,'Monotony/Concavity inconsistencies');
    hl.TextColor=lgdCol;
    hl.Location='best';
    hl.Orientation='horizontal';
end

% Showing possible newly added points
if minHasChanged==1
    plot(K(2),call(2),'Marker','x','Color',red,'LineWidth',1.5);
    plot(K(1:2),call(1:2),'Color',red);
end
if maxHasChanged==1
    plot(K(end-1),call(end-1),'Marker','x','Color',red,'LineWidth',1.5);
    plot(K(end-1:end),call(end-1:end),'Color',red,'LineWidth',1.5);
end
hold off;

%% Plotting put prices

h=subplot_tight(4,2,3, [.06 .06]);
plot(K,put, 'Color', blue,'LineWidth',1.5);

% Setting plot properties
h=gca;
h.Color=bgCol;
h.XColor=gridCol;
h.YColor=gridCol;
xlabel('Strike', 'Color', gridCol);
ylabel('Put price', 'Color', gridCol);
grid on;

hold on;

% Showing possible inconsistencies
if isempty(vc)==0
    h=plot(K(vc),put(vc),'Color',red,'Linestyle','none','Marker','.','MarkerSize',10);
    hl=legend(h,'Monotony/Concavity inconsistencies');
    hl.TextColor=lgdCol;
    hl.Location='best';
    hl.Orientation='horizontal';
end

% Showing possible newly added points
if minHasChanged==1
    plot(K(2),put(2),'Marker','x','Color',red,'LineWidth',1.5);
    plot(K(1:2),put(1:2),'Color',red,'LineWidth',1.5);
end
if maxHasChanged==1
    plot(K(end-1),put(end-1),'Marker','x','Color',red,'LineWidth',1.5);
    plot(K(end-1:end),put(end-1:end),'Color',red,'LineWidth',1.5);
end
hold off;

%% Plotting put-call parity violations

h=subplot_tight(4,2,[2 4],[.05 .08]);
plot(K,call-put+K,'LineStyle','--', 'Marker', '*', 'Color', blue,'LineWidth',1.5);
hold on;
plot(K,(m(1)-baspr)*ones(length(K)), 'Color', blue,'LineWidth',1.5);
plot(K,(m(1)+baspr)*ones(length(K)), 'Color', blue,'LineWidth',1.5);

%% Showing possible newly added points
if minHasChanged==1
    plot(K(1:2),call(1:2)-put(1:2)+K(1:2),'Color',red,'Marker','*','LineWidth',1.5);
end
if maxHasChanged==1
    plot(K(end-1:end),call(end-1:end)-put(end-1:end)+K(end-1:end),'Color',red,'Marker','*','LineWidth',1.5);
end
hold off;
grid on;

%% Setting plot properties
h=gca;
h.Color=bgCol;
h.XColor=gridCol;
h.YColor=gridCol;
h.YAxisLocation='right';
title('Put-Call parity','Color', gridCol);
xlabel('Strike', 'Color', gridCol);
ylabel('Induced Forward Price', 'Color', gridCol);

%% Changing table values
currMsg{1}='______________________________';
currMsg{2}=' ';
currMsg{3}='  Strike     Call       Put   ';
currMsg{4}='______________________________';
currMsg{5}=' ';
chT=num2str([K call put],'% 10.2f');
for i=1:length(K)
    currMsg{i+5}=chT(i,:);
end
currMsg{length(K)+6}=' ';
table.String=currMsg;
drawnow;

status=1;

