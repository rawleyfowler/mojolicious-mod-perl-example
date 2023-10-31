use 5.036;

use lib 'lib';
use App;
use Plack::Builder;

builder {
  App::get_app->start;
};
