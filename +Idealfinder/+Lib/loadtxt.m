function [lat, lng, z] = loadtxt(fileName, varargin)
delimeter = ',';
hdlines = 1;
formatSpec = '%*s %f %f %f %*[^\n]';

fileID = fopen(fileName, 'r');

C_data = textscan(fileID, formatSpec, 'Delimiter', delimeter, 'HeaderLines', hdlines);

fclose(fileID);

lat = C_data{1,1};
lng = C_data{1,2};
z = C_data{1,3};
end