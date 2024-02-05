use v6;
use Mark;
unit module Parser;
# c-like header stuff
class SZ { ... }
class Param { ... }
class Spec  { ... }
class Condition { ... }
class Call { ... }
class System { ... }
class Description { ... }
class Struct { ... }
our $doc = Spec.new;
our $num_calls = 0;
grammar Docu {
    token TOP     { \s* '%!' \s*( <ensures> | <requires> | <is> | <call> | <system> | <description> | <descriptionheader> | <defaults> ) }
    token ensures { 'ensures' <condition> }
    token requires { 'requires' <condition> }
    token condition {.*}
    token descriptionheader { 'description'\s*'(' (<[A..Za..z | _]>*) ')'\s*}
    token description { ('>' (.*))}
    token system { 'system' \s* '['<systemvars> ']' }
    token systemvars { \s* <[A..Za..z ,  _]>  <[A..Za..z , _]>*  }
    token call { 'call' \s* '[[' <output> '],[' <input> ']]' }
    token is { 'is'\s*<var>\s*<datatype> \s* [[ 'björk' \s*'[' <constraints>']'\s* ] | [ 'of' \s*<size>\s*]]* }
    token var { <[A..Za..z _ \.]>*  }
    token constraints {  <[A..Za..z  _  ,]>*  }
    token output {\s* <[A..Za..z  _]>  <[A..Za..z  _  ,]>* }
    token input  {\s* <[A..Za..z  _]>  <[A..Za..z  _  ,]>* }
    token datatype { 'matrix' | 'real' | 'int' | 'string' | 'char' | 'struct' }
    token size  { '['[<number> | <size_var> ] ',' [ <number> | <size_var> ] ']' }
    token size_var { <[A..Za..z | _]>* }
    token number { \d+ }
    token defaults { 'values'\s* '(' (<[A..Za..z  _  \.]>*) ')' \s* (.*) }
}
class System {
  has Str @.members is rw;

  submethod visual ( --> Str) {
    return "System consisting of: "~(@!members.join(",").Str)
  }
  submethod getMembers ( --> Array) {
    return @!members;
  }
}
class Doku-Actions {
  method constraints ($/) {
    $doc.setConstraintOfParameterAtIndex( $/.Str.split(',').Array.flat.Array, $doc.findParamIndex($doc.getCurrentParamName)); 

  }
  method var ($/) {

    $doc.setCurrentParamName($/.Str);
    $doc.addNewParameter($/.Str);
  }
  method defaults ($/) {
    my $p = $/[0].Str;
    my $valus = $/[1].split(',');
    # this is technically unacceptable, but somehow I cannot regex correctly currently.
    $valus = $valus.map:{ $_.subst(/\[/,"")}
    $valus = $valus.map:{ $_.subst(/\]/,"")}
    my @vals = $valus.Array;
    $doc.setValuesOfParameterAtIndex( @vals, $doc.findParamIndex($p)); 

  }
  method call($/) {
   $doc.addCall(Call.new(inputs => $doc.getPendingInput, outputs => $doc.getPendingOutput));
   $doc.addDescription(Description.new(var => ("call_$num_calls").Str));

  }
  method system ($/) {
  }
  method systemvars ($/) {
    $doc.addSystem(System.new(members => $/.Str.split(",")));
  }
  method input ($/) {
    $doc.setPendingInput($/.Str.split(",").Array);
  }
  method output ($/) {
  
    $doc.setPendingOutput($/.Str.split(",").Array);
  }
  method condition($/) {
    $doc.addNewCondition( $/.Str );
  }
  method requires($/) {
    $doc.addToLastCondition( False );
  }
   method ensures($/) {
    $doc.addToLastCondition( True );
  }
  method size($/) { 
    my @SPL = $/.Str.split(',');
    my $l = @SPL[0].substr(1);
    my $r = @SPL[1].substr(0,*-1);
    $doc.setSizeOfParameterAtIndex( SZ.new( l => $l, r => $r), $doc.findParamIndex($doc.getCurrentParamName)); 
     
  }
  method datatype($/) { 
    if ($/.Str ne "struct") {
    $doc.setTypeOfParameterAtIndex( $/.Str, $doc.findParamIndex($doc.getCurrentParamName)); 
    } else {
    my $parts = $doc.getCurrentParamName.Str.split(".").Array;
    $doc.setTypeOfParameterAtIndex( "struct", $doc.findParamIndex($doc.getCurrentParamName)); 
    }
  }
  method description($/) {
   $doc.addToLastDescription($/[0].Str);
  }
  method descriptionheader($/) {
    $doc.addDescription(Description.new(var => ($/[0].Str)))
  }
}
# these should not be strings, but proper case differentiation, maybe fix? 
class SZ {
  has Str $.l; 
  has Str $.r;

  submethod visual {
    return( '[' ~ $!l.Str ~ ',' ~ $!r.Str ~ ']');
  }

}
class Param {
  has Str $.name is rw;
  has Str $.type is rw;
  has SZ $.sz; 
  has Bool $.isMatrix is rw;
  has Array @.constraints is rw; 
  has Str @.values is rw; 
  has Struct $.subs is rw;
  submethod setValues(@vals) {
    @!values = @vals;
  }
  submethod getValues( --> Array) {
    return @!values;
  }
  submethod getSub(--> Struct) {
    return $!subs; 
  } 
   submethod setSub($s) {
    $!subs = $s;
  } 
  submethod setConstraints ($cons) {
    @!constraints = $cons;
  }
  submethod getName (--> Str) {
    return $!name;
  }
   submethod getType (--> Str) {
    return $!type;
  }
  submethod visual {
    my Str $msg = $!name ~ " | " ~ $!type;
    if $!sz {
      $msg = $msg ~ " | " ~ $!sz.visual;
    }
   $msg.say;
  }
  submethod setType ($ptype){
    $!isMatrix = False;
    $!isMatrix = True if $ptype === "matrix";
    $!type = $ptype;
  }
   submethod setSize ($SZ){
    $!sz = $SZ;
  }
  submethod getSize ( --> Str) {
    if $!sz {
    return $!sz.visual;
    }
    return "any"
  }

}
class Call {
  has Array @.inputs is rw; 
  has Array @.outputs is rw;

  submethod visual {
    ("Inputs: ["~@!inputs.Str~"] Outputs: ["~@!outputs~"]").say
  }

  submethod visualInputs ( --> Str ) {
    return ((@!inputs[0].join(", ")).Str);
  }
  submethod visualOutputs (--> Str ) {
    return ("["~(@!outputs[0].join(", ")).Str)~"]";
  }
}
class Description{
  has Str $.var; 
  has Str @.description; 

  submethod addLine ($s) {
    @!description.append($s);
  }
  submethod visual {
    $!var.say; 
    for @!description {
      $_.say if $_;
    }
  }
} 
class Condition {
  has Str $.condition is rw; 
  has Bool $.pre is rw;

  submethod visual {
    if $!pre { say ('requires :', $!condition )} else { say ('ensures  :', $!condition )} 
  }
  submethod setPre ($s) {
    $!pre = $s;
  }
  submethod getPre ( --> Bool) {
    return $!pre;
  }
  submethod getCondition (--> Str) {
   return $!condition; 
  }

}
class Spec{
    has Str $.filename;
    has Str $.funcDescription;
    has Str $.funcName;
    has Param @.parameters is rw;
    has System @.systems is rw; 
    has Condition @.conditions is rw; 
    has Str $.currentParamName is rw;
    has Call @.calls is rw; 
    has Array @.pendingInput is rw; 
    has Array @.pendingOutput is rw;
    has Description @.descriptions is rw; 
    has Struct @.structs is rw;

    submethod getFuncDesc ( --> Str) {
      return $!funcDescription;
    }
    submethod appendFuncDesc ($s){
      $!funcDescription ~= $s;
    }
    submethod structStuff($s) {
    # if exists, cascade down and recall
    my $i = 1;
    for @!structs -> $p {
        if ($p.getName.Str === $s.Str) {
          return $i;
        }  
        $i = $i + 1;
      }
    # else make new and cascade
    }
    submethod addSystem($s){
      @!systems.append($s);
    }
    submethod addDescription($d) {
      @!descriptions.append($d);
    }
    submethod addToLastDescription($s) {
      @!descriptions[*-1].addLine($s);
    }
    submethod addCall($c) {
      @!calls.append($c);
    }
    submethod appendParam($p) {
      # find corresponding place, set that - else new entry
        @!parameters.append($p);
    }
     submethod appendCondition($c) {
      # find corresponding place, set that - else new entry
        @!parameters.append($c);
    }
    submethod getPendingInput( --> Array) {
      return @!pendingInput;
    }
    submethod setPendingInput($i) {
      @!pendingInput = $i;
    } 
    submethod getPendingOutput( --> Array) {
      return @!pendingOutput;
    }
    submethod setPendingOutput($i) {
      @!pendingOutput = $i;
    } 
    submethod setFileName ($fname) {
      $!filename = $fname;
    }
     submethod getFileName ( --> Str) {
     return $!filename;
    }
    submethod setCurrentParamName($name) {
      $!currentParamName = $name;
    }
    submethod getCurrentParamName( --> Str){
      return $!currentParamName;
    }
    submethod findParamIndex ( $pname --> Int){
      my Int $i = 0;
      for @!parameters -> $p {
        if ($p.getName.Str === $pname.Str) {
          return $i;
        }  
        $i = $i + 1;
      }
      return -1;
    }
    submethod getParameters ( --> Array) {
      return @!parameters;
    }
    submethod getCalls ( --> Array) {
      return @!calls;
    }
    submethod getConditions (--> Array) {
      return @!conditions;
    }
    submethod getSystems ( --> Array) {
      return @!systems;
    }
    submethod addNewParameter ($pname) {
      @!parameters.append(Param.new(name => $pname));
    }
    submethod addNewCondition ($pre) {
      @!conditions.append(Condition.new(condition => $pre));
    }
    submethod addToLastCondition($condition) {
      @!conditions[*-1].setPre($condition);
    }
    submethod setTypeOfParameterAtIndex ($type, $index) {
      @!parameters[$index].setType($type);
    }
    submethod setValuesOfParameterAtIndex (@vals, $index) {
      @!parameters[$index].setValues(@vals);

    }
    submethod setConstraintOfParameterAtIndex ($con, $index) {
      @!parameters[$index].setConstraints($con);
    }
    submethod setSizeOfParameterAtIndex ($SZ, $index) {
      @!parameters[$index].setSize($SZ);
    }
    submethod setFuncName($fname) {
      $!funcName = $fname;
    }
    submethod getFuncName( --> Str) {
      return $!funcName;
    }
    submethod printSpecification {
      say "\n"~$!filename~"\n";
      for @!parameters {
        $_.visual;
      }
      for @!conditions {
        $_.visual;
      }
      for @!calls {
        $_.visual;
      }
      for @!descriptions {
        $_.visual;
      }
    }
}

class Struct {
   has Str $.name is rw;
   has Struct $.next is rw; 
   has $.value is rw;

   submethod isLeaf( --> Bool) {
    return ($!next.raku.Str == "Any")
   }
   submethod getName( --> Str) {
    return $!name;
   }
}


our sub parse($file --> Spec){
  # reset $doc
  $doc = Spec.new;
  $num_calls = 0;
  $doc.setFileName($file);

  for $file.IO.lines -> $line {
    if $line ~~ /function .* \= \s*(.*)'('.*')' / {
    $doc.setFuncName(($line ~~ /function .* \= \s*(.*)'('.*')' /)[0].Str);
    }
    if Docu.parse($line) {
      my $match =  Docu.parse($line, actions => Doku-Actions );
    }
  }   
writeSpecToMark($doc);
return $doc;
}

sub writeSpecToMark($doc){
  my $mark = "";
   $mark ~= $doc.funcName.Str~":";
  for $doc.getParameters -> $pa {
    #$pa.raku.say;
    if $pa.values {
        $mark ~= ("\n    "~($pa.name.Str)~":"~($pa.values[0]));
    }
  }
  $mark ~= "\n";
my $fh = open "defaults.mark", :a;
$fh.print($mark);
$fh.close;
}

class CallNode {
    has Str $.name    is rw; 
    has Str @.callers is rw; 
    has Str @.calls   is rw;

    submethod addcaller($c) {
        @!callers.append($c);
    }
    submethod addcalled($c) {
        @!calls.append($c);
    }
    submethod getCallers ( --> Array) {
      return @!callers;
    }
    submethod getCalls ( --> Array) {
      return @!calls;
    }
}

our sub parseYaml($fp --> Hash) {
  my %calls;
  my $indent = 0;
  my $meth;
  my $callSwitch;
  my $skipUntilNext = False;
  for $fp.IO.lines -> $line {
      next if ($line.Str eq "---");
      $indent = ($line ~~ /\s*/).Str.chars;
      if ($line.Str ~~ /\?/) or ($line.Str ~~ /^^\:/) {
        $skipUntilNext = True;
        next;
      }
      if $indent == 0 {
          $skipUntilNext = False;
          $meth = (IO::Spec::Unix.basename($line) ~~ /.* \.m/).Str.split('.')[0].Str; 
          %calls{$meth} = CallNode.new( name => $meth);
      } elsif $indent == 2 {
        next if $skipUntilNext;
          $callSwitch =  ( $line.Str eq "  calls:")     
      } elsif $indent == 4 {
          next if $skipUntilNext;
          if !$callSwitch {
              %calls{$meth}.addcaller((IO::Spec::Unix.basename($line) ~~ /.* \.m/).Str.split('.')[0].Str); 
          } else {
              %calls{$meth}.addcalled((IO::Spec::Unix.basename($line) ~~ /.* \.m/).Str.split('.')[0].Str); 
          }
      } else {
          next if $skipUntilNext;
          "malformed callgraph".say;
      }
  }
  return %calls;

}
our sub getTouchedFiles($files, $callgraph --> Hash ) {
    my $cg = Parser::parseYaml($callgraph);
    my %visited;
    my @queue = [];
    for $files.split("\n") -> $file {        
        my $key = (IO::Spec::Unix.basename($file) ~~ /(.*) \.m/)[0];
        if ($file ~~ /(.*) \.m/) && ($cg{$key}:exists) {
            %visited{$key} = True;
            for $cg{$key}.getCallers -> $caller {
                next if %visited{$caller}:exists;
                %visited{$caller} = True;
                @queue.append($caller);
            }   
        }
    } 
    while @queue.elems > 0 {
           my $elem = @queue.pop; 
           for $cg{$elem}.getCallers -> $caller {
              next if %visited{$caller}:exists;
              %visited{$caller} = True;
              @queue.append($caller);
           }         
    }
      for $files.split("\n") -> $file {        
        my $key = (IO::Spec::Unix.basename($file) ~~ /(.*) \.m/)[0];
        %visited{$key} = True if $key;;
      }
    return %visited;
}
