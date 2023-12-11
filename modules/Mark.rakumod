use v6;
unit module Mark;

our sub readMark($file -->  Hash) {
    grammar mark {
        token TOP {<credit> | <attribute>}
        token credit { (\w+) ':' \s* }
        token attribute { \s+ (\w+) ':' (\w+) } 
    }
    my %defaults;
    my $last = "";
    class mark-actions{
        method credit($/) {
            $last = $/[0].Str;
        }
        method attribute($/) {
            %defaults{$last}{$/[0].Str} = $/[1].Str;
        }
    }
    for $file.IO.lines -> $line {
        mark.parse($line, actions => mark-actions);
    }
    return %defaults;
}
our sub writeMark(%hash, $file, $backup?) {
    if defined $backup {
       if $backup {
        my $copy = $file.IO.slurp;
        my $fh = open "copy_"~$file, :w;
        $fh.print($copy);
        $fh.close
       }
    }
    my $markFile  = "";
    for %hash.keys -> $key {
        $markFile ~= $key.Str~":\n";
        for %hash{$key}.keys -> $sndKey {
            $markFile ~= "    "~$sndKey.Str~":"~%hash{$key}{$sndKey} ~"\n";
        }
    }
    $markFile.say;
}
