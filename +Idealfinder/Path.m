classdef Path < handle
    %PATH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        XYZ
        K
        L
    end
    
    properties (Hidden)
        MP
        MP_v % mittelpunktsvektor
        alpha_l % steigung
        K_l % kruemmung hoehe
    end
    
    properties (Dependent)
%         nLength
    end
    
    methods
        function [this] = Path(xyz)
            this.XYZ = xyz;
            this.GetLength();
            this.getCurvature();
            
            n = size(xyz, 1);
            this.MP = zeros(n, 2);
            this.MP_v = zeros(n, 2);
            this.alpha_l = zeros(n, 1);
            this.K_l = zeros(n, 1);
            
            if size(this.XYZ, 2) < 3
                this.XYZ(:, 3) = zeros(n, 1);
            end
            bHeight = range(this.XYZ(:, 3)) ~= 0;
            
            if n == 2
                vec = diff(xyz);
                n_vec = vec(1, 1:2)/norm(vec(1, 1:2));
                for i = 1:n
                    this.MP_v(i, :) = Idealfinder.Lib.Rotate(n_vec(1, 1:2), -90);
                end
                if bHeight
                    this.alpha_l(1) = atand( (this.XYZ(end, 3) - this.XYZ(1, 3)) / norm(vec(1, 1:2)) );
                end
            elseif n > 2
                vor = diff(xyz(1:end-1, :));
                nach = diff(xyz(2:end, :));
                for j = 2:n-1, i = j-1; k = j+1; % indices
                    n_vor = vor(i, 1:2)/norm(vor(i, 1:2));
                    n_nach = nach(i, 1:2)/norm(nach(i, 1:2));
                    if isequal(n_vor, n_nach)
                        this.MP_v(j,:) = Idealfinder.Lib.Rotate(vor(i, 1:2), -90) / norm(vor(i, 1:2));
                    else
                        [~, this.MP(j, 1), this.MP(j, 2)] = Idealfinder.Lib.radi( xyz(i:k, 1) , xyz(i:k, 2) );
                        dir_vektor = xyz(j, 1:2) - this.MP(j, :);
                        vorz = cross(vor(i, :),nach(i, :));
                        this.MP_v(j, :) = dir_vektor/norm(dir_vektor)*sign(vorz(3));
                    end
                    if bHeight
                        % Hoehe und LaengsKruemmung
                        Lij = norm(vor(i, 1:2));
                        Ljk = norm(nach(i, 1:2));
                        dZ = this.XYZ(j, 3) - this.XYZ(i, 3);
                        xh = [0, Lij, Lij + Ljk]';
                        yh = this.XYZ(i:k, 3); % yh = [Z(i), Z(j), Z(k)];
                        Rh = Idealfinder.Lib.radi(xh, yh);
                        this.K_l(j) = 1/Rh;
                        this.alpha_l(j) = atand(dZ/Lij);
                    end
                end
                this.MP_v(1, :) = Idealfinder.Lib.Rotate(vor(1, 1:2), -90) / norm(vor(1, 1:2));
                this.MP_v(end, :) = Idealfinder.Lib.Rotate(nach(end, 1:2), -90) / norm(nach(end, 1:2));
                if bHeight
                   this.alpha_l(1) = atand( (this.XYZ(2, 3)-this.XYZ(1, 3)) / norm(vor(1, 1:2)) ); 
                   this.alpha_l(end) = atand( (this.XYZ(end, 3)-this.XYZ(end-1, 3)) / norm(nach(end, 1:2)) );
                end
            end
        end
        
        function drawPath(this, hAX)
            line(hAX, this.XYZ(:, 1), this.XYZ(:, 2), this.XYZ(:, 3) ...
                , 'LineStyle', '--' ...
                , 'Tag', 'path' ...
                );
        end
        
        function drawKruemmung(this, hAX)
            for sCurCurve = Idealfinder.Lib.ArrayOfStructs('MP', this.MP, 'R', abs(1./this.K))
                nR = sCurCurve.R;
                if isinf(nR), continue, end
                rectangle(hAX ...
                    , 'Position', [sCurCurve.MP-nR, nR*2, nR*2] ...
                    , 'Curvature', 1 ...
                    , 'EdgeColor', [0, 0, 0, .2] ...
                    , 'Tag', 'dmode' ...
                    );
            end
        end
        
        function drawOrient(this, hAX)            
            for sCurOrient = Idealfinder.Lib.ArrayOfStructs('MP_v', this.MP_v, 'XYZ', this.XYZ)
                line(hAX, [0, sCurOrient.MP_v(1)] + sCurOrient.XYZ(1), [0, sCurOrient.MP_v(2)] + sCurOrient.XYZ(2) ...
                    , 'color', 'red' ...
                    , 'Tag', 'dmode' ...
                    );
            end
        end
        
        function [L] = GetLength(this)
            if ~isempty(this.L)
                L = this.L;
                return
            end
            
            n = size(this.XYZ, 1);
            if n > 1
                delta = diff(this.XYZ);
                L = zeros(n, 1);
                for i = 2:n
                    L(i) = norm(delta(i-1, 1:2));
                end
            else
                L = 0;
            end
            this.L = L;
        end
        
        function [nL] = GetNormLength(this)
            l = cumsum(this.GetLength());
            nL = l/l(end);
        end
        
        function getCurvature(this)
            n = size(this.XYZ, 1);
            this.K = zeros(n, 1);
            if true
                if n > 2
                    for aIdxs = [1:n-2; 2:n-1; 3:n]
                        j = aIdxs(2);
                        R = Idealfinder.Lib.radi(this.XYZ(aIdxs, 1), this.XYZ(aIdxs, 2));
                        this.K(j) = 1/R;
                    end
                end
            else
                this.K = Idealfinder.Path.Curvature(this.XYZ(:, 1), this.XYZ(:, 2));
            end
        end
        
        function overview(this)
            N = 4;
            p = 1;
            x = cumsum(this.L);
            figure('Name', 'Streckenparameter');
            ahAxes = {};
            
            ahAxes{p} = subplot(N, 1, p);
            title(ahAxes{p}, 'Kruemmung (Kurve)');
            ylabel(ahAxes{p}, 'K [m]');
            line(x, this.K, ...
                'color', 'b', ...
                'Parent', ahAxes{p});
            line([x(1) x(end)], [0 0], ...
                'color', [0, 0, 0, .4], ...
                'Parent', ahAxes{p});
            p = p+1;

            ahAxes{p} = subplot(N, 1, p);
            title(ahAxes{p}, 'Hoehenprofil');
            ylabel(ahAxes{p}, 'Hoehe [m]');
            line(x, this.XYZ(:, 3), ...
                'Parent', ahAxes{p});
            p = p+1;

            ahAxes{p} = subplot(N, 1, p);
            title(ahAxes{p}, 'Kruemmung (Hoehe)');
            ylabel(ahAxes{p}, 'K_h [m]');
            line(x, this.K_l, ...
                'color', 'b', ...
                'Parent', ahAxes{p});
            line([x(1) x(end)],[0 0],'color',[0, 0, 0, .4], 'Parent', ahAxes{p});
            p = p+1;

            ahAxes{p} = subplot(N, 1, p);
            title(ahAxes{p}, 'Steigung (Hoehe)');
            ylabel(ahAxes{p}, '\alpha_h [^\circ]');
            line(x, this.alpha_l, ...
                'color', 'b', ...
                'Parent', ahAxes{p});
            line([x(1) x(end)], [0 0], ...
                'color', [0, 0, 0, .4], ...
                'Parent', ahAxes{p});
            p = p+1;

            N = p-1;
            link_array = nan(N, 1);
            for p = 1:N
                grid(ahAxes{p}, 'on');
                ahAxes{p}.Box = 'on';
                link_array(p) = ahAxes{p};
                xlim(ahAxes{p}, [1, inf]);
            end
            linkaxes(link_array, 'x');
        end
        
        function draw(varargin)
            bCourse = false;
            bCurv = false;
            bHeight = false;
            bCurveH = false;
            bSteigung = false;
            for aArgin = varargin
                argin = aArgin{:};
                if isa(argin, 'matlab.graphics.Axes')
                    hAX = argin;
                elseif isa(argin, 'matlab.graphics.Figure')
                    hFigure = argin;
                else
                    switch argin
                        case 'all'
                            bCourse = true;
                            bCurv = true;
                            bHeight = true;
                            bCurveH = true;
                            bSteigung = true;
                        case 'course'
                            bCourse = true;
                        case 'curvature'
                            bCurv = true;
                        case 'height'
                            bHeight = true;
                        case 'hcurvature'
                            bCurveH = true;
                        case 'steigung'
                            bSteigung = true;
                    end
                end 
            end
            
            if isempty(hAX)
                if isempty(hFigure)
                    hAX = axes;
                else
                    hAX = axes(hFigure);
                end
            end
            if bCourse
               line(hAX, this.XYZ(:, 1), this.XYZ(:, 2), this.XYZ(:, 3), 'LineStyle', '--', 'Marker', 'o');
            elseif bCurv
                line(hAX, this.L, this.K);
            elseif bHeight
                line(hAX, this.L, this.XYZ(:,3));
            elseif bCurveH
                line(hAX, this.L, gradient(this.XYZ(:,3)));
            elseif bSteigung
                %
            end
        end
    end
    
    methods (Static)
        function [aK] = Curvature(aX, aY)
            xf = fft(aX);
            yf = fft(aY);
            
            nx = length(xf);
            hx = ceil(nx/2) - 1;
            ftdiff = (2i*pi/nx)*(0:hx);
            ftdiff(nx:-1:nx-hx+1) = -ftdiff(2:hx+1);
            ftddiff = (-(2i*pi/nx)^2)*(0:hx);
            ftddiff(nx:-1:nx-hx+1) = ftddiff(2:hx+1);
            
            dx = real(ifft(xf.*ftdiff'));
            dy = real(ifft(yf.*ftdiff'));
            ddx = real(ifft(xf.*ftddiff'));
            ddy = real(ifft(yf.*ftddiff'));
            
            aK = sqrt((ddy.*dx - ddx.*dy).^2) ./ ((dx.^2 + dy.^2).^(3/2));
        end
    end
end