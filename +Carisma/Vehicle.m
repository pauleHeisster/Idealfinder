classdef Vehicle < handle
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mass = 1200;
        oEngine
        oGearbox
        oPath = Idealfinder.Path.empty
        aero
        nV0 = 0;
        nV = 0;
        nOrient = 0;
        aCurPos
        nVmax = 100; %[m/s]
        l_q = [0, 0];
        dims
        oInertia
        a
        bMapInterpolation = false;
    end
    
    methods
        function [this] = Vehicle(varargin)
            for aArgin = varargin
                Argin = aArgin{:};
                switch class(Argin)
                    case 'Carisma.Engine'
                        this.oEngine = Argin;
                    case 'Carisma.Gearbox'
                        this.oGearbox = Argin;
                    otherwise
                        warning('Unknown InputArgument "%s" of type %s', char(Argin), class(Argin));
                end
            end
            if isempty(this.oEngine)
                this.oEngine = Carisma.Engine;
            end
            if isempty(this.oGearbox)
                this.oGearbox = Carisma.Gearbox;
            end
            this.aero.cW = .29;
            this.aero.A = 2.3;
            % Abmessungen
            this.dims.b = 1.75; % [m] Breite
            this.dims.l = 2.73; % [m] Radstand
            this.dims.h = 1.50; % [m] Schwerpunktshoehe
            this.dims.b_lr = 0.4;
            this.dims.l_fr = 0.5;
            this.dims.h_bt = 0.5;
            this.dims.R = 0.35; % [m] Radhalbmesser
            % Beschleunigung || Inertia
            this.a.l_faktor = 1;
            this.a.q_faktor = 1;
            this.a.qmax = []; % [m/s^2] wird immer aktualisiert; mit Faktor variierbar fÃ¼r Fahrmodi
            this.a.lmax = []; % [m/s^2] wird immer aktualisiert
            this.a.lbrake = 10; % [m/s^2] - ist fix; mit Faktor variierbar fuer Fahrmodi
            this.a.laccl = 4; % [m/s^2] - siehe S. 32
            this.a.x = []; % siehe S. 32 - wird immer aktualisiert
            this.a.y = []; % siehe S. 32 - wird immer aktualisiert
            this.a.z = []; % siehe S. 32 - w
            
            this.oInertia.nMass = 1200; % [ks] Fahrzeugmasse
        end
        
        function TorqueRatios(this, varargin)
            for aArgin = varargin
                switch class(aArgin{:})
                    case 'matlab.graphics.axis.Axes'
                        hAX = aArgin{:};
                end
            end
            if ~exist('hAX', 'var')
                hAX = axes;
            end
            anRatios = this.oGearbox.getRatios('forward');
            for nRatio = anRatios
                Torque = this.oEngine.torque;
                y = Torque(:,2)*nRatio;
                x = Torque(:,1)/nRatio;
                line(x, y, 'Parent', hAX);
            end
        end
        
        function showVehicleStats(this)
            N = 3;
            cols = 1;
            rows = 3;
            ahAchsen = cell(N, 1);
            for i = 1:N
                ahAchsen{i} = subplot(rows, cols, i);
            end
            this.TorqueRatios(ahAchsen{1});
            nNmin = min(this.oEngine.torque(:,1));
            nNmax = max(this.oEngine.torque(:,1));
            this.oGearbox.showRatios(ahAchsen{2},[nNmin, nNmax]);
            this.oEngine.showTorque(ahAchsen{3});
            this.oEngine.showPower(ahAchsen{3});
        end
        
        function updateWheeler(this, sTrackData)
            g = 9.81; % [m/s^2]
            roh = 1.184; % [kg/m^3] Luftdichte bei 25degC

            %% Vertikalbeschleunigung
            this.a.z = g * cosd(sTrackData.alpha_l) * cosd(sTrackData.alpha_q) ...
                + sTrackData.K_l * sTrackData.v^2 ...
                + sTrackData.K_q * sTrackData.v_q^2;
            if this.a.z > 0
                this.a.lmax = this.a.l_faktor * this.a.z;
                this.a.qmax = this.a.q_faktor * this.a.z;
            else
                this.a.lmax = 0;
                this.a.qmax = 0;
            end

            %% Querbeschleunigung
            aY = g * sind(sTrackData.alpha_q) * cosd(sTrackData.alpha_l) ...
                - sTrackData.K * sTrackData.v^2 * cosd(sTrackData.alpha_q);
            this.a.y = min(abs(aY), this.a.qmax) * sign(aY);

            %% Laengsbeschleunigung
            aX = (this.a.lmax * sqrt(1-abs(this.a.y)/this.a.qmax)); % hier könnte ein fehler auftreten
            if sTrackData.accl
                if this.bMapInterpolation
                    F_Ant = interp1(this.kf(:,1), this.kf(:,2), sTrackData.v); % ,'spline');
                    F_Ant = min (F_Ant, this.a.lmax*this.f.m);
                    this.a.laccl = F_Ant/this.f.m ... % Antrieb
                                    - g * sind(sTrackData.alpha_l) * cosd(sTrackData.alpha_q) ... % Steigungswiderstand
                                    - this.f.c_R * this.a.z ... % Rollwiderstand
                                    - this.f.c_W * this.dims.A/this.f.m * roh/2 * sTrackData.v^2; % Luftwiderstand
                end
                aXmax = this.a.laccl;
            else
                aXmax = this.a.lbrake;
            end
            this.a.x = min(aX, aXmax);
        end
        
        function [sSpeedData] = getSpeed(this, varargin)
            %% getSpeed function
            if isempty(this.oPath)
                disp('empty oPath!');
                return
            end
            
            n = size(this.oPath.XYZ, 1);
            anVmax = zeros(n, 1);
            anVAccl = zeros(n, 1);
            anVBrake = zeros(n, 1);
            anTime = zeros(n, 1);

            anK = this.oPath.K;
            anL = this.oPath.L;
            %% Grenzgeschwindigkeit
            for i = 1 : n
                sParam = this.setParamStruct(i, true);
                try
                    sParam.v = anVmax(i-1);
                catch
                    sParam.v = anVmax(i);
                end
                this.updateWheeler(sParam);
                anVmax(i) = sqrt(this.a.qmax / abs(anK(i)));
                anVmax(i) = min(anVmax(i), this.nVmax);
            end

            anVAccl(1) = this.nV; %nV0; % letzter Punkt vor eigentlichen Berechnung
            anVBrake(end) = anVmax(end);

            %% Beschleunigungswerte
            for i = 1 : 1 : n
                sParam = this.setParamStruct(i, true);
                try
                    sParam.v = anVAccl(i-1);
                catch
                    sParam.v = anVAccl(i);
                end
                ds = anL(i);
                this.updateWheeler(sParam);
                nAcclLong = this.a.x;
                nVAccl = sqrt( sParam.v^2 + 2*nAcclLong*ds );
                anVAccl(i) = min(nVAccl, anVmax(i));
            end

            %% Verzoegerungswerte
            for i = n : -1 : 1
                sParam = this.setParamStruct(i, false);
                try
                    sParam.v = anVBrake(i+1);
                    ds = anL(i+1);
                catch
                    sParam.v = anVBrake(i);
                    ds = anL(i);
                end
                this.updateWheeler(sParam);
                nAcclLong = this.a.x;
                nVBrake = sqrt( sParam.v^2 + 2*nAcclLong*ds );
                anVBrake(i) = min(nVBrake, anVmax(i));
            end
            
            anV = min(anVAccl, anVBrake);
            anTime(2:n) = 2*anL(2:n)./(anV(1:n-1)+anV(2:n));
            anAcclLong(2:n) = diff(anV)./anTime(2:n);
            
            %% Ausgaben zusammenführen
            sSpeedData = struct();
            sSpeedData.anV = anV;
            sSpeedData.anTime = anTime;
            sSpeedData.anVmax = anVmax;
            sSpeedData.anVAccl = anVAccl;
            sSpeedData.anVBrake = anVBrake;
            sSpeedData.anAcclLong = anAcclLong;
        end
        
        function [param] = setParamStruct(this, nIdx, bAccl)
            param.alpha_l = this.oPath.alpha_l(nIdx);
            param.alpha_q = 0; % this.oPath.alpha_q(i);
            param.K = this.oPath.K(nIdx);
            param.K_l = this.oPath.K_l(nIdx);
            param.K_q = 0; % this.oPath.K_q(i);
            param.v_q = 0;
            param.accl = bAccl;
        end
    end
end