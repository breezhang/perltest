
use subs qw /nanosleep/;

sub nanosleep {
   use Time::HiRes;
   if($^O == "MSWin32") {
       Time::HiRes->usleep(shift);
       return;
   }
   Time::HiRes->nanosleep(shift);
}




