package Amon2::Auth::Path::Declare;
use strict;
use warnings;
use utf8;

use Exporter::Lite;
our @EXPORT = qw(
    path
    init_route
);

our @_PATHS = ();

sub path {
    my ($path, $code) = @_;
    push @_PATHS, $path, $code;
}

use Amon2::Auth::Path;
sub init_route {
    my $class = shift;
    Amon2::Auth::Path->init_route(@_PATHS);
}

1;
