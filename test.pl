#!/usr/bin/perl

#use local::lib;
use Data::Dumper;
use HTTP::Tiny; 
use Mojo::DOM; 
use LWP::Simple;
use WWW::Google::URLShortener;

use strict;
use DBI;

#my @ary = DBI->available_drivers();
#print join("\n", @ary), "\n";


my $host = "59.22.105.139";
my $dbh = DBI->connect(          
    "dbi:mysql:dbname=autosms;host=$host", 
    "ksoo",                          
    "asdqwe",                          
    { RaiseError => 1 },         
) or die $DBI::errstr;

#print "hello world";
#exit;
my $api_key = 'AIzaSyD9HetdrNyVbNU-de4bW1UWf2f9YvhLxf8';
my $google  = WWW::Google::URLShortener->new({ api_key => $api_key });

my %userRows;
my @taskRows;
my @recentRows;

sub fetchRows{
  my $sth = $dbh->prepare("SELECT * from USER_TABLE");
  $sth->execute() or die $DBI::errstr;

  #print "Number of rows found :" + $sth->rows;
  while (my @row = $sth->fetchrow_array()) {
    my ($id, $pw, $phone ) = @row;
    $userRows{"$id"} = {"phone" => $phone};
    #push @userRows, \%temp;
    #print "First Name = $first_name, Last Name = $last_name\n";
  }
  $sth->finish();

  my $sth = $dbh->prepare("SELECT * from TASK_TABLE");
  $sth->execute() or die $DBI::errstr;

  #print "Number of rows found :" + $sth->rows;
  while (my @row = $sth->fetchrow_array()) {
    my ($id, $user_id, $type ) = @row;
    my %temp = (user_id => $user_id, type => $type);
    push @taskRows, \%temp;
    #print "First Name = $first_name, Last Name = $last_name\n";
  }
  $sth->finish();

  my $sth = $dbh->prepare("SELECT * from RECENT_TABLE");
  $sth->execute() or die $DBI::errstr;

  #print "Number of rows found :" + $sth->rows;
  while (my @row = $sth->fetchrow_array()) {
    my ($type, $no) = @row;
    my %temp = (type => $type, no => $no);
    push @recentRows, \%temp;
    #print "First Name = $first_name, Last Name = $last_name\n";
  }
  $sth->finish();
  #print Dumper(\%userRows);
  #print Dumper(\@taskRows);
  #print Dumper(\@recentRows);

}

fetchRows();

#sendSMS("01073177595", "[학생회] 16년도 하반기 사물함 배정 결과 https://goo.gl/db6Xna");

cse_free();
# cse_free 호출...
exit;
#sendSMS("01073177595", "vvvv");
#cse_free();



##########################################################################
$dbh->disconnect();

sub sendSMS{
  my ($phone, $content) = @_;

  $phone =~ /(\d{3})(\d{4})(\d{4})/;
  my $a1 = $1;
  my $a2 = $2;
  my $a3 = $3;
  print "$a1 $a2 $a3\n";
  #exit;



  my $url = "http://mspeeder.kr/sms_sender2.php?action=go&smsType=S&subject=제목&msg=$content&rphone=$a1$a2$a3&sphone1=$a1&sphone2=$a2&sphone3=$a3&nointeractive=1&repeatNum=1&repeatTime=15";
  my $content = get($url);
}
sub cse_free{
  my $localLastNo = 0;

  for(@recentRows){
    if($_->{"type"} eq "cse_free"){
      $localLastNo = $_->{"no"}; 
    }
    print "type is = ". $_->{"type"} . "$/";
  }
  print "localLastNo = $localLastNo\n";
  # recenttable 에서 type=cse_free 인 경우의 no 를 얻어와서 $localLastNo 에 넣는다.
  my $url = 'http://uwcms.pusan.ac.kr/user/indexSub.action?codyMenuSeq=21712&siteId=cse';
  my $res = HTTP::Tiny->new->get($url); 
  my $html = $res->{content}; 
  my $dom = Mojo::DOM->new($html); 
  my $maxNo = -1e9;
  print "send list\n";
  for my $post ( $dom->find('table[summary="게시판리스트"]>tbody>tr')->each ) { 
    my $title = $post->at('[class="title"]')->all_text;
    my $no = $post->at('[class="no"]')->all_text;
    my $ahref = 'http://uwcms.pusan.ac.kr/user/' . $post->at('[class="title"]>a')->attr('href');

    $ahref = $google->shorten_url($ahref);
    $title =~ s/\s+$//g;
    $title =~ s/^\s+//g;
    $title =~ s/\n.+/\1/g;

    $maxNo = $no if $maxNo < $no;
    #print "[$no]$title \n $ahref\n";
    $title .=  $ahref;
    if($no > $localLastNo){ 
      for(@taskRows){
        my $id = $_->{"user_id"};
        #sendSMS($userRows{$id}->{"phone"}, $title);
      }
    }
  }
  print "-----------\n";

  if($maxNo > $localLastNo){
    my $sth = $dbh->prepare("update RECENT_TABLE set no = $maxNo where type = 'cse_free' ");
    $sth->execute() or die $DBI::errstr;
    $sth->finish();

    print "LastNo was updated\n";
  } 
}

