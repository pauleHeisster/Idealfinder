function [oCourse] = LoadTrack(strTrackName, oMainDialog)
cla(oMainDialog.hMainAxes)

if ~isempty(strTrackName)
    switch strTrackName
        case 'Kurve1'
            aR = [0, -30, 0];
            aL = [30, Idealfinder.Lib.ArcLength(aR(2), 90), 30];
            oTrack = Idealfinder.Track.Generator(aR,aL);
            x = oTrack.XY(:,1);
            y = oTrack.XY(:,2);
            z = zeros(size(x));
            b = ones(size(x))*10;
        case 'Kurve2'
            aR = [0, -30, 0];
            aL = [30, Idealfinder.Lib.ArcLength(aR(2), 180), 30];
            oTrack = Idealfinder.Track.Generator(aR,aL);
            x = oTrack.XY(:,1);
            y = oTrack.XY(:,2);
            z = zeros(size(x));
            b = ones(size(x))*10;
        case 'Kurve3'
            aR = [0, -30, 35, 0];
            aL = [30, Idealfinder.Lib.ArcLength(aR(2), 90), Idealfinder.Lib.ArcLength(aR(3), 90), 30];
            oTrack = Idealfinder.Track.Generator(aR,aL);
            x = oTrack.XY(:,1);
            y = oTrack.XY(:,2);
            z = zeros(size(x));
            b = ones(size(x))*10;
        case 'custom'
            oTrack = Idealfinder.Track.Generator();
            x = oTrack.XY(:,1);
            y = oTrack.XY(:,2);
            z = zeros(size(x));
            b = ones(size(x))*10;
        otherwise
            sTrackPackage = what(fullfile('Idealfinder', '+Track'));
            % TODO: if exist(strFile, 'file') == 2
            load(fullfile(sTrackPackage.path, sprintf('%s.mat', strTrackName)));
    end
else
    % Laedt GPS-Daten
    [strFile, strPath, nExtIndex] = uigetfile({'*.txt';'*.gpx'}, 'Lade Strecke aus GPS-Messung', '');
    strFile = fullfile(strPath, strFile);
    switch nExtIndex
        case 1 % txt (csv)
            [lat, lng, z] = Idealfinder.Lib.loadtxt(strFile);
        case 2 % gpx
            route = Idealfinder.Lib.loadgpx(strFile);
            z = route(:,3);
            lat = route(:,4); % y
            lng = route(:,5); % x
    end    

    switch oMainDialog.sSettings.calc
        case 'simple'
            % eigener vereinfachter Algorithmus
            [x, y] = Idealfinder.Lib.simple(lat, lng);
        case 'gauss'
            % Gauss-Algorythmus
            [x, y] = Idealfinder.Lib.gauss(lat, lng);
    end

    switch oMainDialog.sSettings.filter
        case 'maf'
            n = 5;
            n_ma = 5;
            type = 'valid';
            for i = 1:n
                x = Idealfinder.Lib.movingAverage(x, n_ma, type);
                y = Idealfinder.Lib.movingAverage(y, n_ma, type);
                z = Idealfinder.Lib.movingAverage(z, n_ma, type);
            end
        case 'dps'
            tol = 2; % [m] Abstand
            tol = inputdlg('DPS-Simplify: ', 'Toleranz festlegen [m]:', 1, {num2str(tol)});
            tol = str2double(tol{:});
            ps = Idealfinder.Lib.dpsimplify([x,y,z], tol);
            x = ps(:,1);
            y = ps(:,2);
            z = ps(:,3);
    end
    
    b = ones(size(x))*10;
end

oCourse = Idealfinder.Course([x,y,z], b);
oCourse.drawPath(oMainDialog.hMainAxes);
oCourse.drawBorder(oMainDialog.hMainAxes);
assignin('base', 'oCourse', oCourse);
end