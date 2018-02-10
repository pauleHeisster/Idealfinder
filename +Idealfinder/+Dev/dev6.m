% (saveOpenFigures)
addpath(fullfile(pwd, 'Auswertungen'));
box off;
delete(handles.h_mainaxes.Children(1:end-3));
optimGUI;
close(hoptimGUI.figure);
line(Ideal.XYZ(:,1), Ideal.XYZ(:,2), 'color', 'r', 'LineWidth', 2);
saveOpenFigures