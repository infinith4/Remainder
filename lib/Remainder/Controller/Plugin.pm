package Remainder::Controller::Plugin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Remainder::Controller::Plugin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Remainder::Controller::Plugin in Plugin.');
}
sub change_session :Local {
    my ($self, $c) = @_;
    $c->session->{name} = 'ニンザブロウ';
    my $msg = $c->sessionid . '：' . $c->session->{name} . '<br />';
    $c->change_session_id;
    $msg .= $c->sessionid . '：' . $c->session->{name};
    $c->response->body($msg);
}

sub session :Local{
    my ($self,$c) = @_;
    my $cnt = $c->session->{cnt} || 1;
    $c->response->body("あなたは${cnt}回アクセスしました。");
    $c->session->{cnt} = ++$cnt;
}

=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
