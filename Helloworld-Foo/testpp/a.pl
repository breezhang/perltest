use feature ":5.14";
use POE;

POE::Session->create(
    inline_states => {
        _start => \&start
        ,
        helloA => sub {
          say "yes";
        },
        run => sub {
         say "o";
         $_[KERNEL]->delay(run=>1);
        }
    }
);

POE::Session->create(
    inline_states => {
        _start => sub {
          $_[KERNEL]->sig(A=>'helloB');
          $_[KERNEL]->delay(run=>1);
        }
        ,
        helloB => sub {
          say "No";
        },
        run => sub {
          say "x";
          $_[KERNEL]->delay(run=>1);
          $_[KERNEL]->signal($_[KERNEL],'A');
        }
    }
);

sub start {
    $_[KERNEL]->sig(A=>'helloA');
    $_[KERNEL]->delay(run=>1);
}

$poe_kernel->run;

exit 0;

