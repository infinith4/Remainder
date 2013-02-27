use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Remainder';
use Remainder::Controller::AuthCallback;

ok( request('/authcallback')->is_success, 'Request should succeed' );
done_testing();
