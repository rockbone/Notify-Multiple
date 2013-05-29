package Notify::Plugin::Mail;

use strict;
use warnings;
use Net::SMTP;
use Encode;

our $VERSION = 0.01;
our $TYPE = 'notify';

chomp( my $host = `hostname` );
my $DEFAULT_SENDER = "notify_multiple\@$host";

# argment
# TO FROM SUBJECT
my %arg;
sub hook {
    my ( $IN,$arg,$note ) = @_;
    if ( !$arg->{to} ){
        die "mail recipient is not specified\n";
    }
    
    sendmail( $$IN,$arg,$note );
}

sub sendmail {
    my ( $IN,$arg,$note ) = @_;
    my $subject = $arg->{subject} ? encode( "MIME-Header-ISO_2022_JP",$arg->{subject} ) : "";
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
        if ( $note->{base64} ){
            $smtp->datasend( "Content-Disposition: inline;filename=".$note->{filename}."\n" )
                or die;
            $smtp->datasend( "Content-Type: ".$note->{type}.";name=".$note->{filename}."\n" )
                or die;
            $smtp->datasend( "Content-Transfer-Encoding: base64\n" )
                or die;
        }
        else{
            $smtp->datasend( "Content-Type: text/plain;charset=iso-2022-jp\n" )
                or die;
        }
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
