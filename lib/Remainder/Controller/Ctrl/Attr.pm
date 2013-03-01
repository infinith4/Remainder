package Remainder::Controller::Ctrl::Attr;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Remainder::Controller::Ctrl::Attr - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Remainder::Controller::Ctrl::Attr in Ctrl::Attr.');
}

=pod
sub memo_top :Chained('/') :PathPart('memo_edit') :CaptureArgs(1) {
# sub chain_top :Chained:PathPart('first') :CaptureArgs(0) {
  my ( $self, $c ,$id ) = @_;
  $c->stash->{body} = '<p>achain_topアクション: ${id}</p>';
}

sub memo_edit :Chained('memo_top') :PathPart('edit') {
  my ( $self, $c ) = @_;
  $c->stash->{body} .= '<p>memo_editアクション</p>';
  $c->response->body($c->stash->{body});
}
=cut

my $memoid;
sub memoedit_top :Chained('/') :PathPart('memoedit') :CaptureArgs(1) {
  my ( $self, $c, $id ) = @_;
  $c->stash->{body} .= "<p>chain_secondアクション：${id} </p>";
  $memoid = $id;
#  my ( $self, $c) = @_;
#  my $id =$c->request->captures->[0];
#  $c->stash->{body} .= "<p>chain_secondアクション：${id} </p>";
}

sub memoedit_second :Chained('memoedit_top') :PathPart('') {
  my ( $self, $c ) = @_;
  
  $c->stash->{id} = $memoid;
  $c->model('RemainderDB')->storage->debug(1);
  #mysql からmemoを取得し、.ttへ渡す
  $c->stash->{editmemo} = $c->model('RemainderDB::RemainderMemo')->find($memoid);
  
  #保存ボタンが押されたら
  if($c->req->method eq 'POST'){
      my $editedmemo = $c->request->body_params->{'editedmemo'};
      #memoのアップデート
      my $review = $c->model('RemainderDB::RemainderMemo')->update_or_new({
          id => $memoid,
          memo => $editedmemo
                                                   });
      if($review->in_storage){
          $c->response->redirect("/memo");
          #$c->response->body("okok$editedmemo");
      }
  }
}



=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
