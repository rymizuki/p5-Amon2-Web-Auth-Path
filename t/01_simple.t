use strict;
use warnings;
use Test::More;

use Plack::Request;
use Plack::Test;
use Test::Requires 'HTTP::Request::Common';

subtest 'use array' => sub {
    use Amon2::Lite;

    get '/success' => sub { shift->create_response(200) };
    get '/fail'    => sub { shift->create_response(200) };
    get '/die'     => sub { shift->create_response(200) };

    __PACKAGE__->load_plugins(
        'Web::Auth::Path', +{
            paths => [
                '/success' => sub { $_[1]->success },
                '/fail'    => sub {
                    my ($c, $auth) = @_;
                    $auth->failed;
                    $c->create_response(401);
                },
                '/die' => sub {
                    my ($c, ) = @_;
                    $c->create_response(200);
                },
            ],
        },
    );

    my $app = __PACKAGE__->to_app;

    test_psgi($app, sub {
        my $cb = shift;

        {
            my $res = $cb->(GET '/success');
            is $res->code => 200;
        }
        {
            my $res = $cb->(GET '/fail');
            is $res->code => 401;
        }
        {
            my $res = $cb->(GET '/die');
            is $res->code => 500;
        }
    });
};

subtest 'use module' => sub {
    {
        package App::Web;
        use Amon2::Lite;

        get '/success' => sub { shift->create_response(200) };
        get '/fail'    => sub { shift->create_response(200) };
        get '/die'     => sub { shift->create_response(200) };

        __PACKAGE__->load_plugins(
            'Web::Auth::Path', {
                module => 't::Path',
            },
        );
    }

    my $app = App::Web->to_app;

    test_psgi($app, sub {
        my $cb = shift;

        {
            my $res = $cb->(GET '/success');
            is $res->code => 200;
        }
        {
            my $res = $cb->(GET '/fail');
            is $res->code => 401;
        }
        {
            my $res = $cb->(GET '/die');
            is $res->code => 500;
        }
    });
};

done_testing;
