#!/usr/bin/perl
use strict;
use DBI;

#my @ary = DBI->available_drivers();
#print join("\n", @ary), "\n";

my $dbh = DBI->connect(          
    "dbi:mysql:dbname=autosms", 
    "root",                          
    "asdqwe",                          
    { RaiseError => 1 },         
) or die $DBI::errstr;
my $sth = $dbh->prepare("SELECT * from tabletest");
$sth->execute() or die $DBI::errstr;

print "Number of rows found :" + $sth->rows;
while (my @row = $sth->fetchrow_array()) {
   my ($no, $aa, $bb, $cc ) = @row;
   print "$no $aa $bb $cc\n";
   #print "First Name = $first_name, Last Name = $last_name\n";
}
$sth->finish();


$dbh->disconnect();
