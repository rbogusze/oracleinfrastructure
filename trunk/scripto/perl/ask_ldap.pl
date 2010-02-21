#!/usr/bin/perl
# This script asks the ldap server
#
#use strict;
use warnings;
use Net::LDAP;

$my_filter = $ARGV[0];
$my_attributes = $ARGV[1];
my $connection_status = 0;

while (! $connection_status) { # Try to connect untill successfull
  if ($ldap = Net::LDAP->new("orainf")) {
    $ldap = Net::LDAP->new("orainf", timeout=>30);
    $mesg = $ldap->bind;
    $mesg = $ldap->search(filter=>"$my_filter", base=>"dc=orainf,dc=com", attrs=>"$my_attributes");
    @entries = $mesg->entries;

    # Now I need to make that string $my_attributes into an array
    $tmp = $my_attributes;
    $tmp =~ s/['\[\]\ ]//g;
    @my_attributes_array = split(/,/, $tmp);

    foreach $entry (@entries) {
        foreach $attr_user (@my_attributes_array) {
                printf("%s ", $entry->get_value($attr_user));
        }
        print "\n";
    }

    $ldap->unbind;
    $connection_status = 1;

  } else {
    #print "Unable to connect to LDAP server. Sleep 5 sek.\n";
    sleep 5;
    $connection_status = 0;
  } # if 
} # while
