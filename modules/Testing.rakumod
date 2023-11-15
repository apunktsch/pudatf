use v6;
use Parser;
use Documentation;
unit module Testing;


# 'matrix' | 'real' | 'int' | 'Str' | 'char' | 'struct'
sub makeMatrix (Parser::Param $p --> Str) {
    my $pname = $p.getName;
    my $sz    = $p.getSize;
    if ($sz.Str ~~ /any/) {
        $sz = "[3,3]"
    }
            
    return "$pname = rand($sz);";
}
multi sub makeReal (Parser::Param $p, $ind --> Str) {
    my $pname = $p.getName;
    my $pval = $p.getValues[$ind ];
     return '\qq[$pname] = "\qq[$pval]";'
}
multi sub makeReal (Parser::Param $p --> Str) {
    # rand * (b-a) + a // random number between a and b
     my $pname = $p.getName;
     my $sz    = $p.getSize;
     my $a; my $b;
    if ($sz.Str ~~ /any/) {
        $a = 0;
        $b = 1;
    }  else {
        my $s = $sz ~~ / '[' (.*) ',' (.*) ']' /;
        $a = $s[0];
        $b = $s[1];
    }
    # handle all the bullshit
    return "$pname = rand * ($b-$a) + $a;"
}
multi sub makeInt (Parser::Param $p, $ind --> Str) {
    my $pname = $p.getName;
    my $pval = $p.getValues[$ind];
     return '\qq[$pname] = \qq[$pval];'
}
multi sub makeInt (Parser::Param $p --> Str) {
    my $pname = $p.getName;
    my $sz    = $p.getSize;
    if ($sz.Str ~~ /any/) {
        $sz = "[1,10]"
    }
    
            
    return "$pname = randi($sz);";
} 
multi sub makeString (Parser::Param $p, $ind --> Str) {
    my $pname = $p.getName;
    my $pval = $p.getValues[$ind ];
     return '\qq[$pname] = \qq[$pval];'
}
multi sub makeString (Parser::Param $p --> Str) {
 # strings should really only come from given values
    my $pname = ($p.getName)~"s";
    my $valus = "";
    return "$pname = $valus;"
    
} 
multi sub makeChar (Parser::Param $p, $ind --> Str) {
    my $pname = $p.getName;
    my $pval = $p.getValues[$ind];
     return  '\qq[$pname] = \qq[$pval];'
}
multi sub makeChar (Parser::Param $p --> Str) {
 # chars should really only come from given values
    my $pname = ($p.getName)~"s";
    my $valus = "["~$p.getValues.join(",")~"]";
    return "$pname = $valus;"
}
sub makeStruct (Parser::Param $p --> Str) {
 # cascade the shit out of this
 my $pname = ($p.getName);
 return "$pname = struct;";
} 
multi sub parseParam(Parser::Param $param --> Str) {
    do given $param.getType {
            when 'matrix' {return makeMatrix($param); }             
            when 'struct' {return makeStruct($param); }
            when 'real'   {return makeReal($param);   }
            when 'int'    {return makeInt($param);    }
            when 'string' {return makeString($param); }
            when 'char'   {return makeChar($param);   }
            default       { return ""                 }
            # this should never happen, if this triggers, the parser broke
        };
}
# $param, $param.getValues, @perm[$k]
multi sub parseParam(Parser::Param $param, $ind --> Str) {
    do given $param.getType {
            when 'real'   {return makeReal($param, $ind);   }
            when 'int'    {return makeInt($param, $ind);    }
            when 'string' {return makeString($param, $ind); }
            when 'char'   {return makeChar($param, $ind);   }
            default       { return ""                 }
            # this should never happen, if this triggers, the parser broke
        };
}

our sub createTestCases (Parser::Spec $spec, $filename) {
my $fh = open $filename, :w;
my $testNum = 0;
# print MOxUnitHeader 
my $funcname =(IO::Spec::Unix.basename($spec.getFileName) ~~ /.* \.m/).Str.split('.')[0].Str; 
my $MOxUnitHeader = qq:to/END1/;
function test_suite=test_$funcname
    try 
        test_functions=localfunctions();
    catch
    end
    initTestSuite;
end
END1
$fh.print($MOxUnitHeader);
my $postConditions = "";
# set up postConditions;
for $spec.getConditions -> $cond {
    if $cond.getPre {
    my $t = $cond.getCondition;;
    $postConditions ~= "assert($t)\n";
    }
}
my $singleVals = ""; 
    for $spec.getParameters -> $param {
          if $param.getValues == [] {
          $singleVals = $singleVals~parseParam($param)~"\n";
          } 
    }
    # make list of value lengths
    my @lengthList; 
    my $i = 0;
    for $spec.getParameters -> $param {
      
        @lengthList[$i] = $param.getValues.elems;
        $i = $i + 1;
    }
    my $numRuns = 1;
    for 0 ..^ @lengthList.elems  -> $i {
        if @lengthList[$i] != 0 {
            $numRuns *= @lengthList[$i];
        }
    }
    my @perm; 
    @perm[$_] = 0 for 0 ..^ @lengthList.elems;
    my @AHHHH;
    my $index = 0;
    # preprocess @lengthlist
    for 0 ..^ $numRuns -> $i {
        for 0..^ @lengthList.elems -> $j {
            if @perm[$j] + 1 >= @lengthList[$j] {
                @perm[$j] = 0;
                next;
            }
            @perm[$j] += 1;
            last;
            

        }
        # DO STUFF HERE!!! @perm is correct (not in any logical order, but meh who cares)
        my $uniqueVals = "";
        my $k = 0;
        for $spec.getParameters -> $param {
            if $param.getValues != [] {
            $uniqueVals = $uniqueVals~parseParam($param, @perm[$k])~"\n";
            } 

            $k += 1;
        }

         my $varSetup =  ($singleVals~$uniqueVals);
         #$varSetup.say;
         # for each call, setup the call. 
         for $spec.getCalls -> $c {
            $fh.print("function test_$testNum \n"~$varSetup~"\n\n"~$c.visualOutputs~"="~
                      $spec.getFuncName~"("~$c.visualInputs~");\n"~ $postConditions~"end\n");
            
            $testNum += 1;
         }
    }
$fh.close;
}

