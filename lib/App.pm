package App;

use 5.036;

use Mojolicious::Lite -signatures;

sub get_app { app; }

get '/' => sub {
    shift->render( text => "Hello World!" );
};

1;
