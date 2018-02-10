[file,path] = uigetfile('*Idealfinder*.fig','Figure auswählen','');
openfig([path file]);
handles.h_mainfig = gcf;handles.h_mainaxes = gca;