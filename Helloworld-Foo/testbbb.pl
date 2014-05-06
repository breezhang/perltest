use strict;
use warnings;

use feature ':5.14';
use Wx;

#use version; our $VERSION = qv('0.0.1');

my $app = Wx::SimpleApp->new;
my $frame = Wx::Frame->new( undef, -1, 'helloworld' );

$frame->Show;
$app->MainLoop;
1;

