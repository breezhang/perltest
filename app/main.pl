use feature ":5.14";
say "perl project ";

package main;

use Data::Dumper::Concise;

use WWW::Curl::Simple;

my $curl = WWW::Curl::Simple->new();

my $res = $curl->get('http://www.163.com/');

if ( $res->is_success ) {

    #print $res->decoded_content;
    #$res->decoded_content;
    say $res->code;
    say $res->message;
    say $res->header("Access-Control-Allow-Origin");
    say "Age ",$res->header("Age");
    say "Range",$res->header("Accept-Ranges");
    say $res->header("Content-MD5");
    say $res->header("Content-MD5");
}
else {
    print STDERR $res->status_line, "\n";
}

