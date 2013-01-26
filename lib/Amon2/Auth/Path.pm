package Amon2::Auth::Path;
use strict;
use warnings;
use 5.010_000;
our $VERSION = '0.01';

use Router::Simple;

sub init_route {
    my ($class, @paths) = @_;

    my $router = Router::Simple->new;
    while (@paths) {
        my $path = shift @paths;
        my $code = shift @paths;
        $router->connect($path, {authorize => $code});
    }

    return $router;
}

1;
