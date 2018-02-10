classdef Editor
	properties
	    hFigure
	    hMainAx
	    hHeightAx
	end

	methods
		function [this] = Editor()
			this.hFigure = figure;
			this.hMainAx = axes(this.hFigure ...
				, 'Units', 'normal' ...
				, 'Position', [0, 0.2, 1, 1-0.2] ...
				);
			this.hHeightAx = axes(this.hFigure ...
				, 'Units', 'normal' ...
				, 'Position', [0, 0, 1, 0.2] ...
				);
		end
        
        function ShowData(this, oPath)
            oPath.drawPath(this.hMainAx);
            oPath.draw(this.hHeightAx, 'height');
        end
	end
end
