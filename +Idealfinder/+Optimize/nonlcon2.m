function [c, ceq] = nonlcon2(x, oHorizont, oVehicle)
    c = [];
    ceq = [];

    n = size(x, 1);
    oIdeal = oHorizont.getPathforOptimization(x(:, 1));
    oIdeal = Idealfinder.Path(oIdeal.XYZ);
    MP1 = oHorizont.MP_v(1,:);
    MP2 = oIdeal.MP_v(1,:);
    c(end+1, 1) = acosd( dot(MP1, MP2)/(norm(MP1)*norm(MP2)) )-oVehicle.o;
    
    if true
        switch size(x, 2)
            case 1
                [v, t, al] = oVehicle.getSpeed(oIdeal);
            case 2
                % SpeedInfo bereits in x enthalten
                v = x(:, 2);
        end
        aq = abs(oIdeal.K).*v.^2;
        al = al';

        almax = oVehicle.a.l_faktor*10;
        aqmax = oVehicle.a.q_faktor*10;
        c(end+1:end+n, 1) = sqrt((al/almax).^2+(aq/aqmax).^2)-1;
    else
        c = oIdeal.L-2;
    end
end