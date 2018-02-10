classdef Course < Idealfinder.Path
    %COURSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        B
        leftBorder
        rightBorder
    end
    
    properties (Dependent)
        LeftBorder
        RightBorder
    end
    
    methods
        function [this] = Course(aXYZ, b)
            this = this@Idealfinder.Path(aXYZ);
            this.B = b;
            n = size(aXYZ,1);
            this.leftBorder = zeros(n,2);
            this.rightBorder = zeros(n,2);
            
            this.leftBorder = aXYZ(:,1:2) + b./2.*this.MP_v;
            this.rightBorder = aXYZ(:,1:2) - b./2.*this.MP_v;
        end
        
        function [aLeftBorder] = get.LeftBorder(this)
            aLeftBorder = this.XYZ(:,1:2) + this.B./2.*this.MP_v;
        end
        
        function [aRightBorder] = get.RightBorder(this)
            aRightBorder = this.XYZ(:,1:2) - this.B./2.*this.MP_v;
        end
        
        function drawBorder(this, AX)
            line(AX, this.leftBorder(:,1), this.leftBorder(:,2), 'color', [0,0,0,.4], 'Tag', 'leftBorder');
            line(AX, this.rightBorder(:,1), this.rightBorder(:,2), 'color', [0,0,0,.4], 'Tag', 'rightBorder');
        end
        
        function drawSegments(this, AX)
            n = size(this.XYZ, 1);
            for j = 1:n
                line(AX,[ this.leftBorder(j,1) , this.rightBorder(j,1) ],[ this.leftBorder(j,2) , this.rightBorder(j,2) ],'color',[0,0,0,.4],'Tag','dmode')
            end
        end
        
        function [oPath] = getPathforOptimization(this, x)
            n = size(x, 1);
            aXY = zeros(n, 2);
            for i = 1:n
                aXY(i,:) = this.findPositionByID(i, x(i));
            end
            oPath = Idealfinder.Path([aXY, this.XYZ(:,3)]);
        end
        
        
        function [aPos] = findPositionByID(this, nIdx, q, varargin)
            dmode = false;
            if isempty(varargin)
                dmode = false;
            elseif isgraphics(varargin{1}, 'Axes')
                AX = varargin{1};
                dmode = true;
            end
            aSP = this.XYZ(nIdx, 1:2);
            br = this.B(nIdx)/2;
            K = this.K;
            if K(nIdx) == 0
                Q = this.MP_v(nIdx, :) * br;
            else
                %% Verbindung Stuetzpunkt mit Mittelpunkt & Normierung
                % MP = self.XYZ(ind,1:2)+self.MP_v(ind,:)/abs(self.K(ind));
                aMP = this.MP(nIdx,:);
                % SP_MP = [MP(1) - SP(1) , MP(2) - SP(2)];
                SP2MP = (aMP-aSP)*sign(K(nIdx));
                Q = SP2MP/norm(SP2MP) * br;
            end
            aPos = aSP + Q * q; % tatsaechliche Koordinate

            if dmode
                %% Stuetzpunkt
                line(AX, aSP(1), aSP(2), 'Marker', 'o', 'Tag', 'dmode');

                %% Markierung Mittelpunkt
                line(AX, aMP(1), aMP(2), 'Marker', 'o', 'Tag', 'dmode');
                % line(Ax,[SP(1),MP(1)],[SP(2),MP(2)],'Tag','dmode');

                %% moegliche Bereiche (Querrichtung)
                pL = aSP - Q;
                pR = aSP + Q;
                arrow([aSP(1), pL(1)], [aSP(2), pL(2)], AX, 'r');
                arrow([aSP(1), pR(1)], [aSP(2), pR(2)], AX, 'g');

                %% tatsaechlicher Punkt
                line(AX, aPos(1), aPos(2), 'Marker', 'x');
            end
        end
    end
end