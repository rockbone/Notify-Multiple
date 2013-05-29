package Notify::Plugin::Base64;

use strict;
use warnings;
use MIME::Base64;

our $VERSION = 0.01;
our $TYPE    = 'filter';

sub hook {
    my ( $IN,$opt,$note ) = @_;
    $note->{base64} = 1; # flag for next phase
    @$note{qw/filename type/} = @$opt{qw/filename type/};
    $$IN = encode_base64( $$IN );
}
1;
