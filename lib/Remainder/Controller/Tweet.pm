package Remainder::Controller::Tweet;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Remainder::Controller::Tweet - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

=pod
sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Remainder::Controller::Tweet in Tweet.');
}
=cut
=pod
sub index :Regex('^tweet') :Args(0) {
    my ( $self, $c ) = @_;
 
    $c->stash->{template} = 'twitteroauth.tt';
    $c->stash->{token} = $c->request->params->{token};
    $c->stash->{secret} = $c->request->params->{secret};
    my $tweet = $c->request->params->{tweet};
    $c->stash->{tweet} = $tweet;
 
    my $twitter = Net::Twitter::Lite->new(SampleApp::Const::TOKENS);
    $twitter->access_token($c->session->{token});
    $twitter->access_token_secret($c->session->{secret});
 
    $c->stash->{timeline} = $twitter->user_timeline();
    $twitter->update({'status'=>$tweet});
 
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
