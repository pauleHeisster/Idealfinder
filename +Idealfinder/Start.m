clear all -force %#ok
clc
global oMainDialog oVehicle oCourse

oMainDialog = Idealfinder.MainDialog();
oVehicle = Carisma.Vehicle();

oMainDialog.hFigure.WindowStyle = 'docked';