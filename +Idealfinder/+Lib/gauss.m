function [x,y] = gauss(breite, laenge)
% Gauss-Krüger-Transformation
%--------------------- Konstanten fuer KO-Trafo ---------------------------

% Bo_aschheim = 48.22044382289/180*pi;       % [rad] Ursprung Aschheim
% Lo_aschheim = 11.72514847581/180*pi;
%  
% CONST.Trafo.Bo = Bo_aschheim;
% CONST.Trafo.Lo = Lo_aschheim;
%  
% CONST.Trafo.ae = 6378137;          % Halbachse des WGS-84 Ellipsoids
% CONST.Trafo.be = 6356752.314;      % Halbachse des WGS-84 Ellipsoids

const(1) = breite(1)/180*pi;
const(2) = laenge(1)/180*pi;
const(3) = 6378137;
const(4) = 6356752.314;

Bo = const(1);             
Lo = const(2);
ae = const(3);
be = const(4);
  
 
B = breite/180*pi; 
L = laenge/180*pi; 
 
%------------------- KO Trafo ---------------------------------------------      
%Entwicklungspunkt von Koordinaten abziehen
db = B-Bo;
dl = L-Lo;

%--------------------------------------------------------------------------
ee    = (ae^2-be^2)/ae^2;  
sinbo = sin(Bo);
cosbo = cos(Bo);
t     = sinbo/cosbo;
N     = ae/(sqrt(1-ee*sinbo*sinbo));
uu    = cosbo*cosbo*ee/(1-ee);
%--------------------------------------------------------------------------

a10 = N*(1-uu+uu^2-uu^3); %
a01 = N*cosbo; %
a20 = 3*N*t/2*(uu-2*uu^2); %
a11 = N*cosbo*t*(-1+uu-uu^2+uu^3); %
a02 = N*cosbo^2*t/2; %
a30 = N/2*uu*(1-t^2-2*uu+7*uu*t^2); %
a21 = N*cosbo/2*(-1+uu-3*uu*t^2-uu^2+6*uu^2*t^2); %
a12 = N*cosbo^2/2*(1-t^2+uu*t^2-uu^2*t^2); %
a03 = N*cosbo^3/6*(1-t^2+uu); %
a40 = -N*t/2*uu; %
a31 = N*cosbo*t/6*(1-10*uu+3*uu*t^2); %
a22 = N*cosbo^2*t/4*(-4+3*uu-3*uu*t^2); %
a04 = N*cosbo^4*t/24*(5-t^2+9*uu); %
a13 = N*cosbo^3*t/6*(-5+t^2-4*uu-uu*t^2); %
a41 = N*cosbo/24; %
a32 = N*cosbo^2/3*(-1+t^2); %
a23 = N*cosbo^3/12*(-5+13*t^2); %
a14 = N*cosbo^4/24*(5-18*t^2+t^4); %
a05 = N*cosbo^5/120*(5-18*t^2+t^4); %
a33 = N*cosbo^3/36*t*(41-13*t^2);  %

% A = [ 0  a01 a02 a03 a04 a05;
%      a10 a11 a12 a13 a14  0;
%      a20 a21 a22 a23  0   0;
%      a30 a31 a32 a33  0   0;
%      a40 a41  0   0   0   0 ];
%  
% Dl = [ 0 dl dl.^2 dl.^3 dl.^4 0];
% Db = [ 0 db db.^2 db.^3 db.^4 db.^5];
 
%--- x,y Koordinaten in der Ebene -----------------------------------------

x = a10*db+a20*db.^2+a02*dl.^2+a30*db.^3+a12*db.*dl.^2+a40*db.^4+ ...
    a22*db.^2.*dl.^2+a04*dl.^4+a32*db.^3.*dl.^2+a14*db.*dl.^4;

y = a01*dl+a11*db.*dl+a21*db.^2.*dl+a03*dl.^3+a31*db.^3.*dl+a13*db.*dl.^3+ ...
    a41*db.^4.*dl+a23*db.^2.*dl.^3+a05*dl.^5+a33*db.^3.*dl.^3;

%x,y vertauscht!

%% Ausgabe
h = x;
x = y;
y = h;
%--------------------------------------------------------------------------
end