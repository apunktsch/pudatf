function result = factorial(n)
%! description(factorial)
%!> computes n!
%! is n int
%! values(n) [1,2,3,4]
%! call [[result],[n]]
%! ensures (result == factorial(n))
    result = 1;
    for i = 1:n
        result = multiply(result, i);
    end
end