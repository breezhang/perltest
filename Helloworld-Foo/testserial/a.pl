use JSON::XS;
use feature ":5.14";

package Main;
use Data::Dumper::Concise;
__PACKAGE__->main();

sub foo {
    say "test_ JSON_ XS _";
    my $json = JSON::XS->new->utf8->space_after->encode( { a => [ 1, 2 ] } );
    say Dumper $json;
    say "=============================";
    use Pithub;
    print Pithub->new( user => 'breezang1877@hotmail.com' )->repos->user;
    say;
    print Pithub::Repos->new( user => 'breezang1877@hotmail.com' )
        ->keys->user;
    say;
    my $p = Pithub->new( user => 'breezang1877@hotmail.com', repo => 'perltest' );
    my $r = $p->repos;
    say $r->user;  
    say $r->repo ;
}

sub bar {
    say "bar";
}

sub main {
    say "....runing....";
    foo();
    bar();
}
