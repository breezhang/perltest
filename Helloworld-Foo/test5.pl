package Foo;
use POE;
use base 'POE::Wheel';

sub new {
    print "1";
    my ( $class, %args ) = @_;
    return bless [ $args{FOO}, POE::Wheel::allocate_wheel_id(), ], $class;
}

sub event {
    print "3";
}

sub ID {
    return $_[0]->[1];
}

sub DESTROY {
    print "2";
    POE::Wheel::free_wheel_id( $_[0]->[1] );
}

package main;
use feature ":5.14";
use POE;

POE::Session->create(
    inline_states => {
        _start => sub {
            my $w = foo->new( 'FOO' => 'colorized' );
            return;
        },
        _stop     => sub { },
        colorized => sub {
            print '.............\n\n';
            }
    },
);

POE::Kernel->run();
