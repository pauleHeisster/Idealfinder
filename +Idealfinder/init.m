function [wheeler, veh, handles] = init
sPackage = what('Idealfinder');

import Idealfinder.Lib.*
import Idealfinder.Dev.*

b = .45;
h = .6;

handles.hMainDialog = figure('Name', 'Idealfinder (Hauptfenster)' ...
                   , 'NumberTitle', 'off' ...
                   , 'Units', 'normal' ...
                   , 'Position', [(1-b)/2, (1-h)/2, b, h] ...
                   , 'Tag', 'MainDialog' ...
                   );

handles.hMainAxes = axes('Parent', handles.hMainDialog ...
                  , 'Units', 'normal' ...
                  , 'Position', [0, 0, 1, 1] ...
                  , 'Box', 'on' ...
                  , 'XTick', [] ...
                  , 'YTick', [] ...
                  ..., 'ButtonDownFcn', @placeVehicle ...
                  , 'Tag', 'Hauptachse' ...
                  );
axis(handles.hMainAxes, 'equal');
% sorgt fuer sichtbare Hoehenunterschiede
handles.hMainAxes.DataAspectRatio = [1, 1, 0.01];
%grid(handles.hMainAxes,'on');

hcmenu = uicontextmenu;
uiDel = uimenu(hcmenu, 'Label', 'Obj&ekte löschen');
    uimenu(uiDel, 'Label', '&1 alle Objekte', ...
        'Callback', 'handles.hMainAxes.UserData = {}; delete(handles.hMainAxes.Children(1:end-3));');
    uimenu(uiDel, 'Label', '&2 aktuelles Objekt', ...
        'Callback', 'delGCO;');
    uimenu(uiDel, 'Label', '&3 Kruemmung', ...
        'Callback', @(~,~) delete(findobj(handles.hMainAxes, 'Type', 'rectangle')), 'Separator', 'on');
    uimenu(uiDel, 'Label', '&4 Vektoren', ...
        'Callback', @(~,~) delete(findobj(handles.hMainAxes, 'Tag', 'arrow')));
    uimenu(uiDel, 'Label', '&5 D-Mode', ...
        'Callback', @(~,~) delete(findobj(handles.hMainAxes, 'Tag', 'dmode')));
    uimenu(uiDel, 'Label', '&6 Optimierung', ...
        'Callback', @(~,~) delete(findobj(handles.hMainAxes, 'Tag', 'optim_item')));
    uimenu(hcmenu,'Label', 'D-Mode', ...
        'Callback', 'toogle_dmode', 'Checked', 'off');
    settings.dmode = 'dmode = false';
if false
    %wheeler_ui = ...
    uimenu(hcmenu, 'Label', '&Fahrzeugparameter', 'Callback', 'wheelerGUI');
    %uimenu(wheeler_ui, 'Label', '&Motorkennfeld', 'Tag', 'wheeler_kf', 'Checked', 'off', 'Callback', 'toogle_wheeler');
end;
        
uiCourses = uimenu(hcmenu, 'Label', '&1 Streckenimport', 'Separator', 'on');
    uimenu(uiCourses, 'Label', 'Lade Kurve &1', 'Callback', @(src,evt) Idealfinder.Lib.LoadTrack('Kurve1', handles, settings));
    uimenu(uiCourses, 'Label', 'Lade Kurve &2', 'Callback', @(src,evt) Idealfinder.Lib.LoadTrack('Kurve2', handles, settings));
    uimenu(uiCourses, 'Label', 'Lade Kurve &3', 'Callback', @(src,evt) Idealfinder.Lib.LoadTrack('Kurve3', handles, settings));
    uimenu(uiCourses, 'Label', 'Lade &Aschheim', 'Callback', @(src,evt) Idealfinder.Lib.LoadTrack('aschheim', handles, settings));
    uimenu(uiCourses, 'Label', 'Lade Strecke aus &GPS-Datei', 'Callback', @(src,evt) Idealfinder.Lib.LoadTrack('', handles, settings));
    uimenu(uiCourses, 'Label', 'Kurvefolge &manuell eingeben', 'Callback', @(src,evt) Idealfinder.Lib.LoadTrack('custom', handles, settings));
    uimenu(uiCourses, 'Label', 'Moving-Average-Filter', 'Tag', 'filter_maf', 'Callback', 'toogle_filter;', 'Separator', 'on', 'Checked', 'on');
    uimenu(uiCourses, 'Label', 'DPS-Filter', 'Tag', 'filter_dps', 'Callback', 'toogle_filter;');

settings.filter = 'maf'; % 'dps';
settings.calc = 'gauss'; % 'simple';

uiDevs = uimenu(hcmenu, 'Label', '&2 Devs');

asMFiles = dir(fullfile(sPackage.path, '+Dev', '*.m'));

strRootDir = fileparts(sPackage.path);
for sMFile = asMFiles'
    try
        strFile = fullfile(sMFile.folder, sMFile.name);
        fileID = fopen(strFile, 'r');
        comment = textscan(fileID, '%s', 1, 'delimiter', '\n'); 
        fclose(fileID);
        devnotes = strrep(comment{1}, '%', '');
        [~, strName] = fileparts(sMFile.name);
        strDevCmd = strrep(fullfile(sMFile.folder, strName), strRootDir, '');
        strPattern = sprintf('(%s+)|(%s)', repmat(filesep,1,3), repmat(filesep,1,2));
        strDevCmd = regexprep(strDevCmd, strPattern, '.');
        strDevCmd = regexprep(strDevCmd, '^\.', '');
        uimenu(uiDevs, 'Label', sprintf('%s :%s', strName, devnotes{1}), 'Callback', strDevCmd);
    catch oME
        disp('Fehler beim auslesen der DevNotes');
        throw(oME)
    end   
end
handles.hMainAxes.UIContextMenu = hcmenu;

veh = Carisma.Vehicle;
wheeler = Idealfinder.Wheeler.initWheeler;
%wheeler = Idealfinder.Wheeler.updateWheelerData(wheeler, gobjects(0));
end