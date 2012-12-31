#!/usr/bin/perl

use strict;
use warnings;

use HTTP::Lite;
use HTML::TreeBuilder;
use HTML::TagParser;
use XML::FeedPP;

use XMLRPC::Lite;
use POSIX;

my $http = new HTTP::Lite;
my $body = $http->body();

my $tree = HTML::TreeBuilder->new;
$tree->parse($body);
$tree->eof();

my $userid = "infinity_th4";
#my $tag = $c->request->body_params->{'tag'};
my $tag = "*book";#日本語が使えない
my $of = 20;
my @bookmarkurls = ();
my @titles = ();
my @reltags = ();
my @issueds = ();

my $atomurl0 = "http://b.hatena.ne.jp/".$userid."/atomfeed?tag=".$tag;

my $feed = XML::FeedPP->new( $atomurl0 );
print "Title: ", $feed->title(), "\n";
my $str = $feed->title();
my $bookmarknum = 0;

if($str =~ /\(/){
#    print "before:","$'";
    $str = "$'";
    if($str =~ /\)/){
#        print "after:","$`";
        $bookmarknum = "$`";
    }
}

print ceil($bookmarknum/$of),"\n";

for(my $cnt=0; $cnt<=ceil($bookmarknum/$of); $cnt++){

	my $off = $of*$cnt;
	print "off:",$off,"\n";
	my $atomurl = "http://b.hatena.ne.jp/".$userid."/atomfeed?tag=".$tag."\&of=$off";
	print $atomurl,"\n";
	#for(my $i = 0;$i<=$bookmarkofcnt ;$i++)
	my $req = $http->request("$atomurl") || die $!;
	$feed = XML::FeedPP->new( $atomurl );


	foreach my $item ( $feed->get_item() ) {
		print "bookmarkURL: ", $item->link(), "\n"; #bookmarkURL
		push(@bookmarkurls, $item->link());
		print "Title: ", $item->title(), "\n";      #Title
		push(@titles, $item->title());
		my $reltag ="";
		foreach my $a ($item->get("dc:subject")) {
		    print "category: ", $a, "\n"; #relation Tag
		    $reltag = $reltag.$a.",";
		}
		push(@reltags,$reltag);
		print "issued: ", $item->get("issued"), "\n";#登録日時
		push(@issueds, $item->get("issued"));
	}



}

for(0 .. $bookmarknum){
    print $bookmarkurls[$_],"\n";
}

print "length:",length(@bookmarkurls),"\n";#変


foreach (@reltags){
    print $_,"\n";
}

#foreach my $a ($tree->find("issued")) {
#    print $a->as_text;
#    print "\n";
#}

exit;


