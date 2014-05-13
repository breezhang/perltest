#!perl
use strict;
use warnings;
use feature ':5.14';
use Data::Dumper::Concise;
use Template;
use Carp qw /croak carp confess/;

my $config = {
    INCLUDE_PATH => '/search/path',  # or list ref
    INTERPOLATE  => 1,               # expand "$var" in plain text
    POST_CHOMP   => 1,               # cleanup whitespace
    PRE_PROCESS  => 'header',        # prefix each template
    EVAL_PERL    => 1,               # evaluate Perl code blocks
};


my $tt2 = Template->new(INCLUDE_PATH => 'Template', POST_CHOMP => 1);

$tt2->process('welcome.tt2') || croak $tt2->error(), "\n";
