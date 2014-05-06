use Storable qw(store retrieve freeze thaw dclone);
print $0;
print "\n";
use Cwd;
use File::Basename;
my $dir = getcwd;
use Data::Dumper::Concise;
print $dir;
print "\n";
print basename($0);
system "cls";
` pwd `;
%color = ( 'Blue' => 0.1, 'Red' => 0.8, 'Black' => 0, 'White' => 1 );

store( \%color, $dir . '\tmp\colors' )
    or die "Can't store %a in /tmp/colors!\n";

$colref = retrieve( $dir . '\tmp\colors' );

die "Unable to retrieve from /tmp/colors!\n" unless defined $colref;

printf "Blue is still %lf\n", $colref->{'Blue'};

$colref2 = dclone( \%color );

print Dumper $colref2;

$str = freeze( \%color );

printf "Serialization of %%color is %d bytes long.\n", length($str);

$colref3 = thaw($str);
