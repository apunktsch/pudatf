function area =area_of_circle(radius)
%! description(area_of_circle)
%!> area_of_circle calculates the are of a circle with the radius 'radius'
%! is radius int
%! is area int
%! values(radius) [1,3]
%! call [[area],[radius]]
% Calculate the area of a circle
    area = pi * radius^2;
end