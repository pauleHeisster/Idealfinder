function [nFunVal, nGradient, anHesse] = optimize(x, oCourse, initial, oVehicle)
    % Objective-Function for Optimization
    nFunVal = []; % Funktionswert
    nGradient = []; % Gradient
    anHesse = []; % Hesse-Matrix
    w = []; % Wichtungsvektor
    cols = size(x, 2);

    n = size(x, 1);
    oIdeal = oCourse.getPathforOptimization(x(:,1));
    oIdeal = Idealfinder.Path(oIdeal.XYZ);
    switch cols
        case 1
            oVehicle.oPath = oIdeal;
            [v, t, ~, v_grenz] = oVehicle.getSpeed();
        case 2
            v = x(:,2);
    end
    astrFieldnames = fieldnames(initial);
    for strFieldname = astrFieldnames'
        strFieldname = strFieldname{:}; %#ok<FXSET>
        switch strFieldname
            case 'L'
                scale = initial.(strFieldname).value;
                w(end+1) = initial.(strFieldname).w;
                nFunVal(end+1) = sum(oIdeal.L)/scale * w(end);
            case 'T'
                switch cols
                    case 1
                        T = t;
                    otherwise
                        T = zeros(n,1);
                        T(2:n) = 2*oIdeal.L(2:n)./(v(1:n-1)+v(2:n));
                end
                scale = initial.(strFieldname).value;
                w(end+1) = initial.(strFieldname).w;
                nFunVal(end+1) = sum(T)/scale * w(end);
            case 'V'
                scale = initial.(strFieldname).value;
                w(end+1) = initial.(strFieldname).w;
                nFunVal(end+1) = scale/sum(v) * w(end);
            case 'K'
                scale = initial.(strFieldname).value;
                w(end+1) = initial.(strFieldname).w;
                nFunVal(end+1) = sum(abs(oIdeal.K))/scale * w(end);
            case 'dV'
                dV = v_grenz-v;
                scale = initial.(strFieldname).value;
                w(end+1) = initial.(strFieldname).w;
                nFunVal(end+1) = sum(dV)/scale * w(end);
            case 'a_qmin'
                a_q = abs(oIdeal.K).*v.^2;
                scale = initial.(strFieldname).value;
                w(end+1) = initial.(strFieldname).w;
                nFunVal(end+1) = sum(a_q)/scale * w(end);
        end
    end
    nFunVal = sum(nFunVal)/sum(w);
end