use v6;
use Parser;
use Documentation;
use constraints;
unit module Testing;


# 'matrix' | 'real' | 'int' | 'Str' | 'char' | 'struct'
sub makeMatrix (Parser::Param $p --> Str) {
    my $pname = $p.getName;
    my $sz    = $p.getSize;

    if ($sz.Str ~~ /any/) {
        $sz = "[3,3]"
    }
    #         Sparse, id, symm, pd
    my $aa = [False,  False, False, False];
    if $p.HasConstraint() {
        my $cons = $p.getConstraints; 
        for 0..^$cons.elems -> $i {
            do given $cons[$i] {
            when 'sparse' {$aa[0] = True; } 
            when 'id' {$aa[1] = True; }  
            when 'symm' {$aa[2] = True; } 
            when 'pd' {$aa[3] = True; } 
            when 'spd' {$aa[2] = True; $aa[3] = True; } 
            default       {"Invalid constraint!".say;}                 
            }
            # this should never happen, if this triggers, the parser broke
        };
        return selectMatrix($aa,$p);

        }
    return "$pname = rand($sz);";
}

sub selectMatrix($booleans, $param --> Str) {
    my $pname = $param.getName;
    my $size = $param.getSize;
    my $m = 3;
    my $n = 3;
    if !($size.Str ~~ /any/) {
        my $splitt = ($size ~~ /\[(.*)\]/)[0].Str.split(",");
        $n = $splitt[0];
        $m = $splitt[1];
    }
    do given $booleans {
            when $_ eqv [False, False, False, False] {"1".say}
            when $_ eqv [False, False, False, True] {"2".say}
            when $_ eqv [False, False, True, False] {"3".say}
            when $_ eqv [False, False, True, True] {"4".say}
            when $_ eqv [False, True, False, False] {"5".say}
            when $_ eqv [False, True, False, True] {"6".say}
            when $_ eqv [False, True, True, False] {"7".say}
            when $_ eqv [False, True, True, True] {"8".say}
            when $_ eqv [True, False, False, False] {"9".say}
            when $_ eqv [True, False, False, True] {"10".say}
            when $_ eqv [True, False, True, False] {"11".say}
            when $_ eqv [True, False, True, True] {"12".say}
            when $_ eqv [True, True, False, False] {return constraints::spd($pname,$m,$n)}
            when $_ eqv [True, True, False, True] {"14".say}
            when $_ eqv [True, True, True, False] {"15".say}
            when $_ eqv (True, True, True, True) {"16".say}
            }
    return "";
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
    if ($sz.Str eq "") {
        $sz = "10";
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
sub parseNegativeParam(Parser::Param $param, $ind --> Str) {
    # create some negative test cases to test, whether it is within spec.
    do given $param.getType {
            when 'real'   {return makeString($param, $ind);   }
            when 'int'    {return makeReal($param, $ind);    }
            when 'string' {return makeChar($param, $ind); }
            when 'char'   {return makeInt($param, $ind);   }
            default       {return ""                 }
            # this should never happen, if this triggers, the parser broke
        };
}
our sub getAppropriateSystems( Parser::System $syss --> Array) {
    my $members = $syss.getMembers;
    my $fh = open "systems/systems.index";
    my @matchingSystems = [];
    for $fh.IO.lines -> $line {
        my $match = ($line ~~ / (.*) \: \s* (<[A..Za..z0..9  _]>*) /);
        my $match_split = $match[0].Str.split(",");
        @matchingSystems.append($match[1].Str) if $match_split == $members;
    }
    $fh.close;
    return @matchingSystems;
}
our sub createTestCases (Parser::Spec $spec, $filename, $smoke) {
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
        for @lengthList -> $x {$numRuns = $numRuns * max(1,$x)}
        # scale lengthlist by possible systems
        my $j = 0; 
        $i = 0;
        my @systemms;
        for $spec.getSystems -> $sys_var {
               @systemms[$j++] = getAppropriateSystems($sys_var);
        }
        my @sysLength = @systemms.map( -> $arr { $arr.elems });
        my $differentSystems = [*] @sysLength;
        $numRuns = $numRuns * $differentSystems;
        my Int $l_perm = (@lengthList.elems + @systemms.elems) + 0;
        $j = 0;
        my @perm; 
        @perm[$_] = 0 for 0 .. $l_perm; 
        my $index = 0;
        # preprocess @lengthlist
        my $uniqueVals = "";
        my $k = 0;
        my $varSetup = "";
        $numRuns = 1 if $smoke;
        for 0..$numRuns -> $i {
            for 0..(@lengthList.elems + @systemms.elems - 1) -> $j {
                if $j < @lengthList.elems {
                    if ((@perm[$j] + 1) >= @lengthList[$j]) {
                        @perm[$j] = 0;
                        next;
                    }
                    @perm[$j] += 1;
                    last;
                } else  {
                    my $u = $j - @lengthList.elems;
                     if ((@perm[$j] + 1) >= @systemms[$u]) {
                        @perm[$j] = 0;
                        next;
                    }
                    @perm[$j] += 1;
                    last;
                }
            }
            # DO STUFF HERE!!! @perm is correct (not in any logical order, but meh who cares)
            $uniqueVals = "";
            $k = 0;
            for $spec.getParameters -> $param {
                if $k < @lengthList.elems {
                    if $param.getValues != [] {
                    $uniqueVals = $uniqueVals~parseParam($param, @perm[$k])~"\n";
                    } 
                } 
                $k += 1;
            }
            $varSetup =  ($singleVals~$uniqueVals);
            #$varSetup.say;
            #setup systems 
            for 0..(@systemms.elems - 1) -> $l {
                #(@systemms.elems~" "~@lengthList.elems~"-->"~$l).say;
                $varSetup ~= ("\n"~Q[load("systems/]~(@systemms[$l][@perm[$k+$l]])~Q[.mat");]~"\n")
                
            }
            # for each call, setup the call. 
            for $spec.getCalls -> $c {
                $fh.print("function test_$testNum \n"~$varSetup~"\n\n"~$c.visualOutputs~"="~
                        $spec.getFuncName~"("~$c.visualInputs~");\n"~ $postConditions~"end\n");
                $testNum += 1;
            }
            
        
    # create wrong type testcases
    if $smoke == False {
        "WRONG TESTS".say;
        $uniqueVals = "";
        $k = 0;
        for $spec.getParameters -> $param {
            if $param.getValues != [] {
                $uniqueVals = $uniqueVals~parseNegativeParam($param, @perm[$k])~"\n";
            } 

            $k += 1;
        }
        $postConditions = "";
        for $spec.getConditions -> $cond {
            if $cond.getPre {
                my $t = $cond.getCondition;;
                $postConditions ~= "assert($t)\n";
            }
        }

        $varSetup =  ($singleVals~$uniqueVals);
        # for each call, setup the call. 
        for $spec.getCalls -> $c {
            $fh.print("function test_$testNum \n"~$varSetup~"\n\n"~"assertExceptionThrown("~
                    $spec.getFuncName~"("~$c.visualInputs~"),'*');\n"~"end\n");
                    
        $testNum += 1;
        }
    }

    # create out of spec testcases
        }
$fh.close;
}

