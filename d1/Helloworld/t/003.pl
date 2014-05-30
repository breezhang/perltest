#!/usr/bin/perl
use strict;
use warnings;
use feature ':5.14';
use Data::Dumper::Concise;
use Template;
use Carp qw /croak carp confess/;

my $toto = 'this+is+my+text';
$toto =~tr/+/:/;

my $string = 'my name is sam anderson';
my $s2 = 'google is killer microsoft!';
my $s3 = 'google is killer microsoft!';
say $string;
$string =~ tr/a-z/ABCDE/;
$s2 =~ tr/ -~/10/;
$s3 =~ tr/ -~/01/;
say $string;
say $s2;
say $s3;

say $toto;

my $str = '\t';
say "\Q$str";

my @name = qw /a b c d e f/ ;

say scalar @name ;
shift @name;
say scalar @name;
unshift @name ,'a';

for(@name) {
    say $_;
}
