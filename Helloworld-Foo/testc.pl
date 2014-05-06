package foo ;
use feature ":5.14";
use Data::Dumper::Concise;


package main ;
use feature ":5.14";
use Data::Dumper::Concise;
use POE;
my @sessions = (
POE::Session->create(
    inline_states =>{
        _start => sub {
             $_[KERNEL]->delay( tick => 1, 1 );
             $_[KERNEL]->post($_[SESSION],'say_message',"one","two","three");
        },
        tick =>sub {
         say @_[ARG0..$#_];
        },
        say_message =>\&eventhandler,
    },
),
POE::Session->create(
    inline_states =>{
        _start => sub {
             $_[KERNEL]->delay( tick => 1, 2 );
        },
        tick =>sub {
         say @_[ARG0..$#_];
         say "x" while 1;
        },
    },
),
POE::Session->create(
    inline_states =>{
        _start => sub {
             $_[KERNEL]->delay( tick => 1, 3 );
        },
        tick =>sub {
         say @_[ARG0..$#_];
         print "." while 1;
        },
    },
),
POE::Session->create(
    inline_states =>{
        _start => sub {
             $_[KERNEL]->delay( tick => 1, 4 );
        },
        tick =>sub {
         say @_[ARG0..$#_];
        },
    },
),

);

for(@sessions) {
  $poe_kernel->post($_,'tick',1,2,3,4,5,6);
  $poe_kernel->call($_,'tick',110);
}


POE::Kernel->run();
exit 0;

sub eventhandler {
 say @_[ARG0..$#_];

}
