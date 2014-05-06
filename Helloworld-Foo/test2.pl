use feature ":5.14";
use Win32;

say "[1;37m",Win32::GetCurrentThreadId(),"[m";
 
if(!fork()) {
    say "   child:==>      ","[1;32m",Win32::GetCurrentThreadId(),"[m";
    Win32::MsgBox("Helloworld" , 2);
    exit(0);
  }
say "[1;34m",Win32::GetCurrentThreadId(),"[m";
sleep while 1; # Loop forever
