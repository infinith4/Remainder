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
    Session::PerUser
    FillInForm
    Unicode
    FormValidator::Simple
    FormValidator::Simple::Auto
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
    
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    ENCODING => 'UTF-8',
    default_view => 'TT',
    TEMPLATE_EXTENSION => '.tt',
    enable_catalyst_header => 1, # Send X-Catalyst header
    'Plugin::Session' => {
        expires => 1800,
    },
    'Plugin::Authentication' => {
        default => {
            credential => {
                class => 'Password',
                password_field => 'passwd',
                password_type   => 'hashed',
                password_hash_type => 'MD5',
            },
            store => {
                class => 'DBIx::Class',
                user_model => 'CatalDB::Usr',
                use_userdata_from_session => 1,
                role_relation => 'roles',
                role_field => 'role',
                # role_column => 'roles',
                # ignore_fields_in_find => ['unam'],
            }
        }
    },

/*
    'Plugin::Authentication' => {
        default_realm => "twitter",
        realms => {
            twitter => {
                credential => {
                    class => "Twitter",
                },
                store => {
                    class => 'DBIx::Class',
                    user_model => 'Remainder::Twitteruser',
                },
                auto_create_user => 1,
                consumer_key    => '69HLgtNGXqrNYxhDU9CXg',
                consumer_secret => '6cu2i6wjUog5hfm6GhuvdIujRK1ykFL6CuTDqR6mY',
                callback_url => 'http://27.120.91.248//callback',
            }
        }
    },
*/
    'validator' => {
        plugins => [qw/Japanese/],
        options => {
            charset => 'utf8',
        },
        profiles => __PACKAGE__->path_to('conf/profiles.yml'),
        messages => __PACKAGE__->path_to('conf/messages.yml'),
        message_decode_from => 'utf-8',
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
