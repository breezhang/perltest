use Win32::API;

use Win32::API::Callback;

use feature ":5.14";

use Data::Dumper::Concise;

use Win32::Event;

sub WAIT_IO_COMPLETION {192} 
sub WAIT_OBJECT_0      {0}
sub WAIT_TIMEOUT       {0x102}
sub WAIT_FAILED        {-1}
sub WAIT_ABANDONED     {0x80}

BEGIN {
    $Win32::API::DEBUG = 1;
}

Win32::API->Import(
    'Kernel32', q[
    BOOL DuplicateHandle( HANDLE hSourceProcessHandle,
        HANDLE hSourceHandle, HANDLE hTargetProcessHandle,
        LPHANDLE lpTargethandle, DWORD dwDesiredAccess,
        BOOL bInheritHandle, DWORD dwOptions )
]
) or die $^E;
Win32::API->Import( 'Kernel32', q[ HANDLE GetCurrentProcess() ] ) or die $^E;
Win32::API->Import( 'Kernel32', q[ HANDLE GetCurrentThread() ] )  or die $^E;
Win32::API->Import( 'Kernel32',
                q[ BOOL SetThreadPriority( HANDLE hThread, int nPriority ) ] )
    or die $^E;
Win32::API->Import( 'Kernel32', q[ int GetThreadPriority( HANDLE hThread ) ] )
    or die $^E;

Win32::API::More->Import( "Kernel32", 'QueueUserAPC', 'KNP',  'N');
Win32::API::More->Import( "kernel32", 'SleepEx',   'NN',     'N' );
Win32::API::More->Import( "kernel32", 'WaitForSingleObjectEx',   'NNN',     'N' );
Win32::API::More->Import( "kernel32", 'CreateEvent',   'PNNP',     'N' );
Win32::API::More->Import( "kernel32", 'SetEvent',   'N',     'N' );

my $s = CreateEvent(0,1,0,"Just Test"); 
#
#
#        NULL,               // default security attributes
#        TRUE,               // manual-reset event
#        FALSE,              // initial state is nonsignaled
#        TEXT("WriteEvent")  // object name
#

my $APCcallback = Win32::API::Callback->new(
    sub {
        say "APC CALL!";
        SetEvent(unpack("L",shift));
        return 0;
    },
    "P",
    "N",
);


$h = GetCurrentThread();

QueueUserAPC($APCcallback,$h,pack("L",$s));

my $res=WaitForSingleObjectEx($s,-1,1); #For APC

say Dumper $res;

#while(){SleepEx(1,-1)}; #For APC




