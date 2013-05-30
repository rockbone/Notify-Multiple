package Notify::Multiple;

use strict;
use warnings;
use Notify::Plugin;
use Notify::Configure;
use Encode;
use Encode::Guess qw/cp932 shift-jis 7bit-jis/;
use AnyEvent;
use Data::Dumper;

our $VERSION = 0.01;

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
        my $IN = $self->decode_content( <STDIN> );
        $self->stdin( \$IN ); # reference
    }
    
    my $note_through_phase = {}; # common argment from phase to next phase
    $self->hook( 'filter',$note_through_phase );
    $self->hook( 'notify',$note_through_phase );
}

sub hook {
    my ( $self,$action,$note ) = @_;
    return if !$self->plugin->$action;
    
    my $cv = AE::cv;
    for my $plugin ( @{ $self->plugin->$action } ){
        my $module = $plugin->{fullname};
        eval "require $module";
        my $callback = sub {
            my $watcher = shift || "";
            {
                no strict "refs";
                my $plugin_type = lc ${"$module\::TYPE"};
                die "Error. Selected plugin type [$plugin_type] where expected [$action]" if $action ne $plugin_type;
                &{ "$module\::hook" }( $self->stdin,$plugin->{arg},$note );
            }
            $cv->end if $watcher;
            undef $$watcher if $watcher;
        };
        if ( $plugin->{async} ){
            $cv->begin;
            my $w;$w = AE::timer 0,0,$callback->( \$w );
        }
        else{
            $callback->();
            $cv->send;
        }
    }
    $cv->recv;
}

sub decode_content {
    my ( $self,$content,$charset ) = @_;
    
    if ( $charset ){
        return decode( $charset,$content );
    }
    elsif ( $self->config->opt->{d} && $self->config->opt->{d} ne 'no' ){ # charset
        return decode( $self->config->opt->{d},$content );
    }
    elsif ( !$self->config->opt->{d} ){
        my $decoder = Encode::Guess->guess( $content );
        die "Can't guess encoding [$decoder]\nPlease set INPUT charset -d( --decode ) option\n" if !ref $decoder;
        return $decoder->decode( $content );
    }
    return $content;
}
1;

__END__

=encoding utf8

=head1 NAME
    
    Notify::Multiple - Notify Controller Class

=head1 DESCRIPTION
    
    Fix option,ARGV,config,plugins.Decode STDIN automatically
    if do not specify command option '-d(--decode)'.

=head1 METHOD
    
B<new>
    
    args: (classname,options,ARGV)
    
B<run>
    
    args: (classname,options,ARGV) Call from 'notify'
    
B<hook>
    
    args: (self,action) Fix and execute plugin by action.
    
=head1 AUTHOR
    
    Tooru Iwasaki <rockbone.g{at}gmail.com>

=head1 LICENCE
    
    FREE! ENJOY!

=cut
