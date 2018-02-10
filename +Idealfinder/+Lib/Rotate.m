function [vec] = Rotate(vec, alpha)
aRot = [cosd(alpha), sind(alpha); ...
       -sind(alpha), cosd(alpha)]; 
vec = vec*aRot;
end