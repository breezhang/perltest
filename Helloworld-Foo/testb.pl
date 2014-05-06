package foo;
use feature ":5.14";
use Data::Dumper::Concise;

package main;
use feature ":5.14";
use Data::Dumper::Concise;
use POE;
POE::Session->create(
    inline_states => {
        _start => sub {
            say "hi";
            $_[KERNEL]->delay( do_something => 1 );
            $_[KERNEL]->post( $_[SESSION], "event_name", 0 );
            $_[KERNEL]->post( $_[SESSION], "event_name", 0 );
            $_[KERNEL]->alarm_add( do_something => 2 );
            $_[KERNEL]->alarm_add( do_something => 1 );
            $_[KERNEL]->alarm_add( do_something => 1 );
            $_[KERNEL]->alarm_add( do_something => 1 );
            $_[KERNEL]->delay_set( "later", 5, "hello", "world" );
        },
        _stop => sub {
            say "bye";
        },
        event_name   => \&Google,
        do_something => sub {
            say scalar @_;
        },
        later => sub {
            say @_[ARG0..$#_];
        },
    },
);

POE::Kernel->run;
exit 0;

sub Google {
    say "https://google.com";
}

