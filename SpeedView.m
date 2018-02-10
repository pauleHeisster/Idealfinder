classdef SpeedView < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        % Basic Features
        Figure           %matlab.ui.Figure
        StartButton      %matlab.ui.control.Button
        % Animation Items
        AnimationPanel   %matlab.ui.container.Panel
        AnimateSwitch    %matlab.ui.control.Switch
        PauseButton      %matlab.ui.control.StateButton
        StatusLabel      %matlab.ui.control.Label
        StatusLamp       %matlab.ui.control.Lamp
        CurDataLabel     %matlab.ui.control.Label
        % MainAxes
        AxesPanel        %matlab.ui.container.Panel
        SpeedAxes        %matlab.ui.control.UIAxes
        KammAxes         %matlab.ui.control.UIAxes
        LongAcclAxes     %matlab.ui.control.UIAxes
        LatAcclAxes      %matlab.ui.control.UIAxes
        % Additional Axes
        CurvatureAxes    %matlab.ui.control.UIAxes        
    end
    
    properties (Access = private)
        bAnimation = true;
        bLegacyUI = false;
        anCurStep = 1;
        nMargin = 5; % px
    end

    % App initialization and construction
    methods (Access = private)

        % Create Figure and components
        function createComponents(app)
            % Create Figure
            anFigSize = [100 100 700 500];
            if app.bLegacyUI
                nRowsSubplots = 4;
                nColsSubplots = 4;
                app.Figure = figure( ...
                      'Name', 'Figure' ...
                    );
            else
                app.Figure = uifigure( ...
                      'Name', 'UI Figure' ...
                    );
                setAutoResize(app, app.Figure, true)
            end
            app.Figure.Position = anFigSize;
            
            % Create StartButton
            if app.bLegacyUI
                app.StartButton = uicontrol(app.Figure ...
                    , 'Style', 'pushbutton' ...
                    , 'Callback', @(~,~) app.StartVisualize() ...
                    , 'String', 'Start' ...
                    , 'Units', 'pixels' ...
                    );
            else
                app.StartButton = uibutton(app.Figure, 'push' ...
                    , 'ButtonPushedFcn', @(~,~) app.StartVisualize() ...
                    , 'Text', 'Start' ...
                    );
            end
            anStartBtnPos = [app.nMargin app.nMargin 100 50];
            app.StartButton.Position = anStartBtnPos;
                        
            % Create AnimationPanel
            anAnimationPanelPos = [ ...
                (anStartBtnPos(1)+anStartBtnPos(3))+app.nMargin ...
                anStartBtnPos(2) ...
                anFigSize(3)-((anStartBtnPos(1)+anStartBtnPos(3))+2*app.nMargin) ...
                anStartBtnPos(4) ...
                ];
            app.AnimationPanel = uipanel(app.Figure ...
                , 'Units', 'pixels' ...
                , 'Title', '' ...'Animation' ...
                , 'Position', anAnimationPanelPos ...
                );
            
            % Create AxesPanel
            anAxesPanelPos = [ ...
                app.nMargin ...
                anStartBtnPos(4)+2*app.nMargin ...
                anFigSize(3)-2*app.nMargin ...
                anFigSize(4)-anStartBtnPos(4)-3*app.nMargin ...
                ];
            app.AxesPanel = uipanel(app.Figure ...
                , 'Units', 'pixels' ...
                , 'Title', '' ...
                , 'Position', anAxesPanelPos ...
                );
            anAxesPanelPos = app.AxesPanel.InnerPosition;
            
            % Create AnimateSwitch
            if app.bLegacyUI
                app.AnimateSwitch = uicontrol(app.AnimationPanel ...
                    , 'Style', 'toggle' ...
                    , 'Callback', @(~,evt) app.ToggleAnimation(evt) ...
                    , 'String', 'Animation' ...
                    );
            else
                app.AnimateSwitch = uiswitch(app.AnimationPanel, 'slider' ...
                    , 'Orientation', 'horizontal' ...
                    , 'Items', {'', ''} ... % clear Labels
                    , 'ItemsData', {false, true} ...
                    , 'ValueChangedFcn', @(~,evt) app.ToggleAnimation(evt) ...
                    );
            end
            app.AnimateSwitch.Position = [app.nMargin app.nMargin 100 app.AnimationPanel.InnerPosition(4)-2*app.nMargin];
            app.AnimateSwitch.Value = app.bAnimation;

            % Create PauseButton
            if app.bLegacyUI
                app.PauseButton = uicontrol(app.AnimationPanel ...
                    , 'Style', 'toggle' ...
                    , 'Callback', @(~,~) app.TogglePauseAnimation() ...
                    , 'String', 'Pause' ...
                    );
            else
                app.PauseButton = uibutton(app.AnimationPanel, 'state' ...
                    , 'Text', 'Pause' ...
                    , 'ValueChangedFcn', @(~,~) app.TogglePauseAnimation() ...
                    );
            end
            anPrevPosition = app.AnimateSwitch.Position;
            app.PauseButton.Position = [ ...
                (anPrevPosition(1)+anPrevPosition(3))+app.nMargin ...
                anPrevPosition(2) ...
                100 ...
                anPrevPosition(4) ...
                ];
            
            if ~app.bLegacyUI
            % Create StatusLamp
            anPrevPosition = app.PauseButton.Position;
            app.StatusLamp = uilamp(app.AnimationPanel);
            app.StatusLamp.Position = [ ...
                (anPrevPosition(1)+anPrevPosition(3))+app.nMargin ...
                app.nMargin ...
                20 ...
                20 ...
                ];
            
            % Create StatusLampLabel
            anPrevPosition = app.StatusLamp.Position;
            app.StatusLabel = uilabel(app.AnimationPanel);
            app.StatusLabel.HorizontalAlignment = 'left';
            app.StatusLabel.Position = [ ...
                (anPrevPosition(1)+anPrevPosition(3))+app.nMargin ...
                app.nMargin ...
                100 ...
                15 ...
                ];
            app.StatusLabel.Text = 'strStatus';

            % Create CurDataLabel
            anPrevPosition = app.StatusLabel.Position;
            app.CurDataLabel = uilabel(app.AnimationPanel);
            app.CurDataLabel.Position = [ ...
                (anPrevPosition(1)+anPrevPosition(3))+app.nMargin ...
                app.nMargin ...
                (anPrevPosition(1)+anPrevPosition(3))+app.nMargin ...
                15 ...
                ];
            app.CurDataLabel.Text = 'strCurData';
            end

            % Create KammAxes
            if app.bLegacyUI
                app.KammAxes = subplot(nRowsSubplots, nColsSubplots, 16 ...
                    , 'Parent', app.AxesPanel ...
                    , 'Units', 'pixels' ...
                    );
                app.LongAcclAxes = subplot(nRowsSubplots, nColsSubplots, [13 15] ...
                    , 'Parent', app.AxesPanel ...
                    , 'Units', 'pixels' ...
                    );
                app.LatAcclAxes = subplot(nRowsSubplots, nColsSubplots, [4 12] ...
                    , 'Parent', app.AxesPanel ...
                    , 'Units', 'pixels' ...
                    );
                app.SpeedAxes = subplot(nRowsSubplots, nColsSubplots, [1 7] ...
                    , 'Parent', app.AxesPanel ...
                    , 'Units', 'pixels' ...
                    );
                app.CurvatureAxes = subplot(nRowsSubplots, nColsSubplots, [9 11] ...
                    , 'Parent', app.AxesPanel ...
                    , 'Units', 'pixels' ...
                    );
            else
                app.KammAxes = uiaxes(app.AxesPanel);
            end
            nKammSize = 150; % px
            anKammPosition = [ ...
                anAxesPanelPos(3)-nKammSize-app.nMargin ...
                app.nMargin ...
                nKammSize ...
                nKammSize ...
                ];
            app.KammAxes.Position = anKammPosition;
            
            app.KammAxes.DataAspectRatio = [1, 1, 1];
            app.KammAxes.YAxisLocation = 'right';
            app.KammAxes.Box = 'on';
            app.KammAxes.XGrid = 'on';
            app.KammAxes.YGrid = 'on';
            
            % Create LongAcclAxes
            if ~app.bLegacyUI
                app.LongAcclAxes = uiaxes(app.AxesPanel);
            end
            app.LongAcclAxes.Position = [ ...
                app.nMargin ...
                anKammPosition(2) ...
                anKammPosition(1)-app.nMargin ...
                nKammSize ...
                ];
            ylabel(app.LongAcclAxes, 'LongitudinalAcceleration');
%             ylabel(app.LongAcclAxes, 'a_{Long} [m/s^2]');
            app.LongAcclAxes.Box = 'on';
            app.LongAcclAxes.XGrid = 'on';
            app.LongAcclAxes.YGrid = 'on';

            % Create LatAcclAxes
            if ~app.bLegacyUI
                app.LatAcclAxes = uiaxes(app.AxesPanel);
            end
            app.LatAcclAxes.Position = [ ...
                anKammPosition(1) ...
                anKammPosition(2)+anKammPosition(4)+app.nMargin ...
                nKammSize ...
                app.AxesPanel.InnerPosition(4)-(anKammPosition(2)+anKammPosition(4))-2*app.nMargin ...
                ];
%             xlabel(app.LatAcclAxes, 'LateralAcceleration');
%             xlabel(app.LatAcclAxes, 'a_{Lat} [m/s^2]');
            app.LatAcclAxes.XAxisLocation = 'top';
            app.LatAcclAxes.YAxisLocation = 'right';
            app.LatAcclAxes.Box = 'on';
            app.LatAcclAxes.XGrid = 'on';
            app.LatAcclAxes.YGrid = 'on';
            
            % Create SpeedAxes
            if ~app.bLegacyUI
                app.SpeedAxes = uiaxes(app.AxesPanel);
            end
            nSpeedSize = 200; % px
            app.SpeedAxes.Position = [ ...
                app.nMargin ...
                app.AxesPanel.InnerPosition(4)-nSpeedSize-app.nMargin ...
                anKammPosition(1)-app.nMargin ...
                nSpeedSize ...
                ];
            title(app.SpeedAxes, 'SpeedView');
            xlabel(app.SpeedAxes, 'Distance');
            ylabel(app.SpeedAxes, 'Velocity');
%             ylabel(app.SpeedAxes, 'v [m/s]');
            app.SpeedAxes.Box = 'on';
            app.SpeedAxes.XGrid = 'on';
            app.SpeedAxes.YGrid = 'on';
            
            % Create CurvatureAxes
            if ~app.bLegacyUI
                app.CurvatureAxes = uiaxes(app.AxesPanel);
            end
            nCurvSize = 100; % px
            nHeight = min(nCurvSize, (app.SpeedAxes.Position(2)-(anKammPosition(2)+anKammPosition(3))-2*app.nMargin));
            app.CurvatureAxes.Position = [ ...
                app.nMargin ...
                anKammPosition(2)+anKammPosition(4)+app.nMargin ...
                anKammPosition(1)-app.nMargin ...
                nHeight ...
                ];
%             xlabel(app.CurvatureAxes, '');
            ylabel(app.CurvatureAxes, 'Curvature');
            app.CurvatureAxes.XTickLabel = '';
            app.CurvatureAxes.Box = 'on';
            app.CurvatureAxes.XGrid = 'on';
            app.CurvatureAxes.YGrid = 'on';
            
            if app.bLegacyUI
                linkaxes([app.SpeedAxes, app.CurvatureAxes, app.LongAcclAxes], 'x');
                linkaxes([app.LongAcclAxes, app.KammAxes], 'y');
                linkaxes([app.KammAxes, app.LatAcclAxes], 'x');
            end
        end
        
        function Visualize(app)
            bProfiling = false;
            if bProfiling
                profile on
            end
            
            global oVehicle nMaxPauseTime
            nMaxPauseTime = 0.3;
            hMainaxes = findobj('Tag', 'Hauptachse');
            sSpeedData = oVehicle.getSpeed();
            
            if app.bAnimation
                nPauseTime = max(min(nMaxPauseTime, 1./sSpeedData.anV), 0);
            end
            
            anXVals = cumsum(oVehicle.oPath.L);
            anK = oVehicle.oPath.K;
            sSpeedData.anAcclLat = anK.*sSpeedData.anV.^2;
            
            %% Speed-Axes
            hLineDrive = animatedline(app.SpeedAxes ...
                , 'color', 'm' ...
                , 'LineWidth', 1 ...
                , 'LineStyle', '--' ...
                , 'UserData', struct('strLegendName', sprintf('v_{[t : %.3fs]}', sum(sSpeedData.anTime))) ...
                );
            
            ahLegendEntries = flipud(app.SpeedAxes.Children);
            
            astrLegendText = arrayfun(@(hLegendEntry) {hLegendEntry.UserData.strLegendName}, ahLegendEntries);%{'v_{Accl}', 'v_{Brake}'}
            legend(app.SpeedAxes ...
                , ahLegendEntries, astrLegendText ...
                , 'Location', 'Northwest' ...
                , 'Orientation', 'Horizontal' ...
                );
            
            %% Laengsbeschleunigung
            hLineAcclLong = animatedline('Parent', app.LongAcclAxes, 'color', 'r');
            
            %% Querbeschleunigung
            hLineAcclLat = animatedline('Parent', app.LatAcclAxes, 'color', 'k');
            
            %% Kamm'sche Ellipse
            hLineKamm = animatedline('Parent', app.KammAxes, 'Marker', 'x');
            
            %% Streckeneinfärbung (argbColors ermitteln)
            argbColors = app.GetSpeedColors(oVehicle, sSpeedData, 'AcclLong');
            
            astrStatusLabelText = {
                'Accelerating' ...
                'Decelerating' ...
                'Coasting' ...
                };
            %Startwert angeben, wenn fortgesetzt wird
            while app.anCurStep(end) < size(anXVals, 1)
                if app.PauseButton.Value
                    fprintf('execution paused at %d\n', app.anCurStep(end));
                    break;
                end
                if ~app.bAnimation
                    app.anCurStep = 1:size(anXVals, 1);
                end
                j = app.anCurStep;
                addpoints(hLineDrive, anXVals(j), sSpeedData.anV(j));
                
                addpoints(hLineAcclLong, anXVals(j), sSpeedData.anAcclLong(j));
                addpoints(hLineAcclLat, sSpeedData.anAcclLat(j), anXVals(j));
                
                addpoints(hLineKamm, sSpeedData.anAcclLat(j), sSpeedData.anAcclLong(j));
                                
                for p = j(1):j(end)
                    %% Strecke einfaerben
                    line(anXVals(p), sSpeedData.anV(p), 'Parent', app.SpeedAxes, 'Color', argbColors(p,:), 'Marker', '.');
                    if ~isempty(hMainaxes)
                        % Ausgabe in MainDialog
                        line(oVehicle.oPath.XYZ(p, 1) ...
                           , oVehicle.oPath.XYZ(p, 2) ...
                           , oVehicle.oPath.XYZ(p, 3) ...
                           , 'Parent', hMainaxes ...
                           , 'Color', argbColors(p,:) ...
                           , 'Marker', '.' ...
                           , 'Markersize', 15);
                    end
                end
                
                if app.bAnimation
                    pause(nPauseTime(j));
                    app.StatusLamp.Color = argbColors(j,:);
                    nLimit = 0.5;%.5;
                    if sSpeedData.anAcclLong(j) < -nLimit
                        nStatusLabelIdx = 2;
                    elseif sSpeedData.anAcclLong(j) > nLimit
                        nStatusLabelIdx = 1;
                    else
                        nStatusLabelIdx = 3;
                    end
                    app.StatusLabel.Text = astrStatusLabelText{nStatusLabelIdx};
                    app.CurDataLabel.Text = sprintf('%d) Speed: %3.2f Pause: %1.3f\n', j, sSpeedData.anV(j), nPauseTime(j));
                    app.anCurStep = app.anCurStep+1;
                    drawnow limitrate
                end
            end
            if bProfiling
                profile viewer
            end
        end
        
        function ToggleAnimation(app, event)
            app.bAnimation = event.Source.Value;
            % toogle AnimationItems
            ahAnimationItems = app.AnimationPanel.Children;
            ahAnimationItems(arrayfun(@(hItem) isequal(hItem, app.AnimateSwitch), ahAnimationItems)) = [];
            if app.bAnimation
                set(ahAnimationItems, 'Enable', 'on');
            else
                set(ahAnimationItems, 'Enable', 'off');
            end
        end
        
        function TogglePauseAnimation(app)
            if ~app.PauseButton.Value
                fprintf('execution continued from %d\n', app.anCurStep(end));
                app.Visualize();
            end
        end
        
        function StartVisualize(app)
            app.initState();
            app.Visualize();
        end
        
        function initState(app)
            global oVehicle
            if isempty(oVehicle)
                error('%s:initState', 'Could not initial Dialog', mfilename);
            end
            % clear all Axes
            arrayfun(@cla, ...
                [app.SpeedAxes ...
                 app.CurvatureAxes ...
                 app.KammAxes ...
                 app.LongAcclAxes ...
                 app.LatAcclAxes]);
            if app.PauseButton.Value
                % reset Pause-Button
                app.PauseButton.Value = false;
            end
            % reset CurStepValue
            app.anCurStep = 1;
            
            [sSpeedData] = oVehicle.getSpeed();
            %% SpeedAxes
            anXVals = cumsum(oVehicle.oPath.L);
            line(anXVals, sSpeedData.anVmax ...
                , 'Parent', app.SpeedAxes ...
                , 'UserData', struct('strLegendName', 'v_{max}') ...
                );
            line(anXVals, sSpeedData.anVAccl ...
                , 'Parent', app.SpeedAxes ...
                , 'Color', 'g' ...
                , 'LineStyle', '--' ...
                , 'UserData', struct('strLegendName', 'v_{accl}') ...
                );
            line(anXVals, sSpeedData.anVBrake ...
                , 'Parent', app.SpeedAxes ...
                , 'Color', 'r' ...
                , 'LineStyle', '--' ...
                , 'UserData', struct('strLegendName', 'v_{brake}') ...
                );
            xlim(app.SpeedAxes, [1, anXVals(end)]);
            ylim(app.SpeedAxes, [0, oVehicle.nVmax]);
            %% Curvature Axes
            line(anXVals, oVehicle.oPath.K ...
                , 'Parent', app.CurvatureAxes ...
                );
            xlim(app.CurvatureAxes, [1, anXVals(end)]);
            %% LongAcceleration
            xlim(app.LongAcclAxes, [1, anXVals(end)]);
            ylim(app.LongAcclAxes, [-10, 10]*oVehicle.a.l_faktor);
            %% LatAcceleration
            xlim(app.LatAcclAxes, [-10, 10]*oVehicle.a.q_faktor);
            ylim(app.LatAcclAxes, [1, anXVals(end)]);
            
            t = -pi:.1:pi;
            for iterationItem = {2, 4, 6, 8, 10; '--', '--', '--', '--', '-'}
                nA = oVehicle.a.q_faktor*iterationItem{1};
                nB = oVehicle.a.l_faktor*iterationItem{1};
                xKamm = nA*cos(t);
                yKamm = nB*sin(t);
                xKamm(end+1) = xKamm(1);
                yKamm(end+1) = yKamm(1);
                line(xKamm, yKamm ...
                    , 'Parent', app.KammAxes ...
                    , 'LineStyle', iterationItem{2} ...
                    );
            end
            xlim(app.KammAxes, [-1, 1]*oVehicle.a.q_faktor*10);
            ylim(app.KammAxes, [-1, 1]*oVehicle.a.l_faktor*10);
        end
    end
    
    methods (Static = true)
        function [argbColors] = GetSpeedColors(oVehicle, sSpeedData, strType)
            switch strType
                case 'AcclLong'
                    anRed = round((1-sSpeedData.anAcclLong/oVehicle.a.laccl)*255)';
                    anRed(sSpeedData.anAcclLong < 0) = 255;
                    anGreen = round((1+sSpeedData.anAcclLong./oVehicle.a.lbrake)*255)';
                    anGreen(sSpeedData.anAcclLong > 0) = 255;
                    argbColors = [anRed, anGreen, zeros(numel(sSpeedData.anAcclLong), 1)]/255;
            end
        end
    end

    methods (Access = public)

        % Construct app
        function [app] = SpeedView(varargin)
            
            if ~isempty(varargin) && islogical(varargin{1})
                app.bLegacyUI = varargin{1};
            end
            % Create and configure components
            createComponents(app)
            
            initState(app)

            % Register the app with App Designer
            %registerApp(app, app.Figure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            % Delete Figure when app is deleted
            delete(app.Figure)
        end
    end
end