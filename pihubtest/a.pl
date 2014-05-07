#!
#just tell syn check not pm file
use strict;
use warnings;
use Pithub;
use LWP::UserAgent;
use Data::Dumper::Concise;
use feature ':5.14';

#new
my $token = q{21867e7832cf596f2d68653c5063fd033d2cb4dd};

my $ua = LWP::UserAgent->new(
    agent =>
        'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)',
    timeout => 180
);

my $p = Pithub::Gists->new( token => $token, ua => $ua, user => 'breezhang' );

my $result = $p->get( gist_id => '9969380' );
if ( $result->success ) {
    #print $result->content->{html_url};
    my @list = %{$result->content->{files}};
    print @list;
}

