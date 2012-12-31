package Remainder;
use strict;
use warnings;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Session
    Session::Store::File
    Session::State::Cookie
    Authentication
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in remainder.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(

    name => 'Remainder',
    default_view => 'TT',
    default_model => 'RemainderDB',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    'Plugin::Session' => {
        expires => 1800,
        storage => 'tmp',
        namespace => 'MyApp',
        cookie_expires => 0,
        verify_address => 1,
        verify_user_agent => 1,
    },


    'Plugin::Authentication' => {
        
        default => {
            credentical => {
                class => 'Password',
                passwordfield => 'passwd',
                password_type => 'hashed',
                password_hash_type => 'MD5',
            },
            store => {
                class => 'DBIx::Class',
                user_model => 'RemainderDB::Usr',
                use_userdata_from_session => 1,

            }
        }
    },

);

# Start the application
__PACKAGE__->setup();


=head1 NAME

Remainder - Catalyst based application

=head1 SYNOPSIS

    script/remainder_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Remainder::Controller::Root>, L<Catalyst>

=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
