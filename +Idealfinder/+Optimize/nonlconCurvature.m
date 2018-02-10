function [ c , ceq ] = nonlconCurvature(x,Strecke,wheeler)
c = [];
ceq = [];
if 1
    n = length(x);
    dK = zeros(n,1);
    c = zeros(n,1);
    Ideal = getPathforOptimization(Strecke,x);
    Ideal = prepareCourse(Ideal);
    [~,~,a] = getSpeed(Ideal,wheeler);

    for i = 2:n
        dK(i) = (Ideal.K(i)-Ideal.K(i-1))/Ideal.L(i);
        c(i) = abs(dK(i)) - abs(a(i));
    end
    %c = dK - ones(n,1)*0.0001;
end
% c(i) = X(i)-1;
end