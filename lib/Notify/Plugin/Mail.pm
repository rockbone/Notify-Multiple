package Notify::Plugin::Mail;

use strict;
use warnings;
use Net::SMTP;
use Encode;

our $VERSION = 0.1;

chomp( my $host = `hostname` );
my $DEFAULT_SENDER = "notify_multiple\@$host";

# argment
# TO FROM SUBJECT
my %arg;
sub hook {
    my ( $IN,$arg ) = @_;
    if ( !$arg->{to} ){
        die "mail recipient is not specified\n";
    }
    
    sendmail( $$IN,$arg );
}

sub sendmail {
    my ( $IN,$arg ) = @_;
    my $subject = $arg->{subject} ? encode( "MIME-Header-ISO_2022_JP",$arg{SUBJECT} ) : "";
    my $msg  = encode( "iso-2022-jp",$IN );
    my $from = $arg->{from} || $DEFAULT_SENDER;
    my $to   = $arg->{to};
    
    eval{
        my $smtp = Net::SMTP->new( 'localhost' )
            or die;
        $smtp->mail( $from )
            or die;
        $smtp->recipient( $to )
            or die;
        $smtp->data;
        $smtp->datasend( "Content-Type: text/plain;charset=iso-2022-jp\n" )
            or die;
        $smtp->datasend( "From: $from\n" )
            or die;
        $smtp->datasend( "To: $to\n" )
            or die;
        $smtp->datasend( "Subject:$subject\n" )
            or die;
        $smtp->datasend( "\n" )
            or die;
        $smtp->datasend( $msg )
            or die;
        $smtp->dataend
            or die;
        $smtp->quit;
     };
     die "Error while sending mail\n" if $@;
}
1;
