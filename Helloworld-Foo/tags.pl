#! env perl
use strict;
use warnings;
use Wx qw( :allclasses );
my %seen;
my $content;
my $taglist;
for my $tag ( sort keys %Wx::EXPORT_TAGS ) {
    next if $tag =~ m{^(everything|all)$}xsm;
    $content .= qq(\n:$tag\n);
    $taglist .= qq(\t$tag\n);
    for my $exp ( @{ $Wx::EXPORT_TAGS{$tag} } ) {
        $content .= qq(\t$exp\n);
        $seen{$exp} = 1;
    }
}

print qq(TAGLIST\n $taglist \nTAGINDEX\n $content \nNO TAGS\n);
for my $exp ( @{ $Wx::EXPORT_TAGS{everything} } ) {
    print qq(\n$exp) unless $seen{$exp};
}
