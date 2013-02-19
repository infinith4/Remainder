#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $ary01s = ['a0','a1','a2'];
my $ary02s = ['b0','b1','b2'];
my @ary01 = ('a0','a1');
my @ary02 = ('b0','b1');

print "$ary01[0]\n";

my $hashs = { 'ary01s' => $ary01s, 'ary02s' => $ary02s};
my %hash = ('ary01' => @ary01 ,'ary02' => @ary02);

my $cnt = @ary01;

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

=pod
print "all hash elements.\n";
foreach my $key (sort keys %hash){
    print "key:$key\n";
    foreach (@hash{$key}){
        print $_,"\n";
    }
}

=cut
