# Running mod_perl with Mojolicious in Docker

### Generate your config

Thanks to <a href="https://github.com/motemen/docker-mod_perl">motemen</a> for some nicely pre-configured
`mod_perl` and `Apache2` images.

```
docker run --rm motemen/mod_perl:5.36.0-2.4.58 cat /usr/local/apache2/conf/httpd.conf > httpd.conf
echo 'Include /usr/local/apache2/conf/mojolicious.conf' >> httpd.conf
```

### Enable Prefork MPM instead of Event MPM

In `httpd.conf`:

```apache
#LoadModule mpm_event_module modules/mod_mpm_event.so
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
```

### Write your application

In `lib/App.pm`:

```perl
package App;

use 5.036;

use Mojolicious::Lite -signatures;

sub get_app { app; }

get '/' => sub {
    shift->render( text => "Hello World!" );
};

1;
```

### Write your Plack shim

In `app.psgi`:

```perl
use 5.036;

use lib 'lib';
use App;
use Plack::Builder;

builder {
  App::get_app->start;
};
```

### Write your mod_perl apache conf

In `mojolicious.conf`:

```apache
LoadModule perl_module modules/mod_perl.so

<VirtualHost *:80>
    <Location />
        SetHandler perl-script
        PerlResponseHandler Plack::Handler::Apache2
        PerlSetVar psgi_app /app.psgi
    </Location>
</VirtualHost>
```

### Write your Dockerfile

In `Dockerfile`:

```docker
FROM motemen/mod_perl:5.36.0-2.4.58-2.0.13
COPY app.psgi /app.psgi
COPY lib /usr/local/apache2/lib
COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY mojolicious.conf /usr/local/apache2/conf/mojolicious.conf
RUN apt-get update -y && apt-get install -y wget make build-essential
RUN cpan -iT Plack Mojolicious
EXPOSE 80
CMD ["httpd-foreground"]
```

### Run with docker

```shell
$ docker build . -t mod-perl
$ docker run -p 80:80 mod-perl
$ curl http://localhost:80/
```

You should see `Hello World!`.

### Running with auto-reloading (for development)

You can make this auto-reload if you use a volume for `lib/` against `/usr/local/apache2/lib/`

<hr>

Originally posted on <a href="https://rawley.xyz/docker-mod-perl.html">My Website</a>.
