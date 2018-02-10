function [bogenl] = bogen(fun, varargin)
    syms x
    dfun = diff(fun, x);
    %intfun = matlabFunction(int(dfun, x));
    intfun = matlabFunction(sqrt(dfun.^2));
    bogenl = integral(intfun, varargin{:});
end