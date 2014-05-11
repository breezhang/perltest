#!perl
use strict;
use warnings;
use feature ':5.14';
use Pithub;
use Data::Dumper::Concise;

#
#demo search  if search github no passport ye!


my $p = Pithub::Search->new;

my $r = $p->email(email => 'troups.kid.joey@gmail.com');

say Dumper $r->content;

