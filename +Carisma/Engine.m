classdef Engine < handle
    %ENGINE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        nCylinder = 4;
        displacement = 1600;
        nMin = 650;
        nMax = 7000;
        torque
        eType = Carisma.EngineType.OTTO;
    end
    
    methods
        function [this] = Engine()
            this.torque = [[700, 1000, 1400, 2000, 2500, 3000, 4000, 5000, 5500, 6000, 6500]',...
                           [ 50,   70,  120,  160,  220,  220,  220,  210,  190,  160,  130]'];
        end
        
        function [this] = set.torque(this, torque)
            this.torque = torque;
        end
        
        function showTorque(this, varargin)
            abAxis = cellfun(@(argin) isa(argin, 'matlab.graphics.axis.Axes'), varargin);
            if any(abAxis)
                hAX = varargin{abAxis};
            else
                hAX = axes;
            end
            line(this.torque(:, 1), this.torque(:, 2), 'Parent', hAX);
        end
        
        function [maxTorque] = maxTorque(this)
            maxTorque = max(this.torque);
        end
        
        function showPower(this, varargin)
            abAxis = cellfun(@(argin) isa(argin, 'matlab.graphics.axis.Axes'), varargin);
            if any(abAxis)
                hAX = varargin{abAxis};
            else
                hAX = axes;
            end
            aPower = this.getPower;
            line(this.torque(:, 1), aPower, 'Parent', hAX);
        end
        
        function [maxPower] = maxPower(this)
            aPower = this.getPower;
            maxPower = max(power);
        end
        
        function [aPower] = getPower(this)
            aPower = this.torque(:, 1).*this.torque(:, 2)*2*pi/60/1000;
        end
    end
    
end
