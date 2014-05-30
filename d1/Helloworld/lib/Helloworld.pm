package Helloworld;
use Dancer ':syntax';

use Dancer::Template::Mason;
use strict;
use warnings;
use Carp qw /croak carp confess/;

our $VERSION = '0.1';

hook 'before_template_render' => sub {
    my $tokens = shift;
    $tokens->{foo} = 'bar';
};

get '/' => sub {
    info request->uri_base();
    template 'index' ; 
};

1;
