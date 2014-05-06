use feature ":5.14";
use Data::Dumper::Concise;
use Scalar::Util qw/dualvar/;
use List::Util qw/any pairfirst  pairgrep pairmap/;

my @a = ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 );
my %a = @a;

say keys @a, " || ", values @a;

use threads ( 'yield',
              'stack_size' => 64 * 4096,
              'exit'       => 'threads_only',
              'stringify'
);

sub start_thread {
    my @args = @_;
    print( 'Thread started: ', join( ' ', @args ), "\n" );
    yield while 1;
}
my $thr = threads->create( 'start_thread', 'argument' );
say Dumper $thr;
my $t =threads->self();
say Dumper $t;
$thr->kill('die');
$thr->join();

threads->create( sub { print("I am a thread\n"); } )->join();

