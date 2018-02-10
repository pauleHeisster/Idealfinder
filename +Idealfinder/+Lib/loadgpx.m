function [route] = loadgpx(strFileName, varargin)
% LOADGPX Loads route points from a GPS interchange file
% ROUTE = LOADGPX(FILENAME) Loads route point information from a .GPX
%   GPS interchange file.  This utility is not a general-purpose
%   implementation of GPX reading and is intended mostly for reading the
%   files output by the "gmap pedometer" tool.  
% 
% ROUTE is a Nx6 array where each row is a route point.
%   Columns 1-3 are the X, Y, and Z coordinates.
%   Columns 4-5 are latitude and longitude
%   Column  6 is cumulative route length.
%
% Note that the mapping of latitude/longitude assumes an approximate spherical
% transformation to rectangular coordinates.  
%
% Additional property/value arguments:
%   LOADGPX(...,'ElevationUnits','meters',...) uses meters for elevation
%   LOADGPX(...,'Viz',true,...) displays the route and elevation map
%
%   For more information on the gmap pedometer and GPX output:
%     http://www.gmap-pedometer.com/
%     http://www.elsewhere.org/journal/gmaptogpx/
%
% See also xmlread

%Column identifiers
% COL_X   = 1;
% COL_Y   = 2;
% COL_Z   = 3; 
% COL_LAT = 4;
% COL_LNG = 5;
% COL_DST = 6;
% COL_B   = 7;

COL.X   = 1;
COL.Y   = 2;
COL.Z   = 3;
COL.LAT = 4;
COL.LNG = 5;
COL.DST = 6;
COL.B   = 7;

elevationUnits = 'meters';
bViz = false;
for i = 1:2:length(varargin)-1
    switch lower(varargin{i})
        case 'elevationunits'
            elevationUnits = varargin{i+1};
        case 'viz'
            bViz = varargin{i+1};
        otherwise
            error('loadgpx:unrecognized_input', 'Unrecognized argument "%s"', ...
                varargin{i});
    end
end

d = xmlread(strFileName);

if ~strcmp(d.getDocumentElement.getTagName, 'gpx')
    warning('loadgpx:formaterror','file is not in GPX format');
end

ptList = d.getElementsByTagName('trkpt');% 'rtept');
ptCt = ptList.getLength;

route = nan(ptCt, 5);
for i = 1:ptCt
    pt = ptList.item(i-1);
    try
        route(i,COL.LAT) = str2double(pt.getAttribute('lat'));
    catch
        warning('loadgpx:bad_latitude', 'Malformed latitutude in point %i.  (%s)', i, lasterr);
    end
    try
        route(i,COL.LNG) = str2double(pt.getAttribute('lon'));
    catch
        warning('loadgpx:bad_longitude', 'Malformed longitude in point %i.  (%s)', i, lasterr);
    end
    
    ele = pt.getElementsByTagName('ele');
    if ele.getLength > 0
        try
            route(i,COL.Z) = str2double(ele.item(0).getTextContent);
        catch
            warning('loadgpx:bad_elevation', 'Malformed elevation in point %i.  (%s)', i, lasterr);
        end
    end
end

route(:, [COL.Y, COL.X]) = route(:, [COL.LAT, COL.LNG]) - ones(ptCt, 1)*route(1, COL.LAT:COL.LNG);

lat_mean=mean(route(:,COL.LAT));
switch elevationUnits
    case 'feet' 
        MILES_PER_ARCMINUTE = 1.15; 
        distMult = 1/5280; %5280 feets = 1 Mile
        route(:, COL.X:COL.Y) = MILES_PER_ARCMINUTE*1/distMult*60*route(:, COL.X:COL.Y); 
        route(:, COL.X) = route(:, COL.X)*cos(lat_mean/180*pi); % correction de latitude
    case 'meters' 
        KM_PER_ARCMINUTE = 1.852; 
        distMult = 1/1000;
        route(:, COL.X:COL.Y) = KM_PER_ARCMINUTE*1/distMult*60*route(:, COL.X:COL.Y); 
        route(:, COL.X) = route(:, COL.X)*cos(lat_mean/180*pi); 
end

if bViz
    %cumulative distance - calculate including the elevation hypotenuse
    route(1, COL.DST) = 0;
    route(2:end, COL.DST) = sqrt(sum((route(1:end-1, COL.X:COL.Z)-route(2:end, COL.X:COL.Z)).^2, 2));
    route(:, COL.DST) = cumsum(route(:, COL.DST));
    
    %calculate total elevation gain
    deltaZ = route(2:end, COL.Z)-route(1:end-1, COL.Z);
    deltaZ = sum(deltaZ(deltaZ > 0));
    
    minZ = min(route(:, COL.Z));
    
    clf
    set(gcf ...
        , 'color', 'white' ...
        , 'name', sprintf('loadgpx - %s', strFileName) ...
        );
    ax2 = axes( ...
          'outerposition', [0 0 1 .3] ...
        , 'nextplot', 'add' ...
        );
    plot(distMult*route(:, COL.DST), route(:,COL.Z),...
          'k-' ...
        , 'linewidth', 2 ...
        , 'parent', ax2 ...
        );
    area(distMult*route(:, COL.DST), route(:, COL.Z) ...
        , 'parent', ax2 ...
        );
    
    set(ax2 ...
        , 'box', 'on' ...
        , 'color', 'none' ...
        , 'xtickmode', 'auto' ...
        , 'ylim', [0.9*minZ, 1.1*max(route(:, COL.Z))] ...
        , 'xlim', distMult*[min(route(:, COL.DST)) max(route(:, COL.DST))] ...
        );
    ylabel(elevationUnits);
    title(sprintf('cumulative elevation gain = %i %s', round(deltaZ), elevationUnits));
    
    ax2 = axes( ...
          'outerposition', [0 0.3 1 0.7] ...
        , 'nextplot', 'add' ...
        );
    
    
    plot3(distMult*route(:, 1), distMult*route(:, 2), route(:, 3) ...
        , 'k-' ...
        , 'linewidth', 2 ...
        );
    
    hr = trisurf( ...
          [
            [(1:ptCt-1)', (2:ptCt)', (ptCt+1:ptCt+ptCt-1)']
            [(ptCt+1:ptCt+ptCt-1)', 1+(ptCt+1:ptCt+ptCt-1)', (2:ptCt)']
          ] ...
        , distMult*[
            route(:, COL.X)
            route(:, COL.X)
          ] ...
        , distMult*[
            route(:, COL.Y)
            route(:, COL.Y)
          ] ...
        , [
            route(:, COL.Z)
            minZ*ones(size(route(:, COL.Z)))
          ] ...
        , 'facecolor', 'b' ...
        , 'edgecolor', 'none' ...
        , 'facealpha', 0.8 ...
        );
    
    deltaXYZ = max(route(:, COL.X:COL.Z))-min(route(:, COL.X:COL.Z));
    
    set(ax2 ...
        , 'box', 'on' ...
        , 'dataaspectratio', [1 1 2*deltaXYZ(3)/(distMult*max(deltaXYZ(1:2)))] ...
        );
    axis(ax2, 'tight');
end