use v6;
use Parser;
unit module Documentation;

sub parameterEntity ($s, $p --> Str) {
    return qq:to/END1/;
<div class="spoiler-container">
    <div class="spoiler-header" onclick="toggleSpoiler(this)"> $p.getName():$p.getType() $p.getSize() </div>
    <div class="spoiler-content">
     $s.getDescOfParam($p.getName())
    </div>
</div>
END1
}

sub callEntity ($c --> Str) {
    return "<p> ["~$c.visualInputs~"] = ["~$c.visualOutputs~"]</p>";
}
sub systemEntity ($c --> Str) {
    return "<p> "~$c.visual~"</p>";
}

our sub makeDocumentation (Parser::Spec $s, $filename, @files) {
    my $fh = open $filename, :w;
    my $template = "modules/htmlPreset/htmlPresets.html".IO.slurp;
    my $entries = "";
    for @files -> $file {
        $entries = $entries~ '<li><a href="'~ $file~ '.html">' ~$file~"</a></li>";
    }
    $template ~~s:g/"ENTRIES"/$entries/;
    $template ~~s:g/"FILENAME"/$s.getFuncName()/;
    $template ~~s:g/"FILEDESC"/$s.getDescOfParam($s.getFuncName())/;
    my $body = "";
    for $s.getParameters -> $p {
        $body = $body~parameterEntity($s,$p);
       
    }

   $template ~~s:g/"CONTENT"/$body/; 
   $fh.print($template);
    $fh.close;
    return;
   
      $fh.print("<h4> Calls </h4>");
    for $s.getCalls -> $d {
         $fh.print(callEntity($d));
    }
       $fh.print("<h4> Systems </h4>");
    for $s.getSystems -> $d {
         $fh.print(systemEntity($d));
    }

}