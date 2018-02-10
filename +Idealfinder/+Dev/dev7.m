% (StreckenElemente einzeichnen)
function dev7()
    global oMainDialog oCourse
    str = {'Stuetzstellen/Segmente', 'Kruemmung','MP-Vektoren'};
    astrSelection = listdlg('PromptString', 'Darstellungen auswaehlen:' ...
              , 'InitialValue', 1 ...
              , 'ListSize', [200 60] ...
              , 'SelectionMode', 'multiple' ...
              , 'ListString', str);
    for i=1:length(astrSelection)
        switch astrSelection(i)
            case 1
                oCourse.drawSegments(oMainDialog.hMainAxes);
            case 2
                oCourse.drawKruemmung(oMainDialog.hMainAxes);
            case 3
                oCourse.drawOrient(oMainDialog.hMainAxes);
        end
    end
end
