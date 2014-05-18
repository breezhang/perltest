package test;

use strict;
use warnings;
use base 'Template::Plugin';
use Template::Exception;

use overload
    q|""|    => "text",
    fallback => 1;

our $VERSION = 0.0.1;
our $ERROR   = '';

sub text {
}

sub new {
    my ( $class, $context, @params ) = @_;

    return bless {

        _CONTEXT => $context,

        _PARAMS => \@params,

        },
        $class;    # returns blessed MyPlugin object

}

sub load {
    my ( $class, $context ) = @_;

    return $class;    # returns 'MyPlugin'

}
1;
