function [bStop] = outfun(x, oStrecke, oVehicle, varargin)
    bSpeedVec = false;
    for aArgin = varargin
        switch aArgin{:}
            case 'SpeedVec'
                bSpeedVec = true;
            otherwise
                error([mfilename ':unrecognized_input'], 'Unrecognized argument "%s"', aArgin{:});
        end
    end
    %%

    bStop = false;
    tagname = 'optim_item';
    hMainAxes = findobj('Tag', 'Hauptachse');
    if ~isempty(hMainAxes)
        delete(findobj('Tag', tagname));

        n = length(x);
        oIdeal = oStrecke.getPathforOptimization(x(:, 1));
        oIdeal = Idealfinder.Path(oIdeal.XYZ);
        X = oIdeal.XYZ(:, 1);
        Y = oIdeal.XYZ(:, 2);
        % zeichnet Ideallinie für jeden Schritt
        line(hMainAxes, X, Y, 'Tag', tagname, 'Marker', '.', 'MarkerSize', 10);
        if bSpeedVec
            switch size(x, 2)
                case 1
                    oVehicle.oPath = oIdeal;
                    v = oVehicle.getSpeed();
                case 2
                    v = x(:, 2);
            end
            for i = 1:n
                D = Idealfinder.Lib.Rotate(oIdeal.MP_v(i,:), 90)*v(i);%[-oIdeal.MP_v(i,2) , oIdeal.MP_v(i,1)]*v(i);
                V = oIdeal.XYZ(i, 1:2) + D;
                % zeichnet Geschwindigkeitsvektor
                line(hMainAxes, [X(i), V(1)], [Y(i), V(2)], 'Tag', tagname, 'color', 'r');
            end
        end
    end
end