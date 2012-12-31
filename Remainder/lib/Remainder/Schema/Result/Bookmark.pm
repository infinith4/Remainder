use utf8;
package Remainder::Schema::Result::Bookmark;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Remainder::Schema::Result::Bookmark

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<Bookmark>

=cut

__PACKAGE__->table("Bookmark");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 userid

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 tag

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 bookmarkid

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 title

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 times

  data_type: 'integer'
  is_nullable: 1

=head2 reltag

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "userid",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "tag",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "bookmarkid",
  { data_type => "char", is_nullable => 1, size => 255 },
  "title",
  { data_type => "char", is_nullable => 1, size => 255 },
  "times",
  { data_type => "integer", is_nullable => 1 },
  "reltag",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "created",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-12-23 23:40:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CSg7j+xrmuNmaCwXKVx/YQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
