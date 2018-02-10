function [y] = movingAverage(x ,w ,type)
   k = ones(1, w)/w;
   y = conv(x, k, type);
end