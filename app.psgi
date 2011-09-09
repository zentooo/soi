use strict;
use warnings;

use Plack::Request;
use Plack::Response;
use Plack::Builder;

use Router::Simple;
use Text::Xslate;
use Data::Section::Simple;
use Path::Class;

my $router = Router::Simple->new;
my $x = Text::Xslate->new(
    path => [ Data::Section::Simple->new()->get_data_section() ]
);

my $app = sub {
    my $env = shift;
    my $match = $router->match($env);

    if ( $match ) {
        my $req = Plack::Request->new($env);
        my $res = $req->new_response(200);

        my $handler = $match->{action};
        $handler->($req, $res);
        return $res->finalize;
    }
    else {
        return [404, ['Content-Type' => 'text/html'], ['Not Found']];
    }
};

sub get {
    my ($route, $handler) = @_;
    $router->connect($route, +{ action => $handler }, +{ method => 'GET' } );
}

sub post {
    my ($route, $handler) = @_;
    $router->connect($route, +{ action => $handler }, +{ method => 'POST' } );
}


# write handlers here

get '/' => sub {
    my ($req, $res) = @_;
    $res->body($x->render("index.tx", +{ title => 'soi' }));
};


# include middleware if you need

builder {
    enable 'Static', path => qr/css|js|images/, root => file(__FILE__)->dir->subdir('public');
    $app;
};


# write templates here

__DATA__

@@ base.tx
<!DOCTYPE HTML>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title><: $title // "This is a pen." :></title>
</head>
<body>
<: block body -> { :>default body<: } :>
</body>
</html>

@@ index.tx
: cascade base { $title => $title };
: override body -> {
    soi
: }
