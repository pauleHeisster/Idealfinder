% Skript zur Erstellung der Trajektorienübersicht aus getSpeed-Plot,
% Kamm-Plot, overview-Plot und Optimm-Plot
close all;
clear all;

interp = 'latex';
if ispc
    settings.sep = '\';
elseif isunix
    settings.sep = '/';
end

m = 5;
a = [5,3];
n = sum(a);

wheeler = initWheeler;
wheeler.use_kf = true;
inputs = inputdlg({'Startgeschwindigkeit [m/s] eingeben:','l_faktor:','q_faktor:','use_kf:'},'Test',1,{'10','1','1','0'});
wheeler.v = str2double(inputs{1});
wheeler.a.l_faktor = str2double(inputs{2});
wheeler.a.q_faktor = str2double(inputs{3});
wheeler.use_kf = str2double(inputs{4});

%% Vorbereitungen
try 
folder = uigetdir();
mainfig = openfig([folder settings.sep '1_Idealfinder_(Hauptfenster).fig']);
optimfig = openfig([folder settings.sep '2_Optimization_PlotFcns.fig']);

child = 7;
xval = mainfig.Children(end).Children(end-child).XData';
yval = mainfig.Children(end).Children(end-child).YData';
zval = mainfig.Children(end).Children(end-child).ZData';

Ideal.XYZ = [xval,yval,zval];
Ideal = prepareCourse(Ideal);
x = cumsum(Ideal.L); 
[videal,time,a_l] = getSpeed(Ideal,wheeler,'dmode=true');

speedfig = findobj('Type','figure','Name','getSpeed');
kammfig = findobj('Type','figure','Name','Kamm');

ov = figure;
ax = {};
ax{end+1} = subplot(m,n,[1,n+a(1)]);
ax{end+1} = subplot(m,n,[2*n+1,2*n+a(1)]);
ax{end+1} = subplot(m,n,[3*n+1,3*n+a(1)]);
ax{end+1} = subplot(m,n,[4*n+1,4*n+a(1)]);

ax{end+1} = subplot(m,n,[a(1)+1,a(1)+a(2)]);
ax{end+1} = subplot(m,n,[n+a(1)+1,n+a(1)+a(2)]);
ax{end+1} = subplot(m,n,[2*n+a(1)+1,2*n+a(1)+a(2)]);
ax{end+1} = subplot(m,n,[3*n+a(1)+1,4*n+a(1)+a(2)]);

%% Speed-Diagramm
speedax = speedfig.Children(end);
vgrenz = [speedax.Children(end).XData',speedax.Children(end).YData'];
vaccl = [speedax.Children(end-1).XData',speedax.Children(end-1).YData'];
vbrake = [speedax.Children(end-2).XData',speedax.Children(end-2).YData'];

AX = ax{1};
line(vgrenz(:,1),vgrenz(:,2),'Parent',AX,'color','b');
line(vaccl(:,1),vaccl(:,2),'Parent',AX,'color','g','LineStyle','--');
line(vbrake(:,1),vbrake(:,2),'Parent',AX,'color','r','LineStyle','--');
line(x,videal,'Parent',AX);
ylim(AX,[0 wheeler.vmax]);

for p = 2 : length(vgrenz)
    if abs(a_l(p)) < 0.0125
        col = 'y';
    else
        switch sign(a_l(p))
            case 1
                col = 'g';
            case -1
                col = 'r';
            otherwise
                col = 'y';
        end
    end
    line(x(p),videal(p),'Parent',AX,'color',col,'Marker','.');
end
ylabel(AX,'v [m/s]');
legend_entries = AX.Children(end:end-2);
legend_text = {'$v_{grenz}$','$v_{accl}$','$v_{brake}$'};
leg1 = legend(AX,legend_entries,legend_text,'Location','northwest','Orientation','horizontal','interpreter',interp);
str = {['Weg: ' num2str(sum(Ideal.L)) ' m'],...
       ['Zeit: ' num2str(sum(time)) ' s'],...
       ['\intv: ' num2str(sum(videal)) ' m/s']};
axdim = AX.Position;
dim = [0.75 0.65 0.3 0.3];
ddim = [dim(1)*axdim(3)+axdim(1),...
        dim(2)*axdim(4)+axdim(2),...
        dim(3)*axdim(3),...
        dim(4)*axdim(4)];
anbox = annotation('textbox',ddim,'String',str,'FitBoxToText','on','BackGroundColor','w');


%% Krümmung
AX = ax{2};
line(x,Ideal.K,'Parent',AX);
ylabel(AX,'K [1/m]');

%% Beschleunigungen
laengs = speedfig.Children(end-3);
quer = speedfig.Children(end-4);
AX = ax{3};
line(x,laengs.Children.YData,'Parent',AX,'color','r');
ylabel(AX,'a_l [m/s^2]');
AX = ax{4};
line(x,quer.Children.YData,'Parent',AX,'color','k');
ylabel(AX,'a_q [m/s^2]');
xlabel(AX,'Weg [m]');
%AX.YDir = 'reverse';

%% Kamm
kreis = kammfig.Children.Children(end);
a_lq = kammfig.Children.Children(end-1);
AX = ax{end};
line(kreis.XData,kreis.YData,'Parent',AX);
line(a_lq.XData,a_lq.YData,'Parent',AX,'Marker','x');
AX.DataAspectRatio = [1,1,1];
xlabel(AX,'a_l [m/s^2]');
ylabel(AX,'a_q [m/s^2]');

%% X-Val
xvalax = optimfig.Children(end-2);
xval = xvalax.Children(end).XData';
yval = xvalax.Children(end).YData';
AX = ax{7};
line([1,length(xval)],[1,1],'Parent',AX,'color','k');
line([1,length(xval)],[-1,-1],'Parent',AX,'color','k');
line([1,length(xval)],[0,0],'Parent',AX,'LineStyle','--','color','g');
line(xval,yval,'Parent',AX,'color',[0,0,0],'Marker','+');
AX.YDir = 'reverse';
AX.YLim = [-1.2,1.2];
AX.XLim = [1,inf];
ylabel(AX,'Ideallinie')

%% F-Count
fcountax = optimfig.Children(end);
fcx = fcountax.Children.XData';
fcy = fcountax.Children.YData';
AX = ax{5};
line(fcx,fcy,'Parent',AX,'Marker','d','MarkerFaceColor','r','color','k');
legend(AX,AX.Children(end),{['Aufrufe: ' num2str(sum(fcy)) ' (\o' num2str(round(mean(fcy))) ')']},'Location','northwest','interpreter',interp);
ylabel(AX,'Zf-Aufrufe');
%line(AX.XLim,[1,1]*fcy(1),'Parent',AX,'LineStyle','--');
%AX.YLim = [min(fcy),fcy(2)];

%% F-Value
fvalax = optimfig.Children(end-1);
fvx = fvalax.Children.XData';
fvy = fvalax.Children.YData';
AX = ax{6};
line(fvx,fvy,'Parent',AX,'Marker','d','MarkerFaceColor','r','color','k');
legend(AX,AX.Children(end),{['Funktionswert: ' num2str(fvy(end)) '@' num2str(fvx(end))]},'Location','southwest','interpreter',interp);
ylabel(AX,'Zf-Wert');

%% Darstellung
s = [1,2,3,4];
for i = 1:length(s)
    ax{s(i)}.XLim = [0,inf];
    if isequal(s(i),3) || isequal(s(i),4)
        ax{s(i)}.YLim = [-10,10];
    end
end

s = [1,2,3,5];
for i = 1:length(s)
    ax{s(i)}.XTickLabel = [];
end
s = [5,6,7,8];
for i = 1:length(s)
    ax{s(i)}.YAxisLocation = 'right';
end
end

s = [1,2,3,4,5,6,7,8];
for i = 1:length(s)
    grid(ax{s(i)},'on');
    box(ax{s(i)},'on');
end

ov.PaperOrientation = 'landscape';
ov.PaperPosition = [-2 -1 32.7 23];
%ov.PaperPositionMode = 'auto'; % behält Ansicht bei
print(ov,'-depsc2', '-painters', [folder '.eps']);