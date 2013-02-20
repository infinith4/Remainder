#!usr/bin/perl

use strict;
use warnings;

package Schedule::Sendmail;

#時,分,%userdata(userid,useremail,subject),memoが与えられたら,その内容に応じて,特定のuserに送信する
sub hourmin_entry{
    my ($hours,$mins,$userdatas,@memos) = @_;
    
    for (my $i=0;$i<$hoursnum;$i++){
            print "select time is ",$$hours[$i],$$mins[$i],"\n";
    }
    my $frommail = "remainder.information\@gmail.com";
    my $frommailpassword = "ol12dcdbl0jse1l"; #secret
    #userdata は,ハッシュのリファレンスで渡している %userdata = ( userids => @userids, usermails => @uemails, subject => $subject)
    #複数人に対して、メールを送信する

            my $dt = DateTime->now( time_zone => 'Asia/Tokyo' );
            print "currenttime:",$dt,"\n";
            
            my $content = "";
            
            foreach(@memos){
                $content = $_."\n";
            }
            $content = decode('UTF-8',$content); #encode だと文字化けする
            #print $content,"\n";
            #原因これ？
            for(my $i =0;$i < $hoursnum;$i++){
                #現在の時刻が登録された時間に等しければ、送信。
                if(($$hours[$i] == $dt->hour()) && ($$mins[$i] == $dt->minute()) ){
                    my $cnt = $userdatas->{userids};
                    print "$cnt\n";
                    #$userdatas = { userids => \@userids, usermails => \@uemails, subject => $subject};
                    
                    
#                        my $userdata = { 'userid' => $userids->[$i],'usermail' => $uemails->[$i] ,subject => $subject};
                        
                        #$func;
                        #last;
                        #sendmailjob
                        print "Sendmail:\n";
                        print "to:",${$userdatas->{userid}}[$i],"\n";
                        my $mailcontent = " さん\n\n内容:\n$content\n\n配信を停止する(http://localhost:3000/memo)\n\n-----------------------------------------------\n - Remainder -あなたの気になるをお知らせ-\n $frommail";

                        #print $$hash{userid},"\n";
                        #mail 送信
                        my $email = Email::Simple->create(
                            header => [
                                From    => '"Mail Remainder"'." <".$frommail.">",
                                To      => ${$userdatas->{userid}}[$i]."さん"." <".${$userdatas->{usermails}}[$i].">",#given
                                Subject => "???",#given
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
    }


