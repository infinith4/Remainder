use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Remainder';
use Remainder::Controller::Plugin;

ok( request('/plugin')->is_success, 'Request should succeed' );
done_testing();
