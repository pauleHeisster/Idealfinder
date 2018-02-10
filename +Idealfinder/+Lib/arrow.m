function [arr] = arrow(x,y,haxes,farbe,dicke)
switch nargin
    case 2
        haxes=gca;
        n=haxes.ColorOrderIndex;
        n=n+1;
        if n > 7
            n=1;    
        end
        haxes.ColorOrderIndex=n;
        farbe = haxes.ColorOrder(n,:);
        dicke = 1;
    case 3
        n=haxes.ColorOrderIndex;
        n=n+1;
        if n > 7
            n=1;    
        end
        haxes.ColorOrderIndex=n;
        farbe = haxes.ColorOrder(n,:);
        dicke = 1;
    case 4
        dicke = 1;
    case 5
    otherwise
        arr = [];
        return;
end
alpha=5;
wert=.7;
D=[x(2)-x(1);...
   y(2)-y(1)];

dm1=[cosd(alpha) sind(alpha);...
    -sind(alpha) cosd(alpha)];
dm2=[cosd(-alpha) sind(-alpha);...
    -sind(-alpha) cosd(-alpha)];
A1=dm1*D*wert;
A1(1)=A1(1)+x(1);A1(2)=A1(2)+y(1);
A2=dm2*D*wert;
A2(1)=A2(1)+x(1);A2(2)=A2(2)+y(1);
X=[x(1) x(2) A1(1) A2(1) x(2) x(1)];
Y=[y(1) y(2) A1(2) A2(2) y(2) y(1)];
arr = line(X,Y,'color',farbe,'Parent',haxes,'Linewidth',dicke,'Tag','arrow');
end