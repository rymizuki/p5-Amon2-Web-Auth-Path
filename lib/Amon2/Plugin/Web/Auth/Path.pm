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
__END__

=pod

=encoding utf-8

=head1 NAME

Amon2::Plugin::Web::Auth::Path

=hea1 SYNOPSIS

package YourApp::Web;
use Amon2::Lite;

get '/' => sub {
    my $c = shift;
};

get '/mypage' => sub {
    my $c = shift;
};

__PACKAGE__->load_plugins(
    'Web::Auth' => +{
        module => 'Twitter',
        ...
    },
    'Web::Auth::Path' => sub {
        paths => [
            '/'          => sub { $_[1]->success },
            qr{^/auth}   => sub { $_[1]->success },
            qr{^/mypage} => sub {
                my ($c, $auth,) = @_;
                if ($c->session->get('is_login')) {
                    $auth->success;
                } else {
                    $auth->failed;
                    # redirect to Auth::Site::Twitter
                    return $c->redirect('/auth/twitter/authenticate');
                },
            },
        ],
    },
);

1;
