classdef Gearbox
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        type = 'automatic';
        ratios
    end
    
    methods
        function [this] = Gearbox()
            this.ratios = [4, 2.0, 1.8, 1.4, 1.1, 0.8]';
        end
        
        function [aRatios] = getRatios(this, arg)
            assert(ischar(arg), 'invalid Input!');
            switch arg
                case 'forward'
                    aRatios = this.ratios(this.ratios > 0);
                case 'reverse'
                    aRatios = this.ratios(this.ratios < 0);
            end
        end
        
        function showRatios(this, varargin)
            abAxis = cellfun(@(argin) isa(argin, 'matlab.graphics.axis.Axes'), varargin);
            if any(abAxis)
                hAX = varargin{abAxis};
            else
                hAX = axes;
            end
            n_min = 600;
            n_max = 6500;
            for i = 1:length(varargin)
                arg = varargin{i};
                switch class(arg)
                    case 'double'
                        if length(arg)>1
                            n_min = arg(1);
                            n_max = arg(2);
                        else
                            n_min = arg(1);
                        end
                end
            end
            
            x = [n_min, n_max];
            aRatios = this.getRatios('forward');
            for nRatio = reshape(aRatios, 1, [])
                line(x/nRatio, x, 'Parent', hAX);
            end
            xlim = hAX.XLim;
            line([xlim(1), xlim(2)], [n_min, n_min], 'color', 'black', 'LineStyle', '--', 'Parent', hAX);
            line([xlim(1), xlim(2)], [n_max, n_max], 'color', 'black', 'LineStyle', '--', 'Parent', hAX);
        end        
    end    
end

