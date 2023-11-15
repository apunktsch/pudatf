use v6;
use Parser;
unit module Documentation;

sub parameterEntity ($p --> Str) {
    return "";("<p> Name: "~$p.getName.Str~" type: "~$p.getType.Str~" size: "~$p.getSize.Str~"</p>").Str
}

sub callEntity ($c --> Str) {
    return "<p> ["~$c.visualInputs~"] = ["~$c.visualOutputs~"]</p>";
}
sub systemEntity ($c --> Str) {
    return "<p> "~$c.visual~"</p>";
}

our sub makeDocumentation (Parser::Spec $s, $filename) {
    my $fh = open $filename, :w;
    $fh.print("<html>");
    $fh.print( "<h1> "~$s.getFuncName.Str ~"</h1>");
    $fh.print("<h4> Parameters </h4>");
    for $s.getParameters -> $p {
        $fh.print(parameterEntity($p));
    }
      $fh.print("<h4> Calls </h4>");
    for $s.getCalls -> $d {
         $fh.print(callEntity($d));
    }
       $fh.print("<h4> Systems </h4>");
    for $s.getSystems -> $d {
         $fh.print(systemEntity($d));
    }

     $fh.print("</html>");
    $fh.close;

}