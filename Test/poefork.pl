use feature ":5.14";
use POE;

package foo;
use base qw(POE::Wheel);

#use mro  qw(c3);
use POE;
use Data::Dumper::Concise;
use Carp qw(croak);

sub new {
    my $self = shift;
    %args = @_;
    my $code = $args{Start};
    my $name = $args{Name};
    my $path = $args{Path};

    #say "has" if $poe_kernel;
    my $wheel_id = $self->SUPER::allocate_wheel_id();
    $poe_kernel->state( TestEvent => $code );
    $self->BackEnd;
    return bless [ \%args, $wheel_id ], $self;
}

sub put {
}

sub BackEnd {
}

sub ID {
    my $self = shift;
    return $self->[1];
}

sub DESTROY {
    my $self = shift;
    $self->SUPER::free_wheel_id( $self->ID );
    say "wheel say bye";
}

package main;

sub POE::Kernel::TRACE_DEFAULT () {1}
sub POE::Kernel::TRACE_EVENTS ()  {1}
sub POE::Kernel::USE_SIGCHLD ()   {1}
use threads;
use threads::shared;
use Win32;
use Win32::Pipe;
use Time::HiRes qw/usleep/;
use Data::Dumper::Concise;

my (%hash) : shared;

POE::Session->create(
    inline_states => {
        _start => sub {
            $poe_kernel->delay( "do3", 1 );
        },
        _stop => sub {
            say "bye 3";
        },
        "do3" => sub {
            my $s = $poe_kernel->alias_resolve("main");
            $poe_kernel->post( $s, "google", 3 );
            my $s2 = $poe_kernel->alias_resolve("child");
            unless ($s2) {
                say "no businese!";
            }
        },
        "do4" => sub {
            say "here.....................do 4.....";
            }
    }
);

POE::Session->create(
    inline_states => {
        _start => \&Start,
        _stop  => sub {
            say "bye", Win32::GetCurrentThreadId();
        },
        do_fork => \&foox,

        _child => sub {
            say
                "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx||xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
            my ( $kernel, $signal_name ) = @_[ KERNEL, ARG0 ];
            say $signal_name;
            say Win32::GetCurrentThreadId();

            #$kernel->sig_handled();

        },
        _parent => sub {
            say "parent";
        },
        got_sig_child => sub {
            say "1234567890", Win32::GetCurrentThreadId();
            my ( $kernel, $heap, $child_pid ) = @_[ KERNEL, HEAP, ARG1 ];
            say "        $child_pid                   ";
            say "parent existed............................................";
        },
        child_do => sub {
            say "................................";
            say Dumper $_[HEAP];
            say "C===>", Win32::GetCurrentThreadId();
            $_[KERNEL]->post( $_[SESSION], "google" );
            say "[1;33m child     =>", $_[SESSION]->ID;
            say "[m";

            my $PipeName = "Test_Pipe";
            my $NewSize  = 2048;
            my $iMessage;

            while () {
                print "Creating pipe \"$PipeName\".\n";
                if ( my $Pipe = new Win32::Pipe($PipeName) ) {
                    my $PipeSize = $Pipe->BufferSize();
                    print "This pipe's current size is $PipeSize byte"
                        . ( ( $PipeSize == 1 ) ? "" : "s" )
                        . ".\nWe shall change it to $NewSize ...";
                    print +( ( $Pipe->ResizeBuffer($NewSize) == $NewSize )
                             ? "Successful"
                             : "Unsucessful"
                    ) . "!\n\n";

                    print "Openning the pipe...\n";
                    while ( $Pipe->Connect() ) {
                        while () {
                            ++$iMessage;
                            print "Reading Message #$iMessage: ";
                            my $In = $Pipe->Read();
                            unless ($In) {
                                print
                                    "Recieved no data, closing connection....\n";
                                last;
                            }
                            if ( $In =~ /^quit/i ) {
                                print "\n\nQuitting this connection....\n";
                                last;
                            }
                            elsif ( $In =~ /^exit/i ) {
                                print "\n\nExitting.....\n";
                                exit;
                            }
                            else {
                                print "\"$In\"\n";
                            }
                        }
                        print "Disconnecting...\n";
                        $Pipe->Disconnect();
                    }
                    print "Closing...\n";
                    $Pipe->Close();
                    exit 0;
                }
            }

        },
        dodo => sub {
            say "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
            say Dumper $_[HEAP];
            say "P===>", Win32::GetCurrentThreadId();
            $_[KERNEL]->post( $_[SESSION], "google" );
            say "[1;31m parent    =>", $_[SESSION]->ID;
            say "[m";
            my $PipeName = "\\\\.\\pipe\\Test_Pipe";
            print
                "I am falling asleep for few seconds, so that we give time\nFor the server to get up and running.\n";
            sleep(4);
            print "\nOpening a pipe ...\n";
            if ( my $Pipe = Win32::Pipe->new($PipeName) ) {
                print "\n\nPipe has been opened, writing data to it...\n";
                print "-------------------------------------------\n";
                $Pipe->Write( "\n" . Win32::Pipe::Credit() . "\n\n" );
                while () {
                    print "\nCommands:\n";
                    print "  FILE:xxxxx  Dumps the file xxxxx.\n";
                    print "  Credit      Dumps the credit screen.\n";
                    print
                        "  Quit        Quits this client (server remains running).\n";
                    print "  Exit        Exits both client and server.\n";
                    print "  -----------------------------------------\n";

                    my $In = <STDIN>;
                    chop($In);

                    if ( ( my $File = $In ) =~ s/^file:(.*)/$1/i ) {
                        if ( -s $File ) {
                            if ( open( FILE, "< $File" ) ) {
                                while ( $File = <FILE> ) {
                                    $In .= $File;
                                }
                                close(FILE);
                            }
                        }
                    }

                    if ( $In =~ /^credit$/i ) {
                        $In = "\n" . Win32::Pipe::Credit() . "\n\n";
                    }

                    unless ( $Pipe->Write($In) ) {
                        print "Writing to pipe failed.\n";
                        last;
                    }

                    if ( $In =~ /^(exit|quit)$/i ) {
                        print "\nATTENTION: Closing due to user request.\n";
                        last;
                    }
                }
                print "Closing...\n";
                $Pipe->Close();
            }
            else {
                my ( $Error, $ErrorText ) = Win32::Pipe::Error();
                print "Error:$Error \"$ErrorText\"\n";
                sleep(4);
            }

        },
        google => sub {
            my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
            say "[1;36m Google [m" if $heap->{is_a_child};
            say "[1;33m Microsoft [m" unless $heap->{is_a_child};
            say "[1m";
            return;
            }
    },
);

POE::Session->create(
    inline_states => {
        _start => sub {
            say "start 2";
        },
        _stop => sub {
            say "bye 2";
            }
    }
);

$poe_kernel->run;

sub Start {
    my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
    $kernel->alias_set("main");
    $heap->{children}   = {};
    $heap->{is_a_child} = 0;
    $kernel->sig( 'SIGCLD', '_child' );
    $poe_kernel->yield("do_fork");
}

sub foox {
    my ( $kernel, $heap ) = @_[ KERNEL, HEAP ];
    my $pid = fork;
    unless ($pid) {
        $kernel->has_forked;    # just one kernel
        $kernel->alias_set("child");
        $heap->{is_a_child} = 1;
        $heap->{children}   = {};
        say "child==>", Win32::GetCurrentThreadId();
        $kernel->delay( child_do => 2 );
        return;
    }
    say "parent", Win32::GetCurrentThreadId(), "  $$   ", $pid;
    $kernel->sig_child( $pid, "got_sig_child" );
    $heap->{children}->{$pid} = 1;
    $kernel->delay( dodo => 4 );
    return;
}
