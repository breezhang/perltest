#!perl
use strict;
use warnings;
use Data::Dumper::Concise;
use feature ':5.14';
use Template;
use Carp;
my $tt = Template->new;

my @teams = ( {  name   => 'Man Utd',
                 played => 16,
                 won    => 12,
                 drawn  => 3,
                 lost   => 1
              },
              {  name   => 'Bradford',
                 played => 16,
                 won    => 2,
                 drawn  => 5,
                 lost   => 9
              }
);

my %data = ( name   => 'English Premier League',
             season => '2000/01',
             teams  => \@teams
);

my $temple = <<'EOF';
League Standings
 
League Name: [% name %]
Season     : [% season %]
 
Teams:
[% FOREACH team = teams -%]
[% team.name %] [% team.played -%] [% team.won %] [% team.drawn %] [% team.lost %]
[% END %]
EOF

$tt->process( \$temple, \%data, 'c:\\google.textfile', binmode => ':utf8' )
    || croak $tt->error;

my $file;
my $var = do {
    local $/ = \8;
    open $file, '<', "c:\\google.textfile" || croak;
    <$file>;
};
say $var if $file;

close $file;

