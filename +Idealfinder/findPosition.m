function [ varargout ] = findPosition( Coords , soll , varargin)
dmode = false;
for i = 1:length(varargin)
argument = strsplit(varargin{i},'=');
    switch lower(argument{1})
        case 'dmode'
            try
                if isequal(argument{2},'true')
                    dmode = true;
                end
            end
        otherwise
            error([mfilename ':unrecognized_input','Unrecognized argument "%s"'],varargin{i});
    end
end
%%

% Indizes der Streckenelemente
l_scale = soll(1);
q_scale = soll(2);

switch l_scale
    case 0
        min_i = 1;
        max_i = 2;
    case 1
        max_i = length(Coords.XYZ);
        min_i = max_i-1;
    otherwise
        min_i = find(Coords.nL(:) <  l_scale,1,'last');
        max_i = find(Coords.nL(:) >= l_scale,1,'first');
end

if nargout == 1
    varargout{1} = max_i;
    return
else
    varargout{3} = max_i;
    varargout{4} = min_i;
end

v = [ Coords.XYZ(min_i,1) , Coords.XYZ(min_i,2) , Coords.MP_v(min_i,:) , Coords.B(min_i) , Coords.nL(min_i,:) ];
b = [ Coords.XYZ(max_i,1) , Coords.XYZ(max_i,2) , Coords.MP_v(max_i,:) , Coords.B(max_i) , Coords.nL(max_i,:) ];

% Richtungsvektor des Sektors
v_b = [b(1) - v(1) , b(2) - v(2)];

l_intervall = (l_scale-v(end)) / (b(end)-v(end));
bL = ((b(5) - v(5)) * l_intervall + v(5))/2;

% Stützpunkt in Längsrichtung
SP_l = v(1:2) + v_b * l_intervall;

% Schnittpunktberechnung (gemeinsamer Mittelpunkt)
MP = schnittpkt(v(1:2),v(1:2)+v(3:4),b(1:2),b(1:2)+b(3:4));
if isnan(MP(1)) || isnan(MP(2)) || isinf(MP(1)) || isinf(MP(2))
    Q = [v_b(2) , -v_b(1)]/norm(v_b) * bL;
else
    % Verbindung Stützpunkt mit Mittelpunkt & Normierung   
    SP_MP = [MP(1) - SP_l(1) , MP(2) - SP_l(2)];
    vorz = cross([v_b,0],[SP_MP,0]) * (-1);
    Q = SP_MP/norm(SP_MP) * bL * sign(vorz(3));
end
P = SP_l + Q * q_scale; % tatsächliche Koordinate

if dmode  
    % Markierung Sektor & Stützpunkt
    line(v(1),v(2),'Marker','x','Tag','dmode');
    line(b(1),b(2),'Marker','x','Tag','dmode');
    line(SP_l(1),SP_l(2),'Marker','o','Tag','dmode');

    % Markierung Mittelpunkt
    line(MP(1),MP(2),'Marker','o','Tag','dmode');
    line([SP_l(1),MP(1)],[SP_l(2),MP(2)],'Tag','dmode');
  
    % mögliche Bereiche (Querrichtung)
    pL =-Q + SP_l;
    pR = Q + SP_l;
    arrow([SP_l(1),pL(1)],[SP_l(2),pL(2)],gca,'r');
    arrow([SP_l(1),pR(1)],[SP_l(2),pR(2)],gca,'g');
    
    % tatsächlicher Punkt
    line(P(1),P(2),'Marker','x');
end

varargout{1}=P(1);varargout{2}=P(2);
end