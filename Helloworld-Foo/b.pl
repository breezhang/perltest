# Context:

#The correct way to do this is by using SetPriorityClass() on your process and setting it to IDLE_PRIORITY_CLASS. That will allow your process to use upto 100% of the cpu when nothing else is using the cpu, but will never slow any other processes down by preventing them from access. It's far more accurate than anything than you could code yourself; it will avoid imposing calculation overhead upon the system as the scheduler already has all the information it needs available to it; and it is just much easier. 

#  The code:

#To set thread priorities you will need to use Win32::API to gain access to SetThreadPriority(). 

#In order to use that call, you will need a thread handle

#There is a native API that will return the handle for the currently running thread GetCurrentThread() and you can get at that through Win32::API. 



#The following snippet sets 7 threads running, has them query their thread handles, duplicate them for use in other threads and set up the tid->handle mapping in a shared hash. 

#Thead handles:

# HANDLE hSourceProcessHandle,
# HANDLE hSourceHandle
# HANDLE hTargetProcessHandle
# HANDLE GetCurrentProcess()
# HANDLE GetCurrentThread()
# HANDLE hThread,
# HANDLE hThread


#The main thread then sets their priorities, one at each of those possible, before setting the $go flag and allowing them to run for 10 seconds. Once they get the off, each thread attempts to relinguish its timeslice 2 million times, counting them as it does so; before printing out its priority and the count of timeslices it was allocated before it reached 2 million or ran out of time. 


use strict;
use threads;
use threads::shared; #http://perldoc.perl.org/threads/shared.html
use Win32::API;

$| = 1;

Win32::API->Import( 'Kernel32', q[
    BOOL DuplicateHandle( HANDLE hSourceProcessHandle,
        HANDLE hSourceHandle, HANDLE hTargetProcessHandle,
        LPHANDLE lpTargethandle, DWORD dwDesiredAccess,
        BOOL bInheritHandle, DWORD dwOptions )
] ) or die $^E;
Win32::API->Import( 'Kernel32', q[ HANDLE GetCurrentProcess() ] ) or die $^E;
Win32::API->Import( 'Kernel32', q[ HANDLE GetCurrentThread() ] ) or die $^E;
Win32::API->Import( 'Kernel32', 
    q[ BOOL SetThreadPriority( HANDLE hThread, int nPriority ) ] ) or die $^E;
Win32::API->Import( 'Kernel32', 
    q[ int GetThreadPriority( HANDLE hThread ) ] ) or die $^E;

my %threads : shared;  # The return file.  See http://perldoc.perl.org/attributes.html for explanation of strange syntax
my $running : shared = 0; # http://perldoc.perl.org/threads/shared.html
my $go      : shared = 0; #"shared" means that two (or more) different threads can physically access the same variable.

#Likely, the child thread will clear $running, and the parent thread will see that.



#$running : shared = 0; .... does that mean that only two can access the same variable (or none)
#[bart]: No, it means you're setting the value of that shared variable there. 
#[castaway]: Win, it means that all threads see the same value in that variable.. it has nothing to do with the access.. and the =0 just sets that value 


sub thread{
    my $tid = threads->self->tid;
    my $hProc = GetCurrentProcess();
    my $hThread;
    DuplicateHandle($hProc, GetCurrentThread(), $hProc, $hThread, 0, 0, 2 );
    $threads{ $tid } = $hThread;
    print "$tid started h($hThread)";
    ++$running;

    my $count = 0;
    Win32::Sleep 1 until $go;

    for ( 1 .. 2_000_000 ) {
        $count++ and Win32::Sleep 1;  # Win32::Sleep  sleeps 1 milliscecond
        last if !$go;
    }
    printf "tid($tid) priority(%d) received $count timeslices\n",
        GetThreadPriority( GetCurrentThread() );
    --$running;
}


my @priorities = ( -15, -2, -1, 0, 1, 2, +15 );
my @threads = map{ threads->create( \&thread ) } 0 .. $#priorities;

sleep 1 until $running == @threads;

SetThreadPriority( $threads{ $_ + 1 }, $priorities[ $_ ] )  or die $^E for 0 .. $#priorities;

$go = 1;

sleep 10;

$go = 0;

sleep 1 while $running; # sleep while $running contains a true value

