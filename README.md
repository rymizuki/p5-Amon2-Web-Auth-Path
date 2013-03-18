# NAME

Amon2::Plugin::Web::Auth::Path

# SYNOPSIS

    package YourApp::Web;
    use Amon2::Lite;
 
    get '/' => sub {
        my $c = shift;
        my $result = $c->validator(rule => +{
            page  => 'Int',
            limit => {isa => 'Int', default => 1},
        })->validate();
 
        if ($result->is_success) {
            my $data = $result->valid_data;
 
            ...
        } else {
            return $c->redirect('/error');
        }
    };
 
    post '/' => sub {
        my $c = shift;
        my $data = $c->validator(+{
            page => {isa => 'Int', default => 1},
        })->valid_data;
        my $result = $c->model('hoge')->huga(%$data);
        return $c->render($result);
    };
 
    __PACKAGE__->load_plugins(
        'Web::Validator' => +{
            module  => 'Data::Validator',
            message => \%error_messages,
        },
    );
 
    1;


# DESCRIPTION

Set the trigger for each certification path.


# AUTHOR
ryo iinuma(@mizuki_r)
