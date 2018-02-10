% (Streckenparameter)
function dev2()
    disp('Uebersicht der erkannten Kurvensektoren');
    global oCourse oIdeal oHorizont
    
    try
        oCourse.overview
    catch
        warning('Strecke nicht verfügbar!')
    end

    try
        oIdeal.overview
        oHorizont.overview
    catch
        disp('keine Ideallinie vorhanden!');
    end
end