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
print "\ndtnow:$dtnow\n";
print "dt_plus1min:$dt_plus1min\n";


if(!$db){
    print "接続失敗\n";
    exit;
}
$db->do("set names utf8"); 

my $currenttime = DateTime->now( time_zone => 'Asia/Tokyo' );
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
print "current time:$hour:$min\n";


# SQL文を用意
#                              0   1      2    3    4        5     6
#my $sth = $db->prepare("SELECT id,userid,memo,tag,fromtime,totime,days FROM RemainderMemo WHERE '$dtnow' >= fromtime and days like '%$dayabbr%' ORDER BY fromtime asc"); #fromtime でソート.現在以前
#$dtnow:現在時間がfromtime-totimeの間に入っている AND 現在時間の時間とfromtimeの時間に一致するレコードを取得
my $sth = $db->prepare("SELECT userid,memo,fromtime,totime,days,unam,uemail FROM RemainderMemo INNER JOIN User Using (userid) WHERE (('$dtnow' <= fromtime AND fromtime <= '$dt_plus1min') OR (fromtime <= '$dtnow' AND '$dt_plus1min' <=totime) OR ('$dtnow' <= totime AND totime <= '$dt_plus1min') ) AND DATE_FORMAT(fromtime, '%H:%i:%s') = '$hour:$min:00' ORDER BY fromtime"); #fromtime でソート.現在以前

if(!$sth->execute){
    print "SQL失敗\n";
    exit;
}

#my $time = "2012-12-02 11:49:00";

my @hours;my @mins;my @userids;my @memos;my @unams;my @uemails;
#sendmailするレコードの時間を取得(このとり方は幼稚で,全部取ってくる必要は無く1日で送るべきレコードを取得するなど工夫する)

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
    
while(my @rec = $sth->fetchrow_array){
    my %doc = ("userid" => "" ,"uemail" => "","memo"=> "","hour"=> "","min" => "","fromtime"=>"","totime"=>"");

    #print Dumper @rec;
    #docごとに,labelをつける
    $doc{'userid'} = $rec[0];
    $doc{'uemail'} = $rec[6];
    $doc{'memo'} = $rec[1];
    $doc{'fromtime'} = $rec[2];
    $doc{'totime'} = $rec[3];

    my $fromtime = $rec[2];
    #print "fromtime:",$fromtime,"\n";
    $fromtime =~ m/\s/;
    my $hourminsec = "$'";
#   print "hourminsec:",$hourminsec,"\n";
    my @arr =split(/:/,$hourminsec);
    $doc{'hour'} = $arr[0];
    $doc{'min'} = $arr[1];
    #print "start docdatas###################\n";
    my $doc = \%doc;
    push(@docdatas, $doc);
#    print Dumper @docdatas;
    #ハッシュにハッシュを追加できないのか？
    #print "end docdatas\n";

}

print "Current all sendmail record:\n";
print Dumper @docdatas;
if(!@docdatas){
    print "docdatas record is empty\n";
}
my $refdocdatas = \@docdatas;
use Schedule::Sendmail;
if(!$refdocdatas){
    &Schedule::Sendmail::sendmemo($refdocdatas);
}
#&sendmemo($refdocdatas);

sub sendmemo{
    my ($docdatas) = shift;

    my $frommail = "remainder.information\@gmail.com";
    my $frommailpassword = "ol12dcdbl0jse1l"; #secret
    foreach (@$docdatas){
        print "Sendmail:\n";
        print "to:",$_->{'userid'},"\n";
        my $content = $_->{'memo'};
        my $mailcontent = "$_->{'userid'} さん\n\n内容:\n$content\n\n配信を停止する(http://localhost:3000/memo)\n\n-----------------------------------------------\n - Remainder -あなたの気になるをお知らせ-\n $frommail";

    #print $$hash{userid},"\n";
    #mail 送信
    my $email = Email::Simple->create(
        header => [
            From    => '"Mail Remainder"'." <".$frommail.">",
            To      => $_->{'userid'}."さん"." <".$_->{'uemail'}.">",#given
            Subject => "test",#given
        ],
        body => "$mailcontent",#given
        );

        my $transport = Email::Sender::Transport::SMTP->new({
        ssl  => 1,
        host => 'smtp.gmail.com',
        port => 465,
        sasl_username => $frommail,
        sasl_password => $frommailpassword
                                                            });
        eval { sendmail($email, { transport => $transport }); };             
        if ($@) { warn $@ }
    }

}

=pod
foreach  (@docdatas){
    print $_->{'userid'},"\n"; #pushするときにリファレンスにしたから
}
=cut

