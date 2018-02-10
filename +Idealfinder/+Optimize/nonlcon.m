function [c, ceq] = nonlcon(x, oHorizont, oVehicle)
    c = [];
    ceq = [];

    aqmax = oVehicle.a.qmax;
    almax = oVehicle.a.lmax;

    n = size(x,1);
    oIdeal = oHorizont.getPathforOptimization(x(:, 1));
    oIdeal = Idealfinder.Path(oIdeal.XYZ);
end