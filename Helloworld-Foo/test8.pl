package foo;
use feature ":5.14";
use POE;
use base qw(POE::Wheel);

sub new {
    my ( $class, $event, $code ) = @_;
    say "has " if $poe_kernel;
    say $_[0];
    #$poe_kernel->state( $event, $self, 'other_method' );
    return bless [ $class, $event, $code, POE::Wheel::allocate_wheel_id(), ],
        $class;
}

sub DESTROY {
    my $self = shift;
    POE::Wheel::free_wheel_id( $self->[3] );
}

sub ID {
    return $_[0]->[3];
}

package main;
use feature ":5.14";
use POE;

POE::Session->create(
    inline_states => {
        _start => sub {
            $_[HEAP]{console} = foo->new( Google => 'helloworld', );

        },
        _stop      => sub { },
        helloworld => sub {
            say "...";
        },
    },
);

POE::Kernel->run();
exit 0;
