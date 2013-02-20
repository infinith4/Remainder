#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;


my %hasha = ( 'ary01a' => 'a0', 'ary02a' => 'a1');
my %hashb = ( 'ary01a' => 'b0', 'ary02b' => 'b1');

my @ary = (\%hasha,\%hashb);

my $refary = \@ary;

foreach (@$refary){
    print "$_->{ary01a}\n"
}

=pod
for (my $i = 0;$i<$cnt;$i++){
    my $onehash = { 'ary01s' => $ary01s->[$i],'ary02s' => $ary02s->[$i] };
    print Dumper $onehash;

    entry($onehash);
}
=cut

=pod
print Dumper $onehash;

print %$onehash,"\n";

#print "hashs{ary01s}[0]:$hashs->{ary01s}[1]\n";
=cut
=pod
sub entry{
    my ($hashs) = @_;
    print "all hash elements.\n";
    
    foreach my $key (sort keys %$hashs){
        print "key:$key\n";
        foreach (@{$hashs->{$key}}){
            print $_,"\n";
            #
        }
    }
}

entry($hashs);
=cut
=pod
print "all hash elements.\n";
foreach my $key (sort keys %hash){
    print "key:$key\n";
    foreach (@hash{$key}){
        print $_,"\n";
    }
}

=cut
