#! perl -- ## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;
use feature ':5.14';
use Data::Dumper::Concise;
use Carp;
use Pithub;
use LWP::UserAgent;

sub get_token {
    my $pt = $ENV{HOME} . '\.gist-vim';
    open my $FH, '<', $pt || croak;
    my %tok = split / /, ( grep { chomp; /token\s+[0-9a-g]+/x; } <$FH> )[1];
    close $FH;
    return $tok{token};
}

#demo repo
my $ua = LWP::UserAgent->new(
    agent =>
        'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)',
    timeout => 180
);

my $p = Pithub::Repos->new( token => get_token(),
                            ua    => $ua,
                            user  => 'breezhang'
);

# many branches ========================

#my $result = $p->branches(user => 'breezhang',repo => 'perltest');
#if ( $result->success ) {
#    say $_->{name} for(@{$result->content})
#}
#
#touch README.md
#git init
#git add README.md
#git commit -m "first commit"
#git remote add origin git@github.com:breezhang/for-test-project.git
#git push -u origin master
#

#====================demo new repos=========================
#my $result = $p->create( data => {
#                               name        => 'for-test-project',
#                               description => 'This is your first repository',
#                               auto_init   => 0,
#                               license_template => 'mit',
#                               homepage         => 'https://ooxx.com'
#                         }
#);
#
#if ( $result->success ) {
#    say Dumper $result->content;
#}

#how about get

# $result = $p->get(user => 'breezhang',repo => 'perltest');
#if ( $result->success ) {
#    my $r =$result->content;
#    printf "url =>%s \n id=> %s \n language =>%s \n name=> %s \n",$r->{html_url}
#    ,$r->{id},$r->{language},$r->{name};
#}
#

#my $re  = Pithub::Repos->new;
#my $result = $re->list(user=>'breezhang');
#
#if($result->success) {
#      for (@{$result->content}){
#     printf "%s => %s\n",$_->{full_name} ||'bree',$_->{language} ||'??';
#    }
#}



#just for fun 
#=============================
my $hooks = ` curl --get  https://api.github.com/users/breezhang/repos -d "{\"type\":\"member\"}" `;

use JSON::XS;

my $recoder = decode_json $hooks;

say scalar  @{$recoder};






