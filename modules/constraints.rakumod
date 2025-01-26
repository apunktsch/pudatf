use v6; 
unit module constraints;

our sub id($name, $m, $n --> Str) {
    return qq:to/END1/;
    $name = eye($m,$n)
    END1
}
our sub spid($name, $m, $n --> Str) {
    return qq:to/END1/;
    $name = speye($m,$n)
    END1
}

our sub spd($name, $m, $n --> Str) {
    return qq:to/END1/;
    $name = rand($n,$m); 
    $name = $name*$name';
    END1
}

our sub spspd($name, $m, $n --> Str) {
    return qq:to/END1/;
$name = sprandsym(m); 
$name = $name + m*speye(m);
END1
}

