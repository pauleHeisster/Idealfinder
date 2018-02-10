function [x, y] = simple(lat, lng)
    % Strecke in Ursprung (0,0) verschieben
    lat = lat-lat(1);
    lng = lng-lng(1);
    elevationUnits = 'meters';
    switch elevationUnits
        case 'feet' 
            PER_ARCMINUTE = 1.15; 
            distMult = 1/5280; %5280 feets = 1 Mile 
        case 'meters' 
            PER_ARCMINUTE = 1.852; 
            distMult = 1/1000;
    end

    x = lng*60*PER_ARCMINUTE*1/distMult;
    y = lat*60*PER_ARCMINUTE*1/distMult;

    lat_mean = mean(lat);
    x = x*cos(lat_mean/180*pi); % correction: latitude
end