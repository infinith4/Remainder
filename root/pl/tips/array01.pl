#!/usr/bin/perl

use strict;
use warnings;

my @person1 = ('Ken', 'Japan', 19);
my @person2 = ('Taro', 'USA', 45);

my @persons = (\@person1, \@person2);

print "$persons[0][1]\n";

foreach my $ref (@persons){
    foreach (@$ref){
        print "$_\n";
    }

}
print "\n";

#reference
#my $personsref = [
#    ['Ken', 'Japan', 19],
#    ['Taro', 'USA', 45]
#    ];

my $personsref = [11];

print $personsref->[0],"\n";

foreach (@$personsref){
    print "$_\n";
}
=pod
foreach my $ary (@$personsref){
    foreach (@$ary){
        print "$_\n";
    }

} 
=cut
