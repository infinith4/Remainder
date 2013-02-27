use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Remainder';
use Remainder::Controller::Tweet;

ok( request('/tweet')->is_success, 'Request should succeed' );
done_testing();
