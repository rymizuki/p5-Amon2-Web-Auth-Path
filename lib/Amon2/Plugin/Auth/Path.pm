package Amon2::Plugin::Web::Auth::Path;
use strict;
use warnings;
use 5.010_000;
our $VERSION = '0.01';

use Amon2::Auth::Path;
use Plack::Util ();

sub init {
    my ($class, $c, $conf) = @_;

    my $router;
    if (exists $conf->{module}) {
        my $klass = Plack::Util::load_class($conf->{module})
            or die q{};
        $router = $klass->init_route;
    } else {
        my $paths = $conf->{paths}
            or die q{};
        $router = Amon2::Auth::Path->init_route(@$paths);
    }

    $c->add_trigger(BEFORE_DISPATCH => sub {
        my ($c, ) = @_;
        my $env = $c->req->env;
        if (my $p = $router->match($env)) {
            my ($success, $failed);
            my $auth = Plack::Util::inline_object(
                success => sub { $success = 1 },
                failed  => sub { $failed  = 1 },
            );

            my $res = $p->{authorize}->($c, $auth, $p);
            if ($failed) {
                $conf->{on_error}->($c, $auth, $p)
                    if $conf->{on_error};
                return $res if $res;
                return $c->res_400();
            } elsif ($success) {
                $conf->{on_success}->($c, $auth, $p)
                    if $conf->{on_success};
                return $res if $res;
            } else {
                die '';
            }
        }
    });
}

1;
