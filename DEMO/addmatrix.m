function C = addmatrix(A,B)
%! is A matrix of [2,2]
%! is B matrix of [2,2]
%! is C matrix of [2,2]
%! ensures sum(sum(A == (C + B)))
%! call [[A],[B,C]]
C = A + B;
end