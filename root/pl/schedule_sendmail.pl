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

#現在時間取得
my $currenttime = DateTime->now( time_zone => 'Asia/Tokyo' );
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
print "current time:$hour:$min\n";
#現在時間と等しくなるようなレコードを取得する
#これも、一度DBから取得したようなレコードがあるのだから修正する
=pod
my $sthtime = $db->prepare("select id,userid, memo from RemainderMemo WHERE DATE_FORMAT(fromtime, '%H:%i:%s') = '$hour:$min:00'");
$sthtime->execute;

while (my @rectime = $sthtime->fetchrow_array) {
    
    push(@memos,$rectime[2]);
}

foreach(@memos){
    # バイト文字列(外部からの入力)を内部文字列に変換($strがUTF-8の場合)
    my $str = encode('UTF-8', $_);
    print "str:",$_,"\n";
}
=cut

=pod
#DB から取得されるべき値
#時間は要素ごとに対応している。
my @hours = (5,5,9);
my @mins = (36,37,28);
=cut

my $hoursnum = scalar(@hours);

#時,分,%userdata(userid,useremail,subject),memoが与えられたら,その内容に応じて,特定のuserに送信する
sub hourmin_entry{
    my ($hours,$mins,$userdata,@memos) = @_;
    
    for (my $i=0;$i<$hoursnum;$i++){
            print "select time is ",$$hours[$i],$$mins[$i],"\n";
    }
    my $frommail = "remainder.information\@gmail.com";
    my $frommailpassword = "ol12dcdbl0jse1l"; #secret
    #userdata は,ハッシュのリファレンスで渡している %userdata = ( userids => @userids, usermails => @uemails, subject => $subject)
    #複数人に対して、メールを送信する
#    while(1){

            my $dt = DateTime->now( time_zone => 'Asia/Tokyo' );
            #my $hour = $dt->hour(),"\n";
            #my $min = $dt->minute(),"\n";
            print "currenttime:",$dt,"\n";
            
            my $content = "";
            foreach(@memos){
                $content = $content.$_."\n";
            }
            $content = decode('UTF-8',$content); #encode だと文字化けする
            #print $content,"\n";
            for(my $i =0;$i < $hoursnum;$i++){
                
                if(($$hours[$i] == $dt->hour()) && ($$mins[$i] == $dt->minute()) ){
                    #$func;
                    #last;

                    #sendmailjob
                    print "Sendmail:\n";
                    print $$userdata{userid},"\n";
                    my $mailcontent = "$$userdata{userid} さん\n\n内容:\n$content\n\n配信を停止する(http://localhost:3000/memo)\n\n-----------------------------------------------\n - Remainder -あなたの気になるをお知らせ-\n $frommail";

                    #print $$hash{userid},"\n";
                    #mail 送信
                    my $email = Email::Simple->create(
                        header => [
                            From    => '"Mail Remainder"'." <".$frommail.">",
                            To      => $$userdata{userid}."さん"." <".$$userdata{usermail}.">",#given
                            Subject => "$$userdata{subject}",#given
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
            #sleep(60);
#    }

}

my $subject = "[test] Remainder";
my $cnt = @userids;
my $userdatas = { userids => \@userids, usermails => \@uemails, subject => $subject};
my $userids = \@userids;
my $uemails = \@uemails;
for (my $i = 0;$i<$cnt;$i++){
    my $userdata = { 'userid' => $userids->[$i],'usermail' => $uemails->[$i] ,subject => $subject};
    &hourmin_entry(\@hours,\@mins,$userdata,@memos);
}

=pod
#if文が適用されていない
foreach my $key (sort keys %$userdatas) {
    foreach my $aryelm (@{$userdatas->{$key}}){
        &hourmin_entry(\@hours,\@mins,\%userdata,@memos);
    }
}
#1;
=cut

# ステートメントハンドルオブジェクトを閉じる
$sth->finish;
# データベースハンドルオブジェクトを閉じる
$db->disconnect;
