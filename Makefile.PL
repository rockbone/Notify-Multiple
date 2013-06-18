use strict;
use warnings;

use ExtUtils::MakeMaker;


WriteMakefile(
    NAME          => 'notify',
    AUTHOR        => 'Tooru Iwasaki <rockbone.g{at}gmail.com>',
    LICENSE       => 'perl',
    ABSTRACT      => 'Pluggable Notification Program',
    VERSION_FROM  => 'lib/Notify/Multiple.pm',
    PREREQ_PM     => {
        'YAML'      => 0,
        'Class::Accessor::Fast' => 0,
        'Storable' => 0,
        'AnyEvent' => 0,
        'Test::More' => 0,
        'Cocoa::Growl' => 0
    },
    EXE_FILES      => [ 'bin/notify' ],
);
exit;
