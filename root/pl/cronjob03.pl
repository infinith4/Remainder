#!/use/bin/perl
use strict;
use warnings;
use Schedule::Cron;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Transport::SMTP;

sub dispatcher{
    print "ID: ", shift, "\n";
    print "Args:","@_", "\n";
}
    #必要なデータはmysqlから呼び出す.
    my $userid ="tashirohiro4";#given
    my $usermail = "infinith4\@gmail.com";#given
    my $subject = "[test] Remainder";

    my $frommail = "remainder.information\@gmail.com";
    my $frommailpassword = "ol12dcdbl0jse1l";

    my $mailcontent = "- Remainder -あなたの気になるをお知らせ-\n $frommail";

sub job{
# 実行したい処理（メール送信、時間設定ファイルの読み込み？）
    print "job:$_[0]\n";
    
        #mail 送信
        my $email = Email::Simple->create(
            header => [
                From    => '"Mail Remainder"'." <".$frommail.">",
                To      => $userid."さん"." <".$usermail.">",#given
                Subject => "$subject",#given
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

my $cron = new Schedule::Cron(\&dispatcher);

my @aaa = ("aaa","bbb","ccc");


my @min = (54,55,56);

foreach(@min){
$cron->add_entry("$_ 23 * * * ", \&job($_)); # 10分ごとに&job()を実行
}
$cron->run();
