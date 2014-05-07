#!
use strict;
use warnings;
use Pithub;
use LWP::UserAgent;
use Data::Dumper::Concise;
use feature ':5.14';
use Carp;

sub get_token {
    my $pt = $ENV{HOME} . '\.gist-vim';
    open my $FH, '<', $pt || croak;
    my %tok = split / /, ( grep { chomp; /token\s+[0-9a-g]+/x; } <$FH> )[0];
    close $FH;
    return $tok{token};
}

{
    my $ua = LWP::UserAgent->new(
        agent =>
            'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)',
        timeout => 180
    );

    my $p = Pithub::Gists->new( token => get_token(),
                                ua    => $ua,
                                user  => 'breezhang'
    );

    my $result = $p->get( gist_id => '9969380' );
    if ( $result->success ) {

        my @list = %{ $result->content->{files} };
        print @list;
    }

    $result = $p->create(
          data => {
              description => 'the description for this gist',
              public      => 1,
              files => { 'file1.txt' => { content => 'String file content' } }
          }
    );
    my $myid;
    if ( $result->success ) {
        $myid = $result->content->{id};
        printf "The new gist is available at %s     %s\n",
            $result->content->{html_url}, $result->content->{id};

    }

    $result = $p->delete( gist_id => $myid );
    if ( $result->success ) {
        print "The gist $myid has been deleted\n";
    }


    my $result = $p->list();
    if ( $result->success ) {
        while ( my $row = $result->next ) {
            printf "%s => %s\n", $row->{html_url},
                $row->{description} || 'no description';
        }
    }

    say "demo done ";

}
