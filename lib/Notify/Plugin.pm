package Notify::Plugin;

use strict;
use warnings;
use Storable qw/dclone/;

use parent qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors( qw/plugin_list/ );

sub new {
    my ( $class,$plugin_dir ) = @_;
    my $dh;
    if ( $plugin_dir ){
        die "No such directory for plugin [ $plugin_dir ]\n" if !-d $plugin_dir;
    }
    else{
        ( my $package = $class ) =~ s|::|/|g;
        ( $plugin_dir = $INC{"$package.pm"} ) =~ s/\.pm//;
    }
    opendir $dh,$plugin_dir
        or die "Can't opendir $plugin_dir:$!";
    my @plugins;
    while ( readdir($dh) ){
        if ( s/\.pm// ){
            push @plugins,{
                fullname      => "$class::$_",
                name          => $_
            };
        }
    }
    close $dh;
    die "No plugin found under $plugin_dir\n" if !@plugins;
    my $self = bless {},ref $class || $class;
    $self->plugin_list( @plugins );
    return $self;
}
sub show_list {
    my $self = shift;
    print "Plugins:\n";
    for my $p ( $self->plugin_list ){
        print "\t$p->{name}\n";
    }
    exit 0;
}

sub find_plugin {
    my ( $self,$config ) = @_;

    # below two hash,to find non exists plugin specified in config
    my %config_filter;
    if ( $config->filter ){
        %config_filter    = map{ $_->{name} => 0 } @{ $config->filter };
    }
    my %config_notify = map{ $_->{name} => 0 } @{ $config->notify };
    if ( $config->filter ){
        for my $filter ( @{ $config->filter } ){
            if ( my ( $fullname ) = map{ $_->{fullname} }grep{ $filter->{name} eq $_->{name} } $self->plugin_list ){
                $filter->{fullname} = $fullname;
                push @{ $self->{filter} },dclone($filter);
                $config_filter{ $filter->{name} } = 1; # flag is on when find it
            }
        }
    }
    for my $notify ( @{ $config->notify } ){
        if ( my ( $fullname ) = map{ $_->{fullname} }grep{ $notify->{name} eq $_->{name} } $self->plugin_list ){
            $notify->{fullname} = $fullname;
            push @{ $self->{notify} },dclone($notify);
            $config_notify{ $notify->{name} } = 1; # flag is on when find it
        }
    }
    my @filter_error = grep { !$config_filter{$_} } keys %config_filter;
    my @notify_error = grep { !$config_notify{$_} } keys %config_notify;
    my $error;
    $error  = "Unknown filter type [ @{ [ join( ',',@filter_error ) ] } ]\n" if @filter_error;
    $error .= "Unknown notification type [ @{ [ join( ',',@notify_error ) ] } ]\n" if @notify_error;
    die $error if $error;
}

sub filter { +shift->{filter} }
sub notify { +shift->{notify} }
1;
