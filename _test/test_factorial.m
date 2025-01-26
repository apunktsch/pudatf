function test_suite=test_factorial
    try 
        test_functions=localfunctions();
    catch
    end
    initTestSuite;
end
function test_0 
n = 2;


[result]=factorial(n);
assert( (result == factorial(n)))
end
function test_1 
n = 3;


[result]=factorial(n);
assert( (result == factorial(n)))
end
