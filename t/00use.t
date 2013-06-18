use strict;
use warnings;

use Test::More 'no_plan';
use_ok('Notify::Multiple');
use_ok('Notify::Plugin');
use_ok('Notify::Configure');

my $plugin_dir = "../lib/Notify/Plugin";
my @plugins = glob("$plugin_dir/*");

for my $p ( @plugins ){
    $p =~ s|../lib/||;
    $p =~ s|/|::|g;
    $p =~ s|.pm$||;
    use_ok($p);
}
