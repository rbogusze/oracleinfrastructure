#!/usr/bin/perl 
 # 
 #count_log_switches.pl 
 # 
 #Scans the contents of the alert log looking for log switches and stores
 # the results in an array(date) of arrays(hour) 
 # tricky bit was to get the output in the right order 
 # 
 # Version       By      Decsription 
 # 1.0           JDA     Initial Revision 
 # 
 
 $db_sid = $ENV{ORACLE_SID}; 

# @check_files=("/database/816/$db_sid/bdump/alert_$db_sid.log"); 
# @check_files=("/AR/u01/app/oracle/admin/AR/bdump/alert_AR.log"); 
# @check_files=("/u01/prddb/9.2.0/admin/PRD_wilgadb/bdump/alert_PRD.log"); 
 @check_files=("/HP_42_OL/u01/app/oracle/admin/HP_42_OL/bdump/alert_HP_42_OL.log"); 
 @log_date = (); 
 @months = 
 ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"); 
 @hours = 
 ("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","00");

 
 #does the db_check directory exist? 
 if ( !-d "/tmp/db_check" ) { 
  mkdir ("/tmp/db_check",0755) || die "Cannot create dir /tmp/db_check" ; 
 } 
 #loop through possible alert logs 
 for $check_file (@check_files) { 
  if ( -f "$check_file" ) { 
   open(ALERT_LOG,"$check_file") || die "Cannot open $check_file"; 
    print STDOUT "Checking the contents of $check_file for log switches\n\n"; 
    while( $line = <ALERT_LOG> ) { 
     $thread_line=$line; 
     if ( $thread_line =~ /Thread.*advanced.*/) { 
      #found a log switch - the date_line variable will also be set now 
      $log_date{$date}{$hour} = $log_date{$date}{$hour} + 1; 
     } 
     elsif ( $thread_line =~ /^[A-Z][a-z]+\s+[A-Z]\w+\s+\d+\s+\d+:/) { 
      #remember the date and process it to extract the date/hour 
      ($date_line,$min,$sec) = split(/:/,$thread_line); 
      ($day,$mon,$dat,$hour) = split(/\s+/,$date_line); 
      $date = $dat . " " . $day . " " . $mon; 
     }  
    } 
   close(ALERT_LOG); 
  } 
 } 
 
 print "    Time     1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  00\n"; 
 print "Date \n"; 
 
 for $month (@months) { 
  $day = 1; 
  while ( $day < 32 )  { 
   while(($date,$value)= each %log_date  ) { 
    if ( $date =~ m/$month/g ) { 
     if ( $date =~ m/^$day\b.*/ ) { 
      printf "%10s", $date; 
      for $hour (@hours) { 
       printf "%4s", $log_date{$date}{$hour}; 
      } 
      print "\n"; 
     } 
    } 
   } 
   $day = $day + 1; 
  } 
 }
