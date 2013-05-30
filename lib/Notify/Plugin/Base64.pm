package Notify::Plugin::Base64;

use strict;
use warnings;
use MIME::Base64;
use MIME::Types qw/by_suffix/;

our $VERSION = 0.01;
our $TYPE    = 'filter';

sub hook {
    my ( $IN,$opt,$note ) = @_;
    $note->{base64} = 1; # flag for next phase
    $note->{filename} = $opt->{filename}
        or die "Require filename";
    ( $note->{type} ) = $opt->{type} || by_suffix( $opt->{filename} );
    $$IN = encode_base64( $$IN );
}
1;
