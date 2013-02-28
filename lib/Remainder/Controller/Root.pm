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

use Digest::MD5 qw/md5_hex/;

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
        if($c->authenticate({ userid => $uid ,passwd => $passwd })){
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
=pod
sub twitteroauth : Path :Args(0) {
    my ( $self, $c ) = @_;
 
    my $consumer = OAuth::Lite::Consumer->new(Remainder::Const::TOKENS);
    my $request_token = $consumer->get_request_token();
    my $uri = URI->new($consumer->{authorize_path});
 
    $uri->query($consumer->gen_auth_query("GET",$consumer->{site},$request_token));
    $c->stash->{authquery} = $uri->as_string;
 
    $c->stash->{template} = 'twitteroauth.tt';
}

=cut
sub auth : Local {
    my ( $self, $c) = @_;
 
    my $app_id = '376987082389393';
    my $app_secret = 'e98421b675023fc82eccf180eda6ef68';
    my $authz_endpoint = 'https://www.facebook.com/dialog/oauth';
    my $token_endpoint = 'https://graph.facebook.com/oauth/access_token';
    # Facebook Developers の Website with Facebook Login の Site URL
    my $redirect_uri = 'http://localhost:3000/auth';

    # 2) get authorization code
    if ( my $code = $c->req->param('code') ) {

        # 3) get access token
        my $uri = URI->new($token_endpoint);
        $uri->query_form(
            client_id     => $app_id,
            client_secret => $app_secret,
            redirect_uri  => $redirect_uri,
            code          => $code
            );
        my $ua     = LWP::UserAgent->new;
        my $r      = $ua->get($uri);
        my %params = ();
        for my $pair ( split( /&/, $r->content ) ) {
            my ( $key, $value ) = split( /=/, $pair );
            $params{$key} = $value;
        }
        my $token = $params{access_token};

        # 4) get protected resources
        if ($token) {
            my $url = 'https://graph.facebook.com/me/friends';
            print "===============\n";
            print $url,"\n";
        } else {
            $c->response->body('fail to get token');
        }

    } else { # 1) redirect to authorization endpoint

        my $uri = URI->new($authz_endpoint);
        $uri->query_form(
            client_id    => $app_id,
            redirect_uri => $redirect_uri,
            );
        $c->res->redirect($uri);
    }

}


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


sub logout : Local {
    my ($self, $c) = @_;
    $c->logout();
    $c->response->redirect("/");
}

#全認証
sub auto : Private {
    my ($self, $c) = @_;
    if ($c->action->reverse eq 'index' || $c->action->reverse eq 'signin' || $c->action->reverse eq 'auth') { return 1; }
    
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

=pod
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

=cut


#新規ユーザー登録
sub signin :Local{
    my ($self,$c) = @_;

    
    if($c->req->method eq 'POST'){
        my $userid = $c->request->body_params->{'uid'};
        my $passwd = $c->request->params->{'passwd'};
        my $unam = $c->request->body_params->{'unam'};
        my $uemail = $c->request->body_params->{'uemail'};

        my $signin = $c->model('RemainderDB::User')->create({
            userid => $userid,
            passwd => md5_hex($passwd),
            unam => $unam,
            uemail => $uemail
        });
        if($signin->in_storage){
            $c->response->redirect("/index");
            #$c->response->body("okok$editedmemo");
        }

    }
}

sub loginfacebook :Local {
    my ($self,$c) = @_;
}

sub search_literal :Local{
    my ($self,$c)=@_;
    $c->stash->{list} = [$c->model('RemainderDB::RemainderMemo')
                         ->search_literal('memo like ? ','%test%')];
    $c->stash->{template} = 'list.tt';
}
    
sub memo :Local {
    my ($self ,$c,$page) = @_;
    
    #### Edit memo in form.htm.
    my $memoedit = $c->request->body_params->{'memoedit'};
    # Update memo
    
    #$c->stash->{list} = [$c->model('CatalDB::Book')->all];
    #my $memo = "";
    my $memo = $c->request->body_params->{'memo'};
    #print "$memo\n";
#    my $weektimes = $c->request->body_params->{'weektimes'};
    #my $fromtime = $c->request->body_params->{'days'};
    
    my $days = $c->request->body_params->{'days'}; 
    print Dumper $days;
    #一つの曜日だけ指定するとエラーになる
    my $daystext = "";
    if(ref($days) eq 'ARRAY'){
        foreach (@$days){
            $daystext = $daystext.$_.",";
        }
    }else{
        $daystext = $days;
    }
    #print "==========",$daystext;
    #print $daystext,"\n";
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
    my $loginuseremail = "tashirohiro4\@gmail.com";

    #If user logined site,We check email by DataTable RemainderUsers.Because Email is Primary.
    #$c->stash->{useremail} = $c->model('RemainderDB::RemainderUsers')->find('tashirohiro4\@gmail.com');
    $c->stash->{useremail} = $loginuseremail;
    #$useremail =  $c->model('RemainderDB::RemainderMemo')->find('$loginuseremail',{key => 'useremail'});
    
    #Create for new login user.
    
    my $userid = $c->user->get('userid');
    #create new memo.
    if($c->req->method eq 'POST'){
        if($memo ne ''){
            
            my $row = $c->model('RemainderDB::RemainderMemo')->create({
                userid => $userid, #login しているuserid
                memo => $memo,
                #weektimes => $weektimes,
                tag => '',
                fromtime => "$fromtime",
                totime => "$totime",
                days => $daystext,
                notification => $notification,
                #created => 'NOW()',
                #updated => 'NOW()',
                                                                      });
            
        }
        $c->response->redirect("/memo");
    }
    $c->model('RemainderDB')->storage->debug(1);
    #ログインしているuseridに応じて表示する。また、
    #mysql からmemoを取得し、.ttへ渡す
    #$c->stash->{remaindermemo} = [$c->model('RemainderDB::RemainderMemo')->all];
    #$c->response->body('success')
    
    #5レコードを取得/memo/2,/memo/3..などで取得できる
    $page = 1 unless $page;
    $c->stash->{remaindermemo} = [$c->model('RemainderDB::RemainderMemo')
                                  ->search({ userid => $userid},{
                                           order_by => {-desc => 'id'},
                                           rows => 5,
                                           page => $page
                                           })];
    
    use Data::Dumper;
#    print Dumper [$c->model('RemainderDB::RemainderMemo')->search({ userid => 'tsuzuki'})];
#    $c->stash->{template} = 'memo.tt';
    
    #print $day;
    #$c->stash->{day} = join ',',@$day;
    #現在の日付(時間ふくむ)
    my $dt = DateTime->now( time_zone => 'Asia/Tokyo' );
    $c->stash->{datetimenow} = $dt;
    my  $day_abbr    = $dt->day_abbr;   # 曜日の省略名
    $c->stash->{datetimeweekly} = $day_abbr;

    my $dtto = DateTime->now( time_zone => 'Asia/Tokyo' )->add(months => 1 );
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
