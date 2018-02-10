function [ l_scale , q_scale ] = getPosition( Coords , pos , varargin)
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

%% aktuelle Position auf der Strecke bestimmen
    
% Streckeninformationen
X = Coords.XYZ(:,1);
Y = Coords.XYZ(:,2);
B = Coords.B;

Xc = pos(1); Yc = pos(2);
%% Abstände von Xc,Yc
rs = (X-Xc).^2 + (Y-Yc).^2;
n = length(rs);

m = min(rs(:,1));
id = find(rs(:,1)==m);
% rs(id,1) = max(rs(:,1)); % falls Mehrere gesucht werden

if id > 1
    id(end+1) = id(1)-1;
end
if id < n
    id(end+1) = id(1)+1;
end
id = sort(id);

n = length(id);
S = zeros(n,6); % Sektorenstützpunkt
MP_S = zeros(n,2); % Mittelpunkt -- Sektorstützpunkt
gMP = zeros(n-1,2); % gemeinsame Mittelpunkte

for ii = 1 : n
    S(ii,:) = [X(id(ii)) , Y(id(ii)) , Coords.MP_v(id(ii),:) , B(id(ii)) , Coords.nL(id(ii))];
    nL(ii) = Coords.nL(id(ii));
    MP_S(ii,:) = [ S(ii,1)-S(ii,3) , S(ii,2)-S(ii,4) ]; 
    if ii > 1
        i = ii-1;
        % gemeinsamer Mittelpunkt (gMP)
        Pi1 = S(i,1:2);
        Pi2 = S(i,1:2) + S(i,3:4);
        Pii1 = S(ii,1:2);
        Pii2 = S(ii,1:2) + S(ii,3:4);
        gMP(i,:) = schnittpkt( Pi1 , Pi2 , Pii1 , Pii2);

        MP_S1 = S(i,1:2) - gMP(i,:); % MP -- S1
        MP_S2 = S(ii,1:2) - gMP(i,:); % MP -- S2
        MP_C = [Xc , Yc] - gMP(i,:); % MP -- C
        alpha_mps1_mps2 = acosd( dot(MP_S1,MP_S2)/(norm(MP_S1)*norm(MP_S2)) ); % Öffnungswinkel des Sektors
        % cross([MP_S1,0],[MP_S2,0]);
        alpha_mps1_mpc = acosd( dot(MP_S1,MP_C)/(norm(MP_S1)*norm(MP_C)) ); % Winkel zwischen Sektoreingang und Current
        if alpha_mps1_mpc < alpha_mps1_mps2
            try
                S(ii+1,:) = [];
                gMP(ii,:) = [];
            catch
                S(i-1,:) = [];
                gMP(i,:) = [];
            end
            break
        end
    end
end

% Richtungsvektor im Sektor
S1_S2 = [ S(2,1) - S(1,1) , S(2,2) - S(1,2) ];
[~,x] = schnittpkt(S(1,1:2),S(2,1:2),gMP(:),[Xc,Yc]);

% t =[0..1] ist der Positionsfaktor für D ((Xt,Yt)=t*D+(Xs,Ys))
t = x(1);
l_scale = (S(2,end)-S(1,end))*t+S(1,end);

SP_l = S1_S2*t+S(1,1:2); % Stützpunkt auf der Mitte

%% Vorzeichenermittlung
SP_C = [ Xc , Yc ] - SP_l; % SP -- Current
vorz = cross([S1_S2,0],[SP_C,0]);
vorz = sign(vorz(3));
bS = ((S(2,5) - S(1,5)) * t + S(1,5))/2;

%% Vorzeichen nochmal überdenken
q_scale = norm([ Xc-SP_l(1) , Yc-SP_l(2) ])/bS * vorz * (-1);

if dmode        
    line(gMP(1),gMP(2),'Marker','x','color','k','Tag','dmode');
    col={'g','r'};
    for ii = 1 : 2
        line([gMP(1),S(ii,1)],[gMP(2),S(ii,2)],'LineWidth',1,'color',col{ii},'Tag','dmode');
    end
    line([gMP(1),SP_l(1)],[gMP(2),SP_l(2)],'LineWidth',1,'color','k','Tag','dmode');
    line(SP_l(1),SP_l(2),'Marker','o','color','k','Tag','dmode');        
    arrow([SP_l(1),Xc],[SP_l(2),Yc]);
end