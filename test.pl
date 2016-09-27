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

my $dbh = DBI->connect(          
    "dbi:mysql:dbname=autosms", 
    "ksoo",                          
    "asdqwe",                          
    { RaiseError => 1 },         
) or die $DBI::errstr;

#print "hello world";
#exit;
my $api_key = 'AIzaSyD9HetdrNyVbNU-de4bW1UWf2f9YvhLxf8';
my $google  = WWW::Google::URLShortener->new({ api_key => $api_key });

my @userRows;
my @taskRows;
my @recentRows;

sub fetchRows{
  my $sth = $dbh->prepare("SELECT * from USER_TABLE");
  $sth->execute() or die $DBI::errstr;

  #print "Number of rows found :" + $sth->rows;
  while (my @row = $sth->fetchrow_array()) {
    my ($id, $pw, $phone ) = @row;
    my %temp = (id => $id, pw => $pw, phone => $phone);
    push @userRows, \%temp;
    #print "First Name = $first_name, Last Name = $last_name\n";
  }
  $sth->finish();

  print Dumper(\@userRows);

}

fetchRows();
exit;
#sendSMS("01073177595", "vvvv");
#cse_free();

sub sendSMS{
  my ($phone, $content) = @_;

  $phone =~ /(\d{3})(\d{4})(\d{4})/;
  my $a1 = $1;
  my $a2 = $2;
  my $a3 = $3;
  print "$a1 $a2 $a3\n";
  exit;



  my $url = "http://mspeeder.kr/sms_sender2.php?action=go&smsType=S&subject=제목&msg=$content&rphone=01073177595&sphone1=010&sphone2=7317&sphone3=7595&nointeractive=1&repeatNum=1&repeatTime=15";
  my $content = get($url);
}
sub cse_free{
  my $localLastNo;
  #unless(-e "lastno.txt"){
    #$lastNo = 0; 
  #}
  #else{
    #open FH, "<", "lastno.txt" or die "$!\n";
    #$lastNo = int<FH>;
    #close FH;
  #}
  #print "lastNo = $lastNo\n";
  my $sth = $dbh->prepare("SELECT * from RECENT_TABLE where type = 'cse_free'");
  $sth->execute() or die $DBI::errstr;

  my ($type, $recentNo) = $sth->fetchrow();
  print "$type, $recentNo\n";
  $sth->finish();
#exit;
  my $url = 'http://uwcms.pusan.ac.kr/user/indexSub.action?codyMenuSeq=21712&siteId=cse';
  my $res = HTTP::Tiny->new->get($url); 
  my $html = $res->{content}; 
  my $dom = Mojo::DOM->new($html); 
  my $maxNo = -1e9;
  print "send list\n";
#$lastNo = 98;
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
      my $url = "http://mspeeder.kr/sms_sender2.php?action=go&smsType=S&subject=제목&msg=$title&rphone=01073177595&sphone1=010&sphone2=7317&sphone3=7595&nointeractive=1&repeatNum=1&repeatTime=15";
      my $content = get($url);
      #print $content;

      #print "$title\n";

    }
  }
  print "-----------\n";

  if($maxNo > $localLastNo){
    print "LastNo was updated\n";
    open FH, ">", "lastno.txt" or die "$!\n";
    print FH $maxNo;
    close FH;
  }


}

##########################################################################
$dbh->disconnect();
