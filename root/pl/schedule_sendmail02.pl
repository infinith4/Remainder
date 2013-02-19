#!/usr/bin/perl
use strict;
use warnings;
use DateTime;
use DBI;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Transport::SMTP;
use utf8;
use Encode;
use Data::Dumper;
#ここまでで複数時間を指定してメールを時間に送信できる。

#DBからselect してmemoと時間を指定するだけ。

# データソース
my $d = 'DBI:mysql:remainderdb';
# ユーザ名
my $u = 'remainderuser';
# パスワード
my $p = 'remainderpass';

# データベースへ接続
my $db = DBI->connect($d, $u, $p);
my $dtnow = DateTime->now( time_zone => 'Asia/Tokyo' );
my $dt_plus1min = DateTime->now( time_zone => 'Asia/Tokyo' );
$dt_plus1min->add( minutes => 1 );
print "dtnow:$dtnow\n";
print "dt_plus1min:$dt_plus1min\n";


if(!$db){
    print "接続失敗\n";
    exit;
}
$db->do("set names utf8"); 
# SQL文を用意
#                              0   1      2    3    4        5     6
#my $sth = $db->prepare("SELECT id,userid,memo,tag,fromtime,totime,days FROM RemainderMemo WHERE '$dtnow' >= fromtime and days like '%$dayabbr%' ORDER BY fromtime asc"); #fromtime でソート.現在以前
#$dtnow:現在時間がfromtime-totimeの間に入っているレコードを取得
my $sth = $db->prepare("SELECT userid,memo,fromtime,totime,days,unam,uemail FROM RemainderMemo INNER JOIN User Using (userid) WHERE ('$dtnow' <= fromtime AND fromtime <= '$dt_plus1min') OR (fromtime <= '$dtnow' AND '$dt_plus1min' <=totime) OR ('$dtnow' <= totime AND totime <= '$dt_plus1min') ORDER BY fromtime"); #fromtime でソート.現在以前

if(!$sth->execute){
    print "SQL失敗\n";
    exit;
}

#my $time = "2012-12-02 11:49:00";

my @hours;my @mins;my @userids;my @memos;my @unams;my @uemails;
#sendmailするレコードの時間を取得(このとり方は幼稚で,全部取ってくる必要は無く1日で送るべきレコードを取得するなど工夫する)

=pod
while (my @rec = $sth->fetchrow_array) {
    my $fromtime = $rec[2];
    print "fromtime:",$fromtime,"\n";
    $fromtime =~ m/\s/;
    my $hourminsec = "$'";
    print "hourminsec:",$hourminsec,"\n";
    my @arr =split(/:/,$hourminsec);
    push(@hours,$arr[0]);
    push(@mins,$arr[1]);

    push(@userids,$rec[0]);

    my $memo = encode('UTF-8', $rec[1]);
    print "memo:",$memo,"\n";
    push(@memos,$memo);

    push(@uemails,$rec[6]);
    #push(@memos,$rec[2]);
}
=cut
#送信するデータ数
my $cnt = @memos;
my @docdatas = ();
my @memonum = ();
my @doclabel = ();
=pod
#memoの数の分だけ番号をつける(ドキュメント(doc)と呼ぶ)
for(my $i=0;$i < $cnt ;$i++){
    push(@doclabel,"doc".$i);
}
=cut
my %doc = ("userid" => "" ,"uemail" => "","memo"=> "","hour"=> "","min" => "");
    
while(my @rec = $sth->fetchrow_array){
    #print Dumper @rec;
    #docごとに,labelをつける
    $doc{'userid'} = $rec[0];
    $doc{'uemail'} = $rec[6];
    $doc{'memo'} = $rec[1];
    
    my $fromtime = $rec[2];
    #print "fromtime:",$fromtime,"\n";
    $fromtime =~ m/\s/;
    my $hourminsec = "$'";
#   print "hourminsec:",$hourminsec,"\n";
    my @arr =split(/:/,$hourminsec);
    $doc{'hour'} = $arr[0];
    $doc{'min'} = $arr[1];
    #print "start docdatas###################\n";
    push(@docdatas, %doc);
    #print Dumper @docdatas;
    #ハッシュにハッシュを追加できないのか？
    #print "end docdatas\n";

}
print "result============\n";
print Dumper @docdatas;



