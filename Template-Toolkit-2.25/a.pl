#!perl
use strict;
use warnings;
use feature ':5.14';
use Data::Dumper::Concise;
use Template;
use Carp qw /croak carp confess/;

my $config = {
    INCLUDE_PATH => 'Template',  # or list ref
    INTERPOLATE  => 1,               # expand "$var" in plain text
    POST_CHOMP   => 1,               # cleanup whitespace
    #PRE_PROCESS  => 'header',        # prefix each template
    EVAL_PERL    => 1,               # evaluate Perl code blocks
    CACHE_SIZE   =>1024*8,
    COMPILE_DIR  => "$ENV{APPDATA}\\Local\\Temp",
    DEBUG =>1
};

say "$ENV{APPDATA}\\Local\\Temp";


my $tt2 = Template->new($config);

$tt2->process('welcome.tt2') || croak $tt2->error(), "\n";
$tt2->process('goodbye.tt')  || croak $tt2->error(), "\n";
$tt2->process('wrapper.tt2') || croak $tt2->error(), "\n";
$tt2->process('example.tt2') || croak $tt2->error(), "\n";
