function test_suite=test_addmatrix
    try 
        test_functions=localfunctions();
    catch
    end
    initTestSuite;
end
function test_0 
A = rand([2,2]);
B = rand([2,2]);
C = rand([2,2]);


[A]=addmatrix(B, C);
assert( sum(sum(A == (C + B))))
end
function test_1 
A = rand([2,2]);
B = rand([2,2]);
C = rand([2,2]);


[A]=addmatrix(B, C);
assert( sum(sum(A == (C + B))))
end
