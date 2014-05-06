use strict;
use warnings;
use Wx qw( :allclasses );
my %seen;
my $content;
my $taglist;
for my $tag ( sort keys(%Wx::EXPORT_TAGS) ) {
    next if $tag =~ /^(everything|all)$/;
    $content .=  qq(\n:$tag\n);
    $taglist .= qq(\t$tag\n);
    for my $exp (@{ $Wx::EXPORT_TAGS{$tag} }) {
        $content .=  qq(\t$exp\n);
        $seen{$exp} = 1;
    }
}

print qq(TAGLIST\n);
print $taglist;
print qq(\nTAGINDEX\n);
print $content;
print qq(\nNO TAGS\n);
for my $exp (@{ $Wx::EXPORT_TAGS{everything} }) {
    print qq(\n$exp) if !$seen{$exp};
}
