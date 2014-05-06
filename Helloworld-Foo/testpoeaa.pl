
use warnings;
use strict;

use POE;
use POE::Component::Child;

my $debug = 0;

# By default Child throws the key names but you can remap as desired.
# It's especially useful when running multiple concurrent children.

my %events = (
  stdout => "my_stdout",
  stderr => "my_stderr",
  error  => "my_error",
  done   => "my_done",
  died   => "my_died",
);

# By default Child throws events at a session with the alias "main".
# In fact, all this could be wrapped into another module in a
# different package.

POE::Session->create(
  package_states => ["main" => [values(%events)]],
  inline_states  => {
    _start => sub { $_[KERNEL]->alias_set("main"); },
    _stop  => sub { print "_stop" if $debug; },
  }
);

# Start a child process.

my $c = POE::Component::Child->new(
  events => \%events,
  debug  => $debug
);

# Run something in the child process.

$c->run("ls");

# POEtry in motion.

POE::Kernel->run();
exit;

# These are the "main" event handlers.

sub my_stdout {
  my ($self, $args) = @_[ARG0 .. $#_];
  print "- ", $args->{out}, $/;
}

sub my_stderr {
  my ($self, $args) = @_[ARG0 .. $#_];
  print ">> $args->{out}";
}

sub my_done {
  print "child done\n";
}

sub my_died {
  print "child died!\n";
}

sub my_error {
  my ($self, $args) = @_[ARG0 .. $#_];
  print "yikes! $args->{error}\n";
}
