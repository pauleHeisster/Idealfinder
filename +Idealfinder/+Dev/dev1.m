% (Testscript)
disp('Testing: getPosition() & findPosition()');

if ~isfield(Coords, 'Sectors') || ~isfield(Coords, 'Rand')
    Coords = prepareCourse( Coords );
end

Current = [];
arr = findobj('Tag', 'curSpeed');
if isempty(arr)
    disp('aktuelle Position nicht gefunden!');
else
    %% Erzeugt den struct ''Current'' für die aktuelle Position
    Current.pos = [arr.XData(1) , arr.YData(1)];
    Current.dpos = [arr.XData(2) - arr.XData(1) , arr.YData(2) - arr.YData(1)];
    Current.speed = norm(Current.dpos);

    [l_scale , q_scale] = getPosition( Coords , Current.pos , settings.dmode );

    if ~isempty(Current)
        [ X ,Y ] = findPosition( Coords , [l_scale , q_scale] , settings.dmode);
        line(X,Y,'Marker','o','color','b','Parent',handles.h_mainaxes,'Tag','dmode');

        {
        '' , 'X-Coord' , 'Y-Coord' ;...
        'echte Coords: ' , Current.pos(1) , Current.pos(2) ;...
        'ermittelt Coords: ' , X , Y ;
        }
    end
end