%! is M int
%! is N int
%! is A matrix of [M,N]
%! is B matrix of [N,M] björk [sparse,spd]
%! is x struct 
%! is y char
%! is z int
%! is x.eqn matrix 
%! is tol real of [0,1]
%! is guenther int
%! is stuff string
%! is opts struct 
%! is opts.log struct 
%! is opts.log.number int 
%! is opts.log.word string 
%! ensures A * x == B
%! requires x != 0
%! call [[xc,xb],[A,a_C]]
%! call [[xc,xb],[A,a_C,tol]]
%! system [a,b,c,d]
%! description (x)
%!> x is a wonderful matrix, I do like it!
%!> also for x, the size does not matter!
%! values(z) [1,2,3,4,5,6]
%! values(stuff) ["hey", "ho"]
%! values(y) ['N','T']
%! values(opts.log.word) ["how", "much", "is", "the", "fish?"]
function x = solf(A,B)
x = A\B;
