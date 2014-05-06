#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Helloworld::Foo' ) || print "Bail out!\n";
}

diag( "Testing Helloworld::Foo $Helloworld::Foo::VERSION, Perl $], $^X" );
