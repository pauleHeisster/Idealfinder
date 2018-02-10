function [nR, nX, nY] = radi(x, y)
    % siehe arndt-brunner.de (kreis3p.htm)
    a = -(x.^2 + y.^2);
    A = [ones(size(x)), -x, -y];
    B = A\a;

    nX = B(2)/2;
    nY = B(3)/2;

    v = [x,y zeros(size(x))]-[nX, nY, 0];
    % orient = v1(1) * v2(2) - v1(2) * v2(1) ;
    orient = cross(v(1, :), v(3, :));
    orient = orient(3);

    vorz = sign(orient);
    if isnan(vorz)
        vorz = -1;
    end

    nR = norm(v(2, :))*vorz*(-1);
end
