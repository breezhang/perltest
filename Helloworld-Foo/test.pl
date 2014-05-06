package foo;

sub new {
    return bless {}, shift;
}

sub _start {
    print "..........";
    print "\n";
}

sub _stop {
    print "xxxxxxxxxxxxx";
    print "\n";
}

package bar;

sub new {
    return bless {}, shift;
}

sub _start {
    print "a";
    print "\n";
}

sub _stop {
    print "b";
    print "\n";
}

package main;
use feature ":5.14";
use Data::Dumper::Concise;
use POE;

my $id         = $^O;
my $pid        = $$;
my $Hellokitty = 0;

$bar = bar->new;

#POE::Session->create( object_states => [ $bar => [qw(_start _stop)], ] );

POE::Session->create( package_states => [ foo => [ '_start', '_stop' ], ] );

POE::Session->create(inline_states => { _start  => \&start,
                                        sleeper => \&sleeper,
                     },
                     args    => [1],
                     heap    => [ foo->new, bar->new ],
                     options => { trace => 1, debug => 1, name => 'Service' },
);

POE::Session->create( inline_states => { _start  => \&start,
                                         sleeper => \&sleeper,
                      },
                      args    => [2],
                      options => { name => "Client" },
);

POE::Session->create( object_states => [ $bar => [qw(_start _stop)], ] );

print "Running Kernel\n";
$poe_kernel->run();
print "Exiting\n";
exit(0);

sub start {
    my ( $kernel, $time ) = @_[ KERNEL, ARG0 ];
    $kernel->yield( "sleeper", $time );
}

sub sleeper {
    my ( $kernel, $session, $time ) = @_[ KERNEL, SESSION, ARG0 ];

    #print " $id $$ Hello 1S OSCon Attendees!\n" if $time ==1;
    #print " $id $$ Hello 2S OSCon Attendees!\n" if $time ==3;
    say "[1;32m", Dumper( keys %{ $kernel->[0] } ), "[m";

    use Scalar::Util qw/looks_like_number/;
    use Win32;
    say "[1;33m", Win32::GetCurrentThreadId() ,"[m";

    for ( keys %{ $kernel->[0] } ) {
        say "this is a Session $_  $_[STATE] " if looks_like_number($_);
        say $_[SESSION]->option('name');
    }

    $kernel->delay_set( "sleeper", $time, $time );
}

