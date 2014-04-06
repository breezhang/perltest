use feature ":5.14";
say "perl project ";

package main;

use Data::Dumper::Concise;

use WWW::Curl::Simple;

my $curl =
    WWW::Curl::Simple->new( ssl_cert_bundle =>
        "D:\\Curl\\curl-7.33.0-win32\\curl-7.33.0-win32\\bin\\curl-ca-bundle.crt"
    );
my $res = $curl->get('https://www.google.com/');

if ( $res->is_success ) {

    #print $res->decoded_content;
    #$res->decoded_content;
    $service = $res->header("Set-Cookie");

    $cookie = {};
    for ( split /;/, $service ) {
        if (m{(\w+)=(.+)|(\w+)}x) {
            if ( !$2 && !$1 ) {
                $cookie->{$3} = [];
                next;
            }
            if ( !$cookie->{$1} ) {
                $cookie->{$1} = [$2];
            }
            else {
               push $cookie->{$1} , $2;
            }
        }
    }

    say Dumper($cookie);

}
else {
    print STDERR $res->status_line, "\n";
}

