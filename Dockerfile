FROM motemen/mod_perl:5.36.0-2.4.58-2.0.13
COPY app.psgi /app.psgi
COPY lib /usr/local/apache2/lib
COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY mojolicious.conf /usr/local/apache2/conf/mojolicious.conf
RUN apt-get update -y && apt-get install -y wget make build-essential
RUN cpan -iT Plack Mojolicious
EXPOSE 80
CMD ["httpd-foreground"]
