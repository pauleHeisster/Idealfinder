% (getSpeed - Mittellinie)
function dev5
    global oVehicle oCourse
    disp('ermittelt Grenzgeschwindigkeit anhand der Streckendaten');

    oVehicle.oPath = Idealfinder.Path(oCourse.XYZ);
    if exist('SpeedView', 'file')
        SpeedView(true);
    end
end