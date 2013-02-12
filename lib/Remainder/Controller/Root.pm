package Remainder::Controller::Root;
use strict;
use warnings;

use Moose;
use namespace::autoclean;

use Data::Dumper;
use DateTime;
#use Time::Local;
use Catalyst::Plugin::Unicode;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use OAuth::Lite::Consumer;
use OAuth::Lite::Token;
use DBI;

use HTTP::Lite;
use HTML::TreeBuilder;
use HTML::TagParser;
use XML::FeedPP;

use POSIX;


BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Remainder::Controller::Root - Root Controller for Remainder

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

#sub index :Path :Args(0) {
sub index :Local {
    my ($self, $c ) = @_;

    my $uid = $c->request->params->{uid};
    my $passwd = $c->request->params->{passwd};

    #user name,passwordを入力時のみ認証処理を実行
    if(defined($uid) && defined($passwd)){
        #user name,passwordで認証
        if($c->authenticate({ uid => $uid ,passwd => $passwd })){
            #認証成功
            
            $c->response->redirect("/memo");
        }else{
            $c->stash->{error} = 'ユーザー名またはパスワードが間違っています';
        }
    }
    if($c->user_exists) {
        $c->response->redirect($c->uri_for('/memo'));
    }

}
    # Hello World
    #$c->response->body( $c->welcome_message );

#my $consumer_key   = 'PgpEemhYpWeviQ==';
#my $consumer_secret    = 'YXPnSMwBfljWzXVtl9hcmTu1J3g=';

#my $title = 'Test Hatena OAuth API';

=pod

sub save_request_token {
    my ($request_token) = @_;

    open(TOKEN, ">.session")    or die $!;
    print TOKEN $request_token->as_encoded;
    close(TOKEN);
}

sub load_request_token {
    open(TOKEN, ".session")     or die $!;
    my $request_token = OAuth::Lite::Token->from_encoded(<TOKEN>);
    close(TOKEN);

    return $request_token;
}

my $cgi = new CGI;

my $consumer = new OAuth::Lite::Consumer(
        consumer_key    => $consumer_key,
        consumer_secret => $consumer_secret,
    );

if (! $cgi->param()) {
    my $request_token = $consumer->get_request_token(
            url             => 'https://www.hatena.com/oauth/initiate',
            callback_url    => $cgi->url,
            scope           => 'write_public,read_private',
        )   or die $consumer->errstr."\n";
    save_request_token($request_token);
    print $cgi->redirect(
            $consumer->url_to_authorize(
                url     => 'https://www.hatena.ne.jp/oauth/authorize',
                token   => $request_token,
        ));
}
else {
    my $oauth_verifier  = $cgi->param('oauth_verifier');
    my $request_token   = load_request_token();

    my $access_token = $consumer->get_access_token(
            url         => 'https://www.hatena.com/oauth/token',
            token       => $request_token,
            verifier    => $oauth_verifier,
        );

    print $cgi->header,
          $cgi->start_html(-title=>$title)
              . $cgi->h1($cgi->a({href=>$cgi->url},$title))
        . $cgi->dl(
                $cgi->dt('Access Token:'), $cgi->dd($access_token->token),
                $cgi->dt('Access Secret:'), $cgi->dd($access_token->secret),
            )
        . $cgi->end_html;
}


}

=head2 default

Standard 404 error page

=cut
#}


sub twitter_login : Local {
    my ($self, $c) = @_;
    my $realm = $c->get_auth_realm('twitter');
    $c->res->redirect( $realm->credential->authenticate_twitter_url($c) );
}

sub callback : Local {
   my ($self, $c) = @_;
   $c->stash->{pagetitle} = 'ログインしました - BESTGAMEON';
   if (!$c->authenticate(undef,'twitter')) {
       $c->stash->{pagetitle} = 'ログインエラー - BESTGAMEON';
       $c->stash->{template} = 'login_error.tt';
   }
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=pod
sub login :Local {
    my ($self,$c) = @_;
    #formからの入力を取得
    my $uid = $c->request->params->{uid};
    my $passwd = $c->request->params->{passwd};

    #user name,passwordを入力時のみ認証処理を実行
    if(defined($uid) && defined($passwd)){
        #user name,passwordで認証
        if($c->authenticate({ uid => $uid ,passwd => $passwd })){
            #認証成功
            
            $c->response->redirect("/memo");
        }else{
            #認証失敗時
#sub auto : Private {
#  my ($self, $c) = @_;
#  if ($c->action->reverse eq 'login') { return 1; }
#  if (!$c->user_exists) {
#      $c->response->redirect($c->uri_for('/login'));
#      return 0;
#  }
#  return 1;
#}
            $c->stash->{error} = 'ユーザー名またはパスワードが間違っています';
        }
    }
}
=cut


sub logout : Local {
    my ($self, $c) = @_;
    $c->logout();
    $c->response->redirect("/");
}

#全認証
sub auto : Private {
    my ($self, $c) = @_;
    if ($c->action->reverse eq 'index') { return 1; }
    
    if (!$c->user_exists) {
        $c->response->redirect($c->uri_for('/index'));
        return 0;
    }
    
    return 1;
}


sub bookmark :Local {
	my ($self ,$c) = @_;
	#$c->response->body('こんにちは');
    $c->stash->{bookmark} = [$c->model('RemainderDB::Bookmark')->all];
    #$c->stash->{title} = 'Remainder - あなたの気になるをお知らせ！ -';
    
}

sub bookmarksetting :Local {
	my ($self ,$c) = @_;
    
    my $userid = "infinity_th4";
    
    #BookmarkSettingから取得する
    $c->stash->{bookmarksetting} = $c->model('RemainderDB::BookmarkSetting')->find("$userid");
    #my $dbdays = $c->model('RemainderDB::BookmarkSetting')->find("$userid");
    #print "=============",$dbdays[days],"\n";
    
    #現在の日付(時間ふくむ)
    my $datetimenow = DateTime->now( time_zone => 'Asia/Tokyo' );
    $c->stash->{datetimenow} = $datetimenow;
    
    my $tag = $c->request->body_params->{'tag'};
    #my $email = $c->request->body_params->{'email'};
    my $email = "tashirohiro4\@gmail.com";
    my $reltag = $c->request->body_params->{'reltag'};
    my $remindnum = $c->request->body_params->{'remindnum'};
    my $bookmarkdays = $c->request->body_params->{'bookmarkdays'};
    my $hour = $c->request->body_params->{'hour'};
    my $minute = $c->request->body_params->{'minute'};
    my $days = "";
    
    foreach (@$bookmarkdays){
        $days = $days.$_.",";
        #$days = join ',', @$bookmarkdays;
    }
    #data source
    my $d = "DBI:mysql:RemaidnerMemo";
    my $u = "remainderuser";
    my $p = "remainderpass";
    
    #Connect database;
    my $dbh = DBI->connect($d,$u,$p);

    my $bookmarksetting = $c->model('RemainderDB::BookmarkSetting')->update_or_new({
        userid => $userid,#プライマリキー(重複していたら、更新)
        email => $email,
        tag => $tag,
        remindnum => $remindnum,
        reltag => $reltag,
        days => $days,
        hour => $hour,
        minute => $minute,
        #created => \'NOW()',
        #updated => \'NOW()',
    });

    if($bookmarksetting->in_storage){
    
    }else{#重複なしの場合のみ登録
        $bookmarksetting->insert();
    }


#    my $loginuseremail = $c->request->body_params->{'loginuseremail'};
    my $loginuseremail = "tashirohiro4\@gmail.com";
##############################
    
    my $http = new HTTP::Lite;
    my $body = $http->body();

    my $tree = HTML::TreeBuilder->new;
    $tree->parse($body);
    $tree->eof();

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

########################################
    #If user logined site,We check email by DataTable RemainderUsers.Because Email is Primary.
    #Create for new login user.
=pod    
    my $row = $c->model('RemainderDB::BookmarkSetting')->create({
        userid => '',
        memo => $memo,
        #weektimes => $weektimes,
        tag => '',
        fromtime => "$fromtime",
        totime => "$totime",
        days => "$daystext",
        notification => $notification,
        #created => 'NOW()',
        #updated => 'NOW()',
    });
=cut
    my $n = 20;

    for(0 .. $bookmarknum){
    #DB のbookmarkidと一致するものは登録しない
    my $row = $c->model('RemainderDB::Bookmark')->find_or_new({
        userid => $userid,
        tag => $tag,
        bookmarkid => $bookmarkurls[$_],
        title => $titles[$_],
        reltag => $reltags[$_],
        #created => 'NOW()',
        #updated => 'NOW()',
    }, key => 'bookmarkid' );
    if($row->in_storage){
    
    }else{#重複なしの場合のみ登録
        $row->insert();
    }
    }

    $c->model('RemainderDB')->storage->debug(1);
    #Bookmarkから何件か取得する
    my $row = $c->model('RemainderDB::Bookmark')->find({
        userid => $userid,
    }, key => 'bookmarkid' );

    
}

sub remainder :Local {
	my ($self ,$c) = @_;
	#$c->response->body('こんにちは');
    #$c->stash->{list} = [$c->model('CatalDB::Book')->all];
    #$c->stash->{title} = 'Remainder - あなたの気になるをお知らせ！ -';
   
}

sub signin :Local{
    my ($self,$c) = @_;

    if($c->req->method eq 'POST'){
        my $username = $c->request->body_params->{'username'};
        my $password = $c->request->body_params->{'editedmemo'};
        my $editedmemo = $c->request->body_params->{'editedmemo'};
    }
}

sub memo :Local {
    my ($self ,$c) = @_;
    #### Edit memo in form.htm.
    my $memoedit = $c->request->body_params->{'memoedit'};
    # Update memo
    #sql
    
    #$c->stash->{list} = [$c->model('CatalDB::Book')->all];
    #my $memo = "";
    my $memo = $c->request->body_params->{'memo'};
    #print "$memo\n";
#    my $weektimes = $c->request->body_params->{'weektimes'};
    #my $fromtime = $c->request->body_params->{'days'};
    
    my @days = $c->request->body_params->{'days'};
    my $daystext = "";
    foreach (@days){
        $daystext = $daystext.$_;
    } 
    #print $days,"\n";
    #$c->stash->{day} = join ',',@$day;
    my $notification = $c->request->body_params->{'notification'};
	#$c->stash->{list} = [$c->model('CatalremaindDB::RemainderMemo')->all];
    #レコードへ登録
#    $memo =$memo.".";
    my $fromyear = $c->request->body_params->{'fromyear'};
    my $frommonth = $c->request->body_params->{'frommonth'};
    my $fromday = $c->request->body_params->{'fromday'};
    my $toyear = $c->request->body_params->{'toyear'};
    my $tomonth = $c->request->body_params->{'tomonth'};
    my $today = $c->request->body_params->{'today'};
    my $fromhour = $c->request->body_params->{'hour'};
    my $frommin = $c->request->body_params->{'minute'};

    my $fromtime = $fromyear."-".$frommonth."-".$fromday." ".$fromhour.":".$frommin.":00";
    my $totime = $toyear."-".$tomonth."-".$today." ".$fromhour.":".$frommin.":00";
    #data source
    my $d = "DBI:mysql:RemainderMemo";
    my $u = "remainderuser";
    my $p = "remainderpass";
    
    #Connect database;
    my $dbh = DBI->connect($d,$u,$p);
#    my $loginuseremail = $c->request->body_params->{'loginuseremail'};
    my $loginuseremail = "tashirohiro4\@gmail.com";

    #If user logined site,We check email by DataTable RemainderUsers.Because Email is Primary.
    #$c->stash->{useremail} = $c->model('RemainderDB::RemainderUsers')->find('tashirohiro4\@gmail.com');
    $c->stash->{useremail} = $loginuseremail;
    #$useremail =  $c->model('RemainderDB::RemainderMemo')->find('$loginuseremail',{key => 'useremail'});
    
    #Create for new login user.
    
    
    if($memo ne ''){
        
        my $row = $c->model('RemainderDB::RemainderMemo')->create({
            userid => 'tashirohiro4',
            memo => $memo,
            #weektimes => $weektimes,
            tag => '',
            fromtime => "$fromtime",
            totime => "$totime",
            days => "$daystext",
            notification => $notification,
            #created => 'NOW()',
            #updated => 'NOW()',
        });
        
    }

    $c->model('RemainderDB')->storage->debug(1);
    #mysql からmemoを取得し、.ttへ渡す
    $c->stash->{remaindermemo} = [$c->model('RemainderDB::RemainderMemo')->all];
    #$c->response->body('success')

    #print $day;
    #$c->stash->{day} = join ',',@$day;

    #日付を指定して生成
    my $dt = DateTime->new(
        time_zone => 'Asia/Tokyo',
        year      => 2008,
        month     => 8,
        day       => 4,
        hour      => 15,
        minute    => 0,
        second    => 0
        );

    #epochから生成
    $dt = DateTime->from_epoch( time_zone => 'Asia/Tokyo', epoch => 1217829600 );
    
    #現在の日付(時間ふくむ)
    $dt = DateTime->now( time_zone => 'Asia/Tokyo' );
    $c->stash->{datetimenow} = $dt;
    my  $day_abbr    = $dt->day_abbr;   # 曜日の省略名
    $c->stash->{datetimeweekly} = $day_abbr;

    my $dtto = DateTime->now( time_zone => 'Asia/Tokyo' )->add(months => 12 );
    #$dtto=$dtto->add( months => 12 );
    $c->stash->{datetimeto} = $dtto;

    #月末日を取得
    my $dt2 = DateTime->last_day_of_month( year => 2008, month => 11 );
    $c->stash->{day} = $dt2->day;
    
    #tag付け
    my $tags = "tag1,タグ2,タグ3,ＴＡＧＵ4,Tag 5,tag6";#日本語が使えない;use utf8しておくと２バイト文字が表示できない
    #my $tag1 = "tag1";
    #my $tag2 = "tag2";
    my @tagsarray=();
    my @list=split(/,/,$tags);
    foreach(@list){
        push(@tagsarray, $_);
    }
        #@list = ['Perl', 'php'];
    #$c->stash->{array_t} = \@list; #stashに渡すのは,['perl','php']でないと,うまくいかない
    #my %hash = {'Practical' => 'Perl', 'PP' => 'php'};
    #my @tags = [$tag1,$tag2];
    #$c->stash->{tagslist} = \@tags;# {'Practical' => 'Perl', 'PP' => 'php'}#%hash; #stashに渡すのは,['perl','php']でないと,うまくいかない
    my @array = ( 'test1', 'test2', 'test3' );#日本語が使えない

    $c->stash->{tagsarray} = \@tagsarray; # ハッシュや配列の場合はリファレンスでセットする
    #$c->stash->{textjp} = 'テスト';
    #my %hash = {text1 => 'テスト１',text2 => 'テスト２' };

    #$c->stash->{messageh} = \%hash; # ハッシュや配列の場合はリファレンスでセットする

}

sub memolist :Local {
	my ($self ,$c) = @_;
	$c->stash->{list} = [$c->model('RemainderDB::RemainderMemo')->all];
}

sub oauth :Local {
	my ($self ,$c) = @_;
	
}

sub oauthphp :Local {
	my ($self ,$c) = @_;
	
}

=head1 AUTHOR

th4,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
