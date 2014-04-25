use Win32::API;
use Win32::API::Callback;

my $callback = Win32::API::Callback->new( sub {
      print " [1;32m luck ...xx.....\n [m";
      my ($a,$b,$c) =@_;
      printf "%d %d %d \n",$a,$b,$c;
      },
    "PNN",
    "",
);
Win32::API::More->Import( "kernel32", 'GetLastError',        '',       'N' );
Win32::API::More->Import( "kernel32", 'CreateWaitableTimer', 'PNP',    'N' );
Win32::API::More->Import( "kernel32", 'SetWaitableTimer',    'NPNKPN', 'N' );
Win32::API::More->Import( "kernel32", 'SleepEx',             'NN',     'N' );
Win32::API::More->Import( "kernel32", 'CloseHandle',   'N', 'N' );

sub showerror {
    use Win32;
    $a = GetLastError();    #203 is good
    printf "[1;31m %s [m",Win32::FormatMessage($a);
}

$hTimer = CreateWaitableTimer( 0, 0, "timers" );
if ($hTimer) {
    print "OK ...\n";

    $bSuccess = SetWaitableTimer( $hTimer, t64(1), 1000, $callback, 0, 0 );
    if ($bSuccess) {
            SleepEx( -1, 1 );
    }
    else {
        showerror;
    }

}else{
   showerror;
}
CloseHandle($hTimer);

sub t64 {
    my $t  = shift;
    my $t  = ~($t);
    my $aa = pack( "LL", $t, 0xFFFFFFFF );
}
