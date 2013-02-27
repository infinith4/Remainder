package Remainder::Controller::AuthCallback;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Remainder::Controller::AuthCallback - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

=pod
*OAuth::Lite::Util::encode_param = sub {
    my $param = shift;
    URI::Escape::uri_escape_utf8($param, '^\w.~-');
};
 
sub index :Regex('^auth_callback') :Args(0) {
    my ( $self, $c ) = @_;
    my $consumer = OAuth::Lite::Consumer->new(Remainder::Const::TOKENS);
 
my $access_token = $consumer->get_access_token(
    token    => $c->request->params->{oauth_token},
    verifier => $c->request->params->{oauth_verifier}
    );
 
    my $twitter = Net::Twitter::Lite->new(SampleApp::Const::TOKENS);
 
    $twitter->access_token($access_token->{token});
    $twitter->access_token_secret($access_token->{secret});
 
    $c->stash->{template}='twitteroauth.tt';
    $c->stash->{friends}=$twitter->friends();
    $c->stash->{timeline}=$twitter->user_timeline();
    $c->session->{token}=$access_token->{token};
    $c->session->{secret}=$access_token->{secret};
 
    $c->session->{name}=$user->{name};
}
=cut
=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
