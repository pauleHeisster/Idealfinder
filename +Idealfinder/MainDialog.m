classdef MainDialog < handle
    %MAINDIALOG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hFigure
        hMainAxes
        sSettings
        aFigSize = [0.45, 0.6]
    end
    
    methods
        function [this] = MainDialog()
            global oVehicle
            import Idealfinder.Lib.*
            import Idealfinder.Dev.*

            this.hFigure = figure('Name', 'Idealfinder (Hauptfenster)' ...
                , 'NumberTitle', 'off' ...
                , 'Units', 'normal' ...
                , 'Position', [(1-this.aFigSize(1))/2, (1-this.aFigSize(2))/2, this.aFigSize] ...
                , 'Tag', 'MainDialog' ...
                );
               
            this.hMainAxes = axes('Parent', this.hFigure ...
                , 'Units', 'normal' ...
                , 'Position', [0, 0, 1, 1] ...
                , 'Box', 'on' ...
                , 'XTick', [] ...
                , 'YTick', [] ...
                ..., 'ButtonDownFcn', @Idealfinder.Lib.placeVehicle ...
                , 'Tag', 'Hauptachse' ...
                );
            axis(this.hMainAxes, 'equal');
            % sorgt fuer sichtbare Hoehenunterschiede
            this.hMainAxes.DataAspectRatio = [1, 1, 0.01];
            %grid(this.hMainAxes,'on');
            
            hContextMainMenu = uicontextmenu;
            hUiDel = uimenu(hContextMainMenu, 'Label', 'Obj&ekte loeschen');
                uimenu(hUiDel, 'Label', '&1 alle Objekte', ...
                    'Callback', @(~,~) this.DelAll);
                uimenu(hUiDel, 'Label', '&2 aktuelles Objekt', ...
                    'Callback', @(~,~) this.DelGCO);
                uimenu(hUiDel, 'Label', '&3 Kruemmung', ...
                    'Callback', @(~,~) delete(findobj(this.hMainAxes, 'Type', 'rectangle')), 'Separator', 'on');
                uimenu(hUiDel, 'Label', '&4 Vektoren', ...
                    'Callback', @(~,~) delete(findobj(this.hMainAxes, 'Tag', 'arrow')));
                uimenu(hUiDel, 'Label', '&5 D-Mode', ...
                    'Callback', @(~,~) delete(findobj(this.hMainAxes, 'Tag', 'dmode')));
                uimenu(hUiDel, 'Label', '&6 Optimierung', ...
                    'Callback', @(~,~) delete(findobj(this.hMainAxes, 'Tag', 'optim_item')));
                uimenu(hContextMainMenu, 'Label', 'D-Mode', ...
                    'Callback', @(src, ~) this.toogleDmode(src), 'Checked', 'off');
                
            hUiMenuCourses = uimenu(hContextMainMenu, 'Label', '&1 Streckenimport', 'Separator', 'on');
                uimenu(hUiMenuCourses, 'Label', 'Lade Kurve &1', 'Callback', @(src,~) Idealfinder.Lib.LoadTrack('Kurve1', this));
                uimenu(hUiMenuCourses, 'Label', 'Lade Kurve &2', 'Callback', @(src,~) Idealfinder.Lib.LoadTrack('Kurve2', this));
                uimenu(hUiMenuCourses, 'Label', 'Lade Kurve &3', 'Callback', @(src,~) Idealfinder.Lib.LoadTrack('Kurve3', this));
                uimenu(hUiMenuCourses, 'Label', 'Lade &Aschheim', 'Callback', @(src,~) Idealfinder.Lib.LoadTrack('aschheim', this));
                uimenu(hUiMenuCourses, 'Label', 'Lade Strecke aus &GPS-Datei', 'Callback', @(src,~) Idealfinder.Lib.LoadTrack('', this));
                uimenu(hUiMenuCourses, 'Label', 'Kurvefolge &manuell eingeben', 'Callback', @(src,~) Idealfinder.Lib.LoadTrack('custom', this));
                uimenu(hUiMenuCourses, 'Label', 'Moving-Average-Filter', 'Tag', 'filter_maf', 'Callback', @(src,~) this.toogleFilter(src), 'Separator', 'on', 'Checked', 'on');
                uimenu(hUiMenuCourses, 'Label', 'DPS-Filter', 'Tag', 'filter_dps', 'Callback', @(src,~) this.toogleFilter(src));

            this.sSettings.bDmode = false;
            this.sSettings.filter = 'maf'; % 'dps';
            this.sSettings.calc = 'gauss'; % 'simple';
            if true
                %wheeler_ui = ...
                uimenu(hContextMainMenu, 'Label', '&Fahrzeugparameter', 'Callback', @(~,~) Carisma.Dialog(oVehicle));
                %uimenu(wheeler_ui, 'Label', '&Motorkennfeld', 'Tag', 'wheeler_kf', 'Checked', 'off', 'Callback', 'toogle_wheeler');
            end
            
            hUiDevs = uimenu(hContextMainMenu, 'Label', '&2 Devs');
            
            sPackage = what('Idealfinder');
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
                    strPattern = sprintf('(%s+)|(%s)', repmat(filesep, 1, 3), repmat(filesep, 1, 2));
                    strDevCmd = regexprep(strDevCmd, strPattern, '.');
                    strDevCmd = regexprep(strDevCmd, '^\.', '');
                    uimenu(hUiDevs, 'Label', sprintf('%s :%s', strName, devnotes{1}), 'Callback', strDevCmd);
                catch oME
                    fprintf('Fehler beim auslesen der DevNotes (%s)\n', sMFile.name);
                    throw(oME)
                end   
            end
            this.hMainAxes.UIContextMenu = hContextMainMenu; 
        end
        
        function toogleDmode(this, hUIMenu)
            switch hUIMenu.Checked
                case 'on'
                    hUIMenu.Checked = 'off';
                    this.sSettings.bDmode = false;
                otherwise
                    hUIMenu.Checked = 'on';
                    this.sSettings.bDmode = true;
            end
        end
        
        function toogleFilter(this, hUIFilterMenu)
            hUIParentMenu = hUIFilterMenu.Parent;
            ahUIChildren = hUIParentMenu.Children;
            ahUIFilter = ahUIChildren(~cellfun(@isempty, regexp({ahUIChildren.Tag}, 'filter_', 'once')));
            for hUIFilter = ahUIFilter'
                if hUIFilterMenu == hUIFilter
                   hUIFilter.Checked = 'on';
                   astrFilterType = regexp(hUIFilter.Tag, 'filter_(.*)', 'tokens', 'once');
                   this.sSettings.filter = astrFilterType{1};
                else
                   hUIFilter.Checked = 'off';
                end
            end
        end
        
        function DelAll(this)
            delete(this.hMainAxes.Children(1:end-3));
            this.hMainAxes.UserData = [];
        end
        
        function DelGCO(this)
            oCurrentObject = gco;
            bDel = true;
            astrTagnames = {'Hauptachse', 'ML', 'Start', 'Ziel', 'LRand', 'RRand'};
            for astrTagname = astrTagnames
                strTagname = astrTagname{:};
                hUndelObject = findobj(this.hMainAxes, 'Tag', strTagname);
                if ~isempty(hUndelObject) && isequal(oCurrentObject, hUndelObject)
                    bDel = false;
                    break;
                end
            end
            if bDel
                delete(oCurrentObject);
            else
                fprintf('aktuelles Objekt: %s (%s) kann nicht entfernt werden!\n', oCurrentObject.Type, oCurrentObject.Tag)
            end
        end
    end
    
end

