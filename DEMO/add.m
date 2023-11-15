function x = add(y,z)
%! is x int
%! is y int 
%! is z int
%! description (add) 
%!> adds together two numbers
%! description (x) 
%!> result of adding z and y
%! description (y) 
%!> first addend
%! description (z) 
%!> second addend
%! values(y) [1,2,3,4]
%! values(z) [1,2,3,4]
%! call [[x],[y,z]]
%! ensures x ==  y + z
%! ensures y ==  x - z
%! ensures z ==  x - y

x = y + z;