use Win32::API;
use Win32::API::Callback;
use Data::Dumper::Concise;
use Win32;

my $Callback = Win32::API::Callback->new(
    sub {
        print Win32::GetCurrentThreadId(),"\n";
        print "OOOOOOOOOOOOOOOOOOOOOOOOOOO\n";
        SetEvent($x);
    },
    'PN',
    ''
);

print "\n xxxx 0  ",Win32::GetCurrentThreadId(),"\n";

Win32::API::More->Import( "kernel32", 'CreateTimerQueueTimer',   'PNKPNNN', 'N' );
Win32::API::More->Import( "kernel32", 'CreateTimerQueue',   'V', 'N' );
Win32::API::More->Import( "kernel32", 'CreateEvent',   'NNNN', 'N' );
Win32::API::More->Import( "kernel32", 'SetEvent',   'N', 'N' );
Win32::API::More->Import( "kernel32", 'WaitForSingleObject',   'NN', 'N' );
Win32::API::More->Import( "kernel32", 'CloseHandle',   'N', 'N' );
Win32::API::More->Import( "kernel32", 'DeleteTimerQueue',   'N', 'N' );
Win32::API::More->Import( "kernel32", 'GetLastError',   '', 'I' );
Win32::API::More->Import( "kernel32", 'SleepEx',             'NN',     'N' );



print Dumper $x;
my $a = pack( "L", 0 ); 
my $a1 =CreateTimerQueue();


print "...........\n" if $a1;
;
SleepEx(1,-1);
if($y){
CloseHandle($x);
DeleteTimerQueue($y);
print "\n xxx1  ",Win32::GetCurrentThreadId(),"\n";
}
print Dumper GetLastError(),"\n";
