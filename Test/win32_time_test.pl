use feature ":5.14";
use Win32::API;
use Data::Dumper::Concise;

BEGIN {
    $Win32::API::DEBUG = 1;
}

Win32::API::More->Import( "kernel32", 'QueryPerformanceCounter',   'P', 'N' );
Win32::API::More->Import( "kernel32", 'QueryPerformanceFrequency', 'P', 'N' );
Win32::API::More->Import( "ntdll", 'NtQueryTimerResolution', 'PPP', 'V' );
Win32::API::More->Import( "ntdll", 'NtDelayExecution',       'NP',  'V' );

sub clock_win32 {
    my $count = pack( "b64", 0 );
    QueryPerformanceCounter($count);
    my ( $clo, $chi ) = unpack( "ll", $count );
    $clo + $chi * 4 * 1024**3;
}

sub freq {
    my $count = pack( "b64", 0 );
    QueryPerformanceFrequency($count);
    my ( $clo, $chi ) = unpack( "ll", $count );
    $clo;
}

$a = clock_win32();
say;
say;
$f = freq();
$b = clock_win32();

print( ( ( $b - $a ) / $f ) * 1000 );

my ( $min, $max, $cur ) = ( pack( "l", 0 ), pack( "l", 0 ), pack( "l", 0 ) );

NtQueryTimerResolution( $min, $max, $cur );

say;
printf "max %f ms  min %f ms sys %f ms \n", unpack( "l", $min ) / 10000,
    unpack( "l", $max ) / 10000, unpack( "l", $cur ) / 10000;

sub del100ns {
    my $t= shift;
    my $t = ~($t -1 );
    my $aa = pack( "LL", $t, 0xFFFFFFFF );
    NtDelayExecution( 0, $aa );
}

$a = clock_win32();
del100ns(10);
$b = clock_win32();

print( ( ( $b - $a ) / $f ) );

