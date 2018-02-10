% (prepareCourse)
try
    Coords = prepareCourse( Coords , settings.dmode ); %'dmode=true');
catch
    disp('Keine Strecke vorhanden!');
end