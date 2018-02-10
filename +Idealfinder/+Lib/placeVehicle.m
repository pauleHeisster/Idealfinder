function placeVehicle(hObject, eventdata)
tagname = 'curSpeed';

vehicle = findobj('Tag', tagname);

switch eventdata.Button
    case 1
    if isempty(vehicle)
        coord = get(hObject, 'CurrentPoint');
        hObject.UserData{end+1, 1} = coord(1, 1);
        hObject.UserData{end, 2} = coord(1, 2);
        if size(hObject.UserData,1) >= 2
            x = [hObject.UserData{end-1:end, 1}];
            y = [hObject.UserData{end-1:end, 2}];
            vehicle = arrow(x, y, hObject, 'b', 2);
            vehicle.Tag = tagname;
            % evalin('base','wheeler.X = ...');
        end
    end
    case 2
    if ~isempty(vehicle)
        delete(vehicle);
        hObject.UserData = {};
        % evalin('base', 'wheeler.X = []; wheeler.Y = []; wheeler.v = [];');
    end
end
end
