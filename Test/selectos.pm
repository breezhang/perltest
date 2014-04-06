# just for patch win32
#use subs qw /nanosleep/;
#
#sub nanosleep {
#   use Time::HiRes;
#   if($^O == "MSWin32") {
#       Time::HiRes->usleep(shift);
#       return;
#   }
#   Time::HiRes->nanosleep(shift);
#}
#

use feature ":5.14";
use Data::Dumper::Concise;

say "helloworld";

$test = {};

say Dumper $test;





