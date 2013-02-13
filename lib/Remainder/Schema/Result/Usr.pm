use utf8;
package Remainder::Schema::Result::Usr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Remainder::Schema::Result::Usr

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

=head1 TABLE: C<usr>

=cut

__PACKAGE__->table("usr");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uid

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 passwd

  data_type: 'char'
  is_nullable: 0
  size: 32

=head2 unam

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 uemail

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 roles

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uid",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "passwd",
  { data_type => "char", is_nullable => 0, size => 32 },
  "unam",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "uemail",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "roles",
  { data_type => "varchar", is_nullable => 0, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07033 @ 2013-02-14 03:25:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FULR3Gt63FYB+ZLm9HKNXw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
