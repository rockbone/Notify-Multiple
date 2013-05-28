package Notify::Configure;

use strict;
use warnings;
use YAML qw/LoadFile/;

use parent 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors( qw/opt filter notify/ );


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

__END__

=encoding utf8

=head1 NAME
    
    Notify::Configure - Notify Configure Class

=head1 DESCRIPTION
    
    Initialize the settings for notification by option and ARGV.

=head1 METHOD
    
B<new>
    
    args: (classname,options,ARGV) If config file is given,set it.
    Otherwise set it from option and ARGV.Options are orverwrite
    if specify the config file ,and ignore ARGV.
    
B<parse_argv>
    
    args: (self,ARGV) return Hash Reference it has key and val
    separeted by '='.
    
=head1 AUTHOR
    
    Tooru Iwasaki <rockbone.g{at}gmail.com>

=head1 LICENCE
    
    FREE! ENJOY!

=cut
