package Testaa;

use strict;
use Win32::API;
use Win32::API::Callback;
use warnings;
use version; our $VERSION = qv('0.0.1');
my $callback = Win32::API::Callback->new(
    sub {
        print " [1;32m luck ...xx.....\n [m";
        my ( $a, $b, $c ) = @_;
        printf "%d %d %d \n", $a, $b, $c;
    },
    'PNN',
    'V'
);
Win32::API::More->Import( 'kernel32', 'GetLastError',        'V',      'N' );
Win32::API::More->Import( 'kernel32', 'CreateWaitableTimer', 'PNP',    'N' );
Win32::API::More->Import( 'kernel32', 'SetWaitableTimer',    'NPNKPN', 'N' );
Win32::API::More->Import( 'kernel32', 'SleepEx',             'NN',     'N' );
Win32::API::More->Import( 'kernel32', 'CloseHandle',         'N',      'N' );

sub showerror {
    use Win32;
    my $a     = GetLastError();    #203 is good
    my $s     = q{[1;31m};
    my $e     = q{[m};
    my $token = '%s';

    printf "$token $token $token", $s, Win32::FormatMessage($a), $e;
    return;

    # printf "$s"."%s"."$e", Win32::FormatMessage($a);
}

{
    my $htimer = CreateWaitableTimer( 0, 0, 'timers' );
    if ($htimer) {
        print "OK ...\n";

        my $bsuccess
            = SetWaitableTimer( $htimer, t64(1), 1000, $callback, 0, 0 );
        if ($bsuccess) {
            SleepEx( -1, 1 );
        }
        else {
            showerror;
        }

    }
    else {
        showerror;
    }
    CloseHandle($htimer);
}

sub t64 {
    my $t = shift;
    $t = ~($t);
    return pack 'LL', $t, 0xFFFFFFFF;
}
1;
