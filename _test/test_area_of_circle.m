function test_suite=test_area_of_circle
    try 
        test_functions=localfunctions();
    catch
    end
    initTestSuite;
end
function test_0 
area = randi(10);
radius = 3;


[area]=area_of_circle(radius);
end
function test_1 
area = randi(10);
radius = 1;


[area]=area_of_circle(radius);
end
