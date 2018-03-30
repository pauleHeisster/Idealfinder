function [y] = movingAverage(x, w, strShape)
   k = ones(1, w)/w;
   y = conv(x, k, strShape);
end