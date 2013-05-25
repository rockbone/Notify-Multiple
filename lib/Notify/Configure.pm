package Notify::Configure;

use strict;
use warnings;
use YAML qw/LoadFile/;

use parent 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors( qw/opt filter notify/ );

#global:
# decode: CHARSET
# plugin_path: PATH_TO_PLUGIN
#plugin:
# filter:
#  name: FILTER_NAME
##  path: PATH_TO_FILTER
#  arg:
#   KEY1: VAL1
#   KEY2: VAL2
# notify:
#  nmae: NOTIFY_NAME
##  path: PATH_TO_NOTIFY
#  arg:
#   KEY1: VAL1
#   KEY2: VAL2

sub new {
    my ( $class,$opt,@argv ) = @_;
    my $self = bless {},ref $class || $class;

    # read config file and orverwrite option
    if ( my $config_file = $opt->{c} ){
        die "No such config file [$config_file]\n" if !-f $config_file;
        my $config = LoadFile( $config_file )
            or die "Failed to parsing YAML data from [$config_file]\n";
        my $opt_overwrite = {};
        my $global = $config->{global};
        $opt->{d} = $global->{decode} || '';
        $opt->{p} = $global->{plugin_path} || '';
        $self->opt( $opt_overwrite );

        $self->filter( $config->{plugin}{filter} );
        $self->notify( $config->{plugin}{notify} );
    }
    # given no config file
    else{
        $self->opt( $opt );
        my @type = split/,/,$self->opt->{t};
        my @notify;
        for my $name ( @type ){
            push @notify,{
                name    => $name,
                arg     => $self->parse_argv( @argv )
            };
        }
        $self->notify( \@notify );
    }
    # standardize to ARRAY ref
    $self->filter( [ $self->filter ] ) if $self->filter && ref $self->filter ne 'ARRAY';
    $self->notify( [ $self->notify ] ) if ref $self->notify ne 'ARRAY';
    return $self;
}
sub parse_argv {
    my ( $self,@argv ) = @_;
    my %argv;
    for ( @argv ){
        die "Invalid command line argment [$_]\n\tmust be [ key=val ]\n" if !/^.+?=.+/;
        my ( $key,$val ) = split/=/;
        $argv{lc $key} = $val;
    }
    return \%argv;
}
1;
