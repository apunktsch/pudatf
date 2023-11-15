function a = multiply(b,c)
%! is a int
%! is b int 
%! is c int
%! description (add) 
%!> multiplies two numbers
%! description (a) 
%!> result of multiplying c and b
%! description (b) 
%!> first number
%! description (c) 
%!> second number
%! values(b) [1,2,3,4]
%! values(c) [1,2,3,4]
%! call [[a],[b,c]]
%!> multiplies b by c to get a
%! ensures a ==  b * c
%! ensures b ==  a / c
%! ensures c ==  a / b
a = 0;
for i = 1:c
    a = add(a,b);
end