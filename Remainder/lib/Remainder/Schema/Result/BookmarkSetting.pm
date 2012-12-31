use utf8;
package Remainder::Schema::Result::BookmarkSetting;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Remainder::Schema::Result::BookmarkSetting

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

=head1 TABLE: C<BookmarkSetting>

=cut

__PACKAGE__->table("BookmarkSetting");

=head1 ACCESSORS

=head2 userid

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 tag

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 remindnum

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 reltag

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 days

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 hour

  data_type: 'integer'
  is_nullable: 1

=head2 minute

  data_type: 'integer'
  is_nullable: 1

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
  "userid",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "tag",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "remindnum",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "reltag",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "days",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "hour",
  { data_type => "integer", is_nullable => 1 },
  "minute",
  { data_type => "integer", is_nullable => 1 },
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

=item * L</userid>

=back

=cut

__PACKAGE__->set_primary_key("userid");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2012-12-23 23:40:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zw6etAr1vxg0ga6QPkwm1w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
