






use feature ":5.14";

sub display
{
 ($msg) = @_;
 print $msg;
}

 
sub main
{
 display("1111111111111111111");
 if (prototype display) {
        print "display is defined!\n";
    }
    else {
        print "display is undefed!\n";
    }
}
 
main();
