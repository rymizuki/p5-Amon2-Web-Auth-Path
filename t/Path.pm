package t::Path;
use Amon2::Auth::Path::Declare;

path '/success' => sub { $_[1]->success };
path '/fail'    => sub {
    my ($c, $auth) = @_;
    $auth->failed;
    $c->create_response(401);
};
path '/die' => sub {
    my ($c, ) = @_;
    $c->create_response(200);
},

1;
