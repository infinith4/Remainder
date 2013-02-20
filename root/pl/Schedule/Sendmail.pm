#!/usr/bin/perl

package Schedule::Sendmail;

use strict;
use warnings;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use Email::Sender::Transport::SMTP;

sub sendmemo{
    my ($docdatas) = shift;
    print ":::::run sendmemo::::::\n";
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

1;

#&sendmail(@docdatas);
