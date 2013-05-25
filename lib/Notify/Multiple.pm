package Notify::Multiple;

use strict;
use warnings;
use Notify::Plugin;
use Notify::Configure;
use Encode;
use Encode::Guess qw/cp932 shift-jis 7bit-jis/;
use AnyEvent;
use Data::Dumper;

our $VERSION = 0.1;

use parent qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors( qw/plugin config opt stdin/ );

sub new {
    my $class = shift;
    my $self = bless {},ref $class || $class;
    
    $self->config( Notify::Configure->new( @_ ) ); # command option,$ARGV
    $self->plugin( Notify::Plugin->new( $self->config->opt->{p} ) );
    $self->plugin->show_list if $self->config->opt->{l}; # option list
    
    $self->plugin->find_plugin( $self->config );
    return $self;
}
sub run {
    my $class = shift;
    my $self = $class->new( @_ ); # command option,$ARGV
    {
        local $/;
        my $IN = <STDIN>;
        if ( $self->config->opt->{d} ){ # charset
            $IN = decode( $self->config->opt->{d},$IN );
        }
        else{
            my $decoder = Encode::Guess->guess( $IN );
            die "Can't guess encoding [$decoder]\nPlease set INPUT charset -d( --decode ) option\n" if !ref $decoder;
            $IN = $decoder->decode( $IN );
        }
        $self->stdin( \$IN ); # reference
    }
    $self->hook( 'filter' );
    $self->hook( 'notify' );
}

sub hook {
    my ( $self,$action ) = @_;
    return if !$self->plugin->$action;
    
    my $cv = AE::cv;
    for my $plugin ( @{ $self->plugin->$action } ){
        my $module = $plugin->{fullname};
        eval "require $module";
        $cv->begin;
        my $w;$w = AE::timer 0,0,sub {
            $module->hook( $self->stdin,$plugin->{arg} );
            undef $w;
            $cv->end;
        }
    }
    $cv->recv;
}
1;
