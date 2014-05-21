#!/usr/bin/perl
use strict;
use warnings;
use feature ':5.14';
use Data::Dumper::Concise;
use Template;
use Carp qw /croak carp confess/;

use Mason::Tidy;
my $source = 'd.mc';
my $mc = Mason::Tidy->new( mason_version => 2 );
my $dest = $mc->tidy($source);
