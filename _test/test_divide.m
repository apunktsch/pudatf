function test_suite=test_divide
    try 
        test_functions=localfunctions();
    catch
    end
    initTestSuite;
end
function test_0 
a = "2";
b = "1";
c = "1";


[c]=divide(a, b);
end
function test_1 
a = "1";
b = "3";
c = "1";


[c]=divide(a, b);
end
