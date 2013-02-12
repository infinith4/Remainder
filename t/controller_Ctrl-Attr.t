use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Remainder';
use Remainder::Controller::Ctrl::Attr;

ok( request('/ctrl/attr')->is_success, 'Request should succeed' );
done_testing();
