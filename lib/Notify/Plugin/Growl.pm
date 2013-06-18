package Notify::Plugin::Growl;

use Cocoa::Growl qw/:all/;

our $VERSION = 0.01;
our $TYPE = 'notify';

# app  => app name
# icon => icon path
sub hook {
    my ( $IN,$arg,$note ) = @_;
    if ( !growl_installed() || !growl_running() ){
        die "Growl is not running\n";
    }
    my %register = (
        app     => $arg->{app} || 'NotifyMultiple',
        notifications => [qw/Notification1/]
    );
    $register{icon} = $arg->{icon} if $arg->{icon};
    growl_register( %register );
    
    my %notify = (
        name        => 'Notification1',
        title       => $arg->{title} || 'NotifyMultiple',
        description => $$IN,
    );
    growl_notify( %notify );
}

1;
