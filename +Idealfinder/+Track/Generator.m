classdef Generator < handle
    %GENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        R
        L
        XY
        MP
        output = false;
    end
    
    methods
        function [this] = Generator(R, L)
            if nargin == 0
                input = inputdlg({'Radien', 'Laenge'}, '');
                if ~isempty(input)
                    R = str2double(strsplit(input{1}, ','));
                    L = str2double(strsplit(input{2}, ','));
                end
%             else
%                 R = [ 0, 60,  0, -50, 20,  0, -30];
%                 L = [10, 30, 20,  20, 20, 10,  30];
            end
            R(arrayfun(@(r) sign(r) == 0, R)) = 5000; %Inf;
            this.R = R;
            this.L = L;
            this.Calc;
        end
        
        function Calc(this)
            this.XY(1, :) = [0, 0];
            
            if this.output
                hAx = axes;
                hLine = animatedline(hAx);
                axis(hAx, 'equal');
                addpoints(hLine, this.XY(1,1), this.XY(1,2));
            end
            
            arcEnd = 0;
            lastRadius = Inf;
            bFirst = true;
            for aRL = [this.R; this.L]
                curRadius = aRL(1);
                curLength = aRL(2);
                if ~bFirst
                    if lastRadius ~= Inf
                        aMPN = (this.MP(end,:)-this.XY(end,:))/lastRadius;
                        vDirection = aMPN;
                    end
                    this.MP(end+1,:) = this.XY(end,:) + vDirection*curRadius;
                else
                    this.MP(end+1,:) = [-curRadius, 0];
                    vDirection = [-1,0];
                    bFirst = false;
                end
                
                arcTemp = arcEnd + (90 - 90*sign(curRadius)*sign(lastRadius));
                arcStart = mod(arcTemp, 360);    
                nElements = floor(curLength);
                if curRadius == Inf
                    alpha = 0;
                    aTemp = zeros(nElements,2);
                    aTemp(:,1) = (1:nElements)';
                    aTemp = Idealfinder.Lib.Rotate(aTemp, arcStart+90) + this.XY(end,:);
                else                        
                    alpha = curLength*180/(curRadius*pi);
                    t = linspace(arcStart, arcStart+alpha, nElements)';
                    aTemp = abs(curRadius)*[cosd(t), sind(t)] + this.MP(end,:);
                    aTemp(1,:) = [];% remove first value; same value already exist
                end
                if this.output
                    for aT = aTemp'
                        addpoints(hLine, aT(1), aT(2));
                        pause(0.1);
                    end
                end
                this.XY = [this.XY; aTemp];
                
                arcEnd = arcStart + alpha;
                lastRadius = curRadius;
            end
        end
        
        function plot(this)
            this.Clear;
            this.Calc;
            plot(this.XY(:, 1), this.XY(:, 2), 'x-')
            hold on
            axis('equal')
            plot(this.MP(:, 1), this.MP(:, 2), 'o')
        end
        
        function Clear(this)
            this.XY = [];
            this.MP = [];
        end
    end
end
