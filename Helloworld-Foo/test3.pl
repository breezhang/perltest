use warnings;
use strict;
use POE;
use Win32;
use feature ':5.14';
use POE::Wheel::FollowTail;
$|++;
my $file = $ARGV[0] || 'C:\\a.file' || croak 'No file to watch';
POE::Session->create( inline_states => { _start     => \&main,
                                         got_record => \&got_record,
                      },
                      args => [$file],
);
$poe_kernel->run();
exit 0;

sub main {
    my ( $heap, $log_file ) = @_[ HEAP, ARG0 ];
    my $watcher =
        POE::Wheel::FollowTail->new( Filename   => $log_file,
                                     InputEvent => "got_record", );
    return $heap->{w} = $watcher;

}

sub got_record {
    my $log_record = $_[ARG0];
    print $log_record, "\n";
    return;
}
