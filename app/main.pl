use feature ":5.14";
say "perl project ";

package main;

use Data::Dumper::Concise;

use WWW::Curl::Simple;
use HTTP::Request;
use HTTP::Headers;

$h = HTTP::Headers->new(
  User_Agent   => 'Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 6.0)',
  Accept  =>'*/*',
  );

  $fake = HTTP::Request->new( 'GET', 'http://www.example.com/', $h );
  say Dumper $fake;



my $curl =
    WWW::Curl::Simple->new( ssl_cert_bundle =>
        "D:\\Curl\\curl-7.33.0-win32\\curl-7.33.0-win32\\bin\\curl-ca-bundle.crt"
    );

 $curl->add_request($fake);
 @r = $curl->perform; #--->make many simple-require 

 say "[1;32m";
 say Dumper $r[0]->perform;# curllib backend  return many HTTP::Response 
 say "[m"
#

#my $res = $curl->get('http://www.renren.com/');
#
#if ( $res->is_success ) {
#
#    #print $res->decoded_content;
#    #$res->decoded_content;
#    $service = $res->header("Set-Cookie");
#    $cookie = {};
#    for ( split /;/, $service ) {
#        if (m{(\w+)=(.+)|(\w+)}x) {
#            if ( !$2 && !$1 ) {
#                $cookie->{$3} = [];
#                next;
#            }
#            if ( !$cookie->{$1} ) {
#                $cookie->{$1} = [$2];
#            }
#            else {
#               push $cookie->{$1} , $2;
#            }
#        }
#    }
#    say Dumper($cookie);
#
#    say "Server  [1;33m",$res->header("Server"),"[m";
#    say "HTTP ETag  " ,$res->header("ETag");
#    say "Content-Type   " ,$res->header("Content-Type");
#    say "Date   " ,$res->header("Date");
#    say "Connection   " ,$res->header("Connection");
#    say "Vary   " ,$res->header("Vary");
#    say "Last-Modified   " ,$res->header("Last-Modified");
#    say "X-UA-Compatible   " ,$res->header("X-UA-Compatible");
#    say "X-Powered-By   " ,$res->header("X-Powered-By");
#    say "P3P   " ,$res->header("P3P");
#    say "Age   " ,$res->header("Age");
#    say "Via   " ,$res->header("Via");
#    say "Transfer-Encoding   " ,$res->header("Transfer-Encoding");
#}
#else {
#    print STDERR $res->status_line, "\n";
#}
#
