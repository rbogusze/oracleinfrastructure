#!/usr/bin/perl
#$Header: /CVS/cvsadmin/cvsrepository/admin/projects/tremon/tremon.pl,v 1.69 2010/08/23 08:21:39 remikcvs Exp $
# This script 
#
# - I do not understand why do I have access to all atributes

use strict;
use Net::LDAP;
use Net::SSH::Perl;
use Math::BigInt::GMP;  # Don't forget this! sppedsup ssh connection
use DBI;
use File::stat;
use Time::localtime;
use Log::Log4perl qw(:easy); # http://www.perl.com/pub/a/2002/09/11/log4perl.html?page=1
use IO::Socket::INET;  # For open ports monitoring
use DBD::Oracle;

# Should be taken from environment
#$ENV{'ORACLE_HOME'}='/home/orainf/oracle/product/11.2.0/client_1';

Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($WARN);
my $logger = get_logger();

package TremorMonitoring;
sub new {
        my $self  = {};
        $self->{NAME}    = undef;
        $self->{DESC}    = undef;
        $self->{FILTER}    = undef;
        $self->{PASSWORD}    = undef;
        $self->{ATTRIBUTES}    = undef;
        $self->{PEERS}  = [];
        bless($self);           # but see below
        return $self;
    }

sub name {
        my $self = shift;
        if (@_) { $self->{NAME} = shift }
        return $self->{NAME};
}

sub desc {
        my $self = shift;
        if (@_) { $self->{DESC} = shift }
        return $self->{DESC};
}

sub filter {
        my $self = shift;
        if (@_) { $self->{FILTER} = shift }
        return $self->{FILTER};
}

sub password {
        my $self = shift;
        if (@_) { $self->{PASSWORD} = shift }
        return $self->{PASSWORD};
}

sub attributes {
        my $self = shift;
        if (@_) { $self->{ATTRIBUTES} = shift }
        return $self->{ATTRIBUTES};
}

sub attributes_values {
        my $self = shift;
        if (@_) { $self->{ATTRIBUTES_VALUES} = shift }
        return $self->{ATTRIBUTES_VALUES};
}

sub remik {
        my $self = shift;
        if (@_) { $self->{REMIK} = shift }
        return $self->{REMIK};
}

sub peers {
        my $self = shift;
        if (@_) { @{ $self->{PEERS} } = @_ }
        return @{ $self->{PEERS} };
}

# Decide based on name which action to take
sub action {
  my $self = shift;
  #
  # Action - RmanCorruption
  #
  if ($self->{NAME} eq "RmanCorruption") {
    $logger->info("--Doing stuff for RmanCorruption ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
    # Check if the time has come to run this trigger
    if (check_frequency($self->{NAME}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), $self->{ATTRIBUTES_VALUES}->get_value('orainfDbCheckRmanCorruptionFrequency'))) { return; }
    eval {
    my $dbh = DBI->connect( 
                   'dbi:Oracle:'.$self->{ATTRIBUTES_VALUES}->get_value('cn')
                   ,$self->{ATTRIBUTES_VALUES}->get_value('orainfDbRrdoraUser')
                   ,$self->{PASSWORD},
                   { RaiseError => 1,AutoCommit => 0}
                   ) || die "Database connection not made : $DBI::errstr";
    #my $sql = qq{ select sysdate from dual };
    my $sql = qq{ select * from V\$DATABASE_BLOCK_CORRUPTION };
    my $sth = $dbh->prepare( $sql );
    $sth->execute();

    # If there are some rows returned I consider that corruption reported.
    if ( $sth->fetch() ) {
      $logger->debug("There are some rows returned I consider that corruption reported.\n");
      monitor_treshold(
        1,
        " ",
        $self->{DESC},
        $self->{ATTRIBUTES_VALUES}->get_value('cn'),
        0,
        0,
        $self->{ATTRIBUTES_VALUES}->get_value('orainfDbCheckRmanCorruptionReceipients'),
        $self->{ATTRIBUTES_VALUES}->get_value('orainfDbCheckRmanCorruptionReceipients')
      ); # monitor_treshold(

    } else {
      $logger->debug("NO rows returned that could indicate found corruptions.\n");
    }
   
    $sth->finish(); 
    $dbh->disconnect();
    }; #eval
    if ($@) # $@ contains the exception that was thrown
    {
      $logger->error("Checking for RmanCorruption. Could not connect to ",$self->{ATTRIBUTES_VALUES}->get_value('cn'),"\n");
      $logger->error($@);
    } # if ($@) 
    $logger->info("--/Doing stuff for RmanCorruption ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
    
  } # if ($self->{NAME} eq "RmanCorruption") 
  #
  # /Action - RmanCorruption
  #



  #
  # Action - TnspingMonitoring
  #
  # It actually does a little more than tnsping, it tries to connect and perform
  # the select * from dual;
  if ($self->{NAME} eq "TnspingMonitoring") {
    $logger->info("--Doing stuff for TnspingMonitoring ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
    # Check if the time has come to run this trigger
    if (check_frequency($self->{NAME}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), $self->{ATTRIBUTES_VALUES}->get_value('orainfDbTnspingMonitoringFrequency'))) { return; }
    eval {


    my $dbh = DBI->connect( 
                   'dbi:Oracle:'.$self->{ATTRIBUTES_VALUES}->get_value('cn')
                   ,$self->{ATTRIBUTES_VALUES}->get_value('orainfDbRrdoraUser')
                   ,'perfstat',
                   { RaiseError => 1,AutoCommit => 0}
                   ); 
    my $sql = qq{ SELECT * FROM dual };
    my $sth = $dbh->prepare( $sql );
    $sth->execute();
    $sth->finish();
    $dbh->disconnect();
    };
    $logger->debug("ala ma kota\n");
    my $flag_L1 = "/tmp/TnspingMonitoringL1_".$self->{ATTRIBUTES_VALUES}->get_value('cn');
    my $flag_L2 = "/tmp/TnspingMonitoringL2_".$self->{ATTRIBUTES_VALUES}->get_value('cn');

    # Check if tnsping was successful
    if ($@) # $@ contains the exception that was thrown
    {
      $logger->error("[tremor][error] There was an error during tnsping with select to\n");
      $logger->error($@);
      # Check if L1 flag exists
      if (-e $flag_L1) {
        # Check if it is time to escalate to L2
        $logger->debug("L1 flag exists\n");
	my @stat = stat "$flag_L1";
	my $flag_L1_time = scalar $stat[9]; # File creation time in seconds since the epoch
	$logger->debug("File mtime = ", $flag_L1_time,  "\n");
	$logger->debug("Difference = ", time() - $flag_L1_time,  "\n");
	if ((time() - $flag_L1_time) > ($self->{ATTRIBUTES_VALUES}->get_value('orainfDbTnspingMonitoringEscalation') * 60)) {
	  $logger->debug("Time to escalate to L2\n");
	  monitor_treshold( 2, " ", $self->{DESC}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), 0, 1, $self->{ATTRIBUTES_VALUES}->get_value('orainfDbTnspingMonitoringReceipientsL1'), $self->{ATTRIBUTES_VALUES}->get_value('orainfDbTnspingMonitoringReceipientsL2'));
	} else {
	  $logger->debug("Not yet a time to escalate to L2. L1 actions for now.\n");
	  monitor_treshold( 1, " ", $self->{DESC}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), 0, 1, $self->{ATTRIBUTES_VALUES}->get_value('orainfDbTnspingMonitoringReceipientsL1'), $self->{ATTRIBUTES_VALUES}->get_value('orainfDbTnspingMonitoringReceipientsL2'));
	}
      } else {
        # Set the L1 flag and perform actions
        $logger->debug("L1 flag does not exists. Creating one.\n");
	open(FH,">$flag_L1") or die "Can't create new.txt: $!";
	close(FH);
	monitor_treshold( 1, " ", $self->{DESC}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), 0, 1, $self->{ATTRIBUTES_VALUES}->get_value('orainfDbTnspingMonitoringReceipientsL1'), $self->{ATTRIBUTES_VALUES}->get_value('orainfDbTnspingMonitoringReceipientsL2'));
      } # if (-e $flag_L1)
      
    } else {
      # Tnsping was OK, clearing flags if exists
      $logger->debug("Everything looks fine, clearing previous warnings if they exists\n");
      rename "$flag_L1","/tmp/cleared_L1";
      rename "$flag_L2","/tmp/cleared_L2";
    } # eval
    $logger->info("--/Doing stuff for TnspingMonitoring ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
  } # "TnspingMonitoring"

  #
  # /Action - TnspingMonitoring
  #
  # Action - PortMonitoring
  #
  if ($self->{NAME} eq "PortMonitoring") {
    $logger->info("--Doing stuff for PortMonitoring ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
    # Check if the time has come to run this trigger
    if (check_frequency($self->{NAME}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), $self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringFrequency'))) { return; }
    my $flag_L1 = "/tmp/PortMonitoringL1_".$self->{ATTRIBUTES_VALUES}->get_value('cn');
    my $flag_L2 = "/tmp/PortMonitoringL2_".$self->{ATTRIBUTES_VALUES}->get_value('cn');
    # Build an array of ports
    my @peer_ports = split(',',$self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringPorts'));
    foreach my $peer_port (@peer_ports) {
      $logger->debug("PortMonitoring. Checking port ", $peer_port, " on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
   
      # Check if the port is open
      if (IO::Socket::INET->new(PeerAddr => $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'),
                         PeerPort => $peer_port,
                         Proto    => 'tcp',))
      {
        print "Port open.\n";
        # Port is open - OK, clearing flags if exists
        $logger->debug("PortMonitoring. Port ", $peer_port," on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName')," open, clearing previous warnings if they exists\n");
        rename "$flag_L1","/tmp/cleared_L1";
        rename "$flag_L2","/tmp/cleared_L2";
      } else {
        print "Port closed.\n"; 

        $logger->error("PortMonitoring: Port ", $peer_port," on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName')," is closed.\n");
        $logger->error($@);
        # Check if L1 flag exists
        if (-e $flag_L1) {
          # Check if it is time to escalate to L2
          $logger->debug("L1 flag exists\n");
          my @stat = stat "$flag_L1";
          my $flag_L1_time = scalar $stat[9]; # File creation time in seconds since the epoch
          $logger->debug("File mtime = ", $flag_L1_time,  "\n");
          $logger->debug("Difference = ", time() - $flag_L1_time,  "\n");
          if ((time() - $flag_L1_time) > ($self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringEscalation') * 60)) {
	    $logger->debug("Time to escalate to L2\n");
	    monitor_treshold( 2, " ", $self->{DESC}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), 0, 1, $self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringReceipientsL1'), $self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringReceipientsL2'));
	  } else {
	    $logger->debug("Not yet a time to escalate to L2. L1 actions for now.\n");
	    monitor_treshold( 1, " ", $self->{DESC}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), 0, 1, $self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringReceipientsL1'), $self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringReceipientsL2'));
	  }
        } else {
          # Set the L1 flag and perform actions
          $logger->debug("L1 flag does not exists. Creating one.\n");
	  open(FH,">$flag_L1") or die "Can't create new.txt: $!";
	  close(FH);
	  monitor_treshold( 1, " ", $self->{DESC}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), 0, 1, $self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringReceipientsL1'), $self->{ATTRIBUTES_VALUES}->get_value('orainfPortMonitoringReceipientsL2'));
        } # if (-e $flag_L1)
      } # if (IO::Socket
    } # foreach my $peer_port
      $logger->info("--/Doing stuff for PortMonitoring ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
  } # "PortMonitoring"

  #
  # /Action - PortMonitoring
  #
  
  #
  # Action - JobsPackagesMonitoring
  #
  #
  if ($self->{NAME} eq "JobsPackagesMonitoring") {
    $logger->info("-- Doing stuff for JobsPackagesMonitoring ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
    
    # Check if the time has come to run this trigger
    if (check_frequency($self->{NAME}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), $self->{ATTRIBUTES_VALUES}->get_value('orainfDbCheckJobsPackagesFrequency'))) { return; }
    eval {
    my $dbh = DBI->connect( 
                   'dbi:Oracle:'.$self->{ATTRIBUTES_VALUES}->get_value('cn')
                   ,$self->{ATTRIBUTES_VALUES}->get_value('orainfDbRrdoraUser')
                   ,$self->{PASSWORD},
                   { RaiseError => 1,AutoCommit => 0}
                   ) || die "Database connection not made : $DBI::errstr";
    
    # Write the full info about checked jobs, packages to the touched file
    my $triger_name = $self->{NAME};
    my $object_name = $self->{ATTRIBUTES_VALUES}->get_value('cn');
    my $file ="/tmp/$triger_name.$object_name.touch";
    open(OUT_JOB,">>$file") or die "Can't create new.txt: $!";

    # Deal with jobs 
    my $sql = qq{ select LOG_USER, JOB from dba_jobs where BROKEN = 'Y' };
    my $sth = $dbh->prepare( $sql );
    $sth->execute();

    my( $log_user, $job);
    $sth->bind_columns( undef, \$log_user, \$job );

    while ( $sth->fetch() ) {
      $logger->debug("Found broken jobs.\n");
      $logger->debug($log_user, " ", $job, "\n");
      print OUT_JOB $log_user, " ", $job, "\n";
      monitor_treshold(
        $job,
        "User: $log_user Job nr: ",
        "Broken job on DB:",
        $self->{ATTRIBUTES_VALUES}->get_value('cn'),
        0,
        0,
        "file_append(/dev/null)",
        $self->{ATTRIBUTES_VALUES}->get_value('orainfDbCheckJobsPackagesReceipients')
      ); # monitor_treshold(
    } # while


    # Deal with packages
    my $sql = qq{ select object_name, owner, object_type from dba_objects where status != 'VALID' and OBJECT_TYPE not in ('MATERIALIZED VIEW','SYNONYM') order by owner };
    my $sth = $dbh->prepare( $sql );
    $sth->execute();

    my( $object_name, $owner, $object_type);
    $sth->bind_columns( undef, \$object_name, \$owner, \$object_type );

    while ( $sth->fetch() ) {
      $logger->debug("Found invalid packages.\n");
      $logger->debug($object_name, " ", $owner, " ", $object_type, "\n");
      print OUT_JOB $object_name, " ", $owner, " ", $object_type, "\n";
      monitor_treshold(
        1,
        "object_name: $object_name owner: $owner object_type: $object_type ",
        "Invalid package on DB:",
        $self->{ATTRIBUTES_VALUES}->get_value('cn'),
        0,
        0,
        "file_append(/dev/null)",
        $self->{ATTRIBUTES_VALUES}->get_value('orainfDbCheckJobsPackagesReceipients')
      ); # monitor_treshold(
    } # while

    # Done
   
    $logger->debug("ala ma kota \n");
    close(OUT_JOB);
    $sth->finish(); 
    $dbh->disconnect();
    }; #eval
    if ($@) # $@ contains the exception that was thrown
    {
      $logger->error("Checking for JobsPackagesMonitoring. Could not connect to ",$self->{ATTRIBUTES_VALUES}->get_value('cn'),"\n");
      $logger->error($@);
    } # if ($@) 
    $logger->info("--/Doing stuff for JobsPackagesMonitoring ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
    
  } # if ($self->{NAME} == "JobsPackagesMonitoring")

  #
  # /Action - JobsPackagesMonitoring
  #
  
  #
  # Action - TablespaceMonitoring
  #
  if ($self->{NAME} eq "TablespaceMonitoring") {
    $logger->info("-- Doing stuff for TablespaceMonitoring ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
    
    # Check if the time has come to run this trigger
    if (check_frequency($self->{NAME}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorTablespaceMonitoringFrequency'))) { return; }
    eval {
    my $dbh = DBI->connect( 
                   'dbi:Oracle:'.$self->{ATTRIBUTES_VALUES}->get_value('cn')
                   ,$self->{ATTRIBUTES_VALUES}->get_value('orainfDbRrdoraUser')
                   ,$self->{PASSWORD},
                   { RaiseError => 1,AutoCommit => 0}
                   ) || die "Database connection not made : $DBI::errstr";
    my $sql = qq{ 
      SELECT Total.name "Tablespace Name"
            , TO_CHAR(ROUND(100-(Free_space*100/total_space), 0)) TBS_full FROM
      ( select tablespace_name, sum(bytes/1024/1024) Free_Space
        from sys.dba_free_space
        group by tablespace_name
      ) Free,
      ( select b.name, sum(bytes/1024/1024) TOTAL_SPACE
        from sys.v_\$datafile a, sys.v_\$tablespace B
        where a.ts# = b.ts#
        group by b.name
      ) Total
      WHERE Free.Tablespace_name = Total.name
    };
    
    my $sth = $dbh->prepare( $sql );
    $sth->execute();

    my( $tbs_name, $tbs_full );
    $sth->bind_columns( undef, \$tbs_name, \$tbs_full );

    # Write the full info about checked tablespaces to the touched file
    my $triger_name = $self->{NAME};
    my $object_name = $self->{ATTRIBUTES_VALUES}->get_value('cn');
    my $file ="/tmp/$triger_name.$object_name.touch";
    open(OUT,">>$file") or die "Can't create new.txt: $!";

    while( $sth->fetch() ) {
      $logger->debug("TBS Monitoring: Looping through fetch:", $tbs_name, " ", $tbs_full,"\n");
      print OUT $tbs_name, " ", $tbs_full, "\n";
      if ($tbs_full =~ m/^\d+$/) { # Check if variable is numeric
        monitor_treshold(
          $tbs_full,
          $tbs_name,
          $self->{DESC},
          $self->{ATTRIBUTES_VALUES}->get_value('cn'),
          $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorTablespaceMonitoringTresholdL1'),
          $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorTablespaceMonitoringTresholdL2'),
          $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorTablespaceMonitoringReceipientsL1'),
          $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorTablespaceMonitoringReceipientsL2')
        ); # monitor_treshold(
      } # Check if variable is numeric
    }

    close(OUT);

    $sth->finish();
    $dbh->disconnect();
    }; #eval
    if ($@) # $@ contains the exception that was thrown
    {
      $logger->error("TablespaceMonitoring. Could not connect to",$self->{ATTRIBUTES_VALUES}->get_value('cn'),"\n");
      $logger->error($@);
    } # if ($@) 
    $logger->info("-- /Doing stuff for TablespaceMonitoring ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), "\n");
  
  } # if ($self->{NAME} == "TablespaceMonitoring")

  #
  # FilesystemMonitoring
  #
  if ($self->{NAME} eq "FilesystemMonitoring") {
    $logger->info("Doing stuff for FilesystemMonitoring, ", $self->{ATTRIBUTES_VALUES}->get_value('cn'), " which is on ", $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), " logging as user: ", $self->{ATTRIBUTES_VALUES}->get_value('orainfOsLogwatchUser'), "\n");
    # Check if the time has come to run this trigger
    if (check_frequency($self->{NAME}, $self->{ATTRIBUTES_VALUES}->get_value('cn'), $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorFilesystemMonitoringFrequency'))) { return; }
    
    #my $ssh = Net::SSH::Perl->new("obsdb1", debug => 1); # Error check this
    my $ssh = Net::SSH::Perl->new($self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'), protocol=>'2,1'); # Error check this
    eval { $ssh->login($self->{ATTRIBUTES_VALUES}->get_value('orainfOsLogwatchUser')); }; # Error check this
    warn $@ if $@;

    # Check df
    my $command = "df -h";
    my ($stdout, $stderr, $exit) = $ssh->cmd($command); # Check output
    
    # Loop through all the lines from df
    foreach my $df_line (split(/\n/, $stdout)) {
      #print "$df_line \n";
      $df_line =~ m/(\d+)%\s+(\S+)/;
      my $filesystem_use_prcnt = $1;
      my $filesystem_name = $2;
      # Now I have the procent, issue the checking routine
      # $1 - should be the % Use
      # $2 should the mount point
      if ($filesystem_use_prcnt) { 
        #print "Launching monitor_treshold\n";
        #print "podaje do monitor_treshold: $1 $2 \n";
        #
        # Extra checking for /lib /platform /sbin /usr
        # as on Solaris 10 they are virtual and it is OK if the are over 90%
        # that is why I exclude them
        #if (($filesystem_name ne '/lib')) {
        if (($filesystem_name ne '/lib')&&($filesystem_name ne '/platform')&&($filesystem_name ne '/sbin')&&($filesystem_name ne '/usr')) {
        monitor_treshold(
         $filesystem_use_prcnt, 
         $filesystem_name,
         $self->{DESC}, 
         $self->{ATTRIBUTES_VALUES}->get_value('orclSystemName'),
         $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorFilesystemMonitoringTresholdL1'),
         $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorFilesystemMonitoringTresholdL2'),
         $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorFilesystemMonitoringReceipientsL1'),
         $self->{ATTRIBUTES_VALUES}->get_value('orainfTremorFilesystemMonitoringReceipientsL2')
        );
        } # else { print "Skipping - $filesystem_name\n\n\n"; } # if (($filesystem_name !=
      } # if ($filesystem_use_prcnt)
    } # foreach my $df_line
  } # if ($self->{NAME} == "FilesystemMonitoring")
}

1;  # so the require or use succeeds  

sub monitor_treshold( ) {
  $logger->info("[Inside: monitor_treshold]");
  my $value=$_[0];
  my $desc =$_[1]; 
  my $object_desc =$_[2]; 
  my $where =$_[3]; 
  my $tresholdl1 =$_[4]; 
  my $tresholdl2 =$_[5]; 
  my $receipientsl1 =$_[6]; 
  my $receipientsl2 =$_[7]; 
  $logger->debug("[monitor_treshold()]Received parameters: \nvalue:".$value."\ndesc: ".$desc."\nobject_desc: ".$object_desc."\nwhere: ".$where."\ntresholdl1: ".$tresholdl1."\ntresholdl2: ".$tresholdl2."\nreceipientsl1: ".$receipientsl1."\nreceipientsl2: ".$receipientsl2."\n"); 
  if ($value > $tresholdl1) {
    $logger->info("[L1 warning]".$object_desc, " ", $where, " ", $desc, " ", $value, "\n");
    treshold_action($receipientsl1, $where, $desc, $value, "[L1 warning]".$object_desc);
  }
  if ($value > $tresholdl2) {
    $logger->info("[L2 warning]".$object_desc, " ", $where, " ", $desc, " ", $value, "\n");
    treshold_action($receipientsl2, $where, $desc, $value, "[L2 warning]".$object_desc);
  }
  $logger->info("[Leaving: monitor_treshold]");
} # monitor_treshold

# This function gets performs the actions desired if some treshold is exceeded
sub treshold_action( ) {
  my $receipients =$_[0];
  my $where =$_[1];
  my $desc =$_[2];
  my $value =$_[3];
  my $object_desc =$_[4];

  # print "[] I will do ", $receipients, "\n";
  # Split to sections based on '|'
  my @sections = split('\|',$receipients);
  # Decide what to do based on which section I am in
  foreach my $section (@sections) {
    #print $section, "\n";
    if ($section =~ m/^email\(/) {
      $section =~ s/^email\(//;
      $section =~ s/\)$//;
      #print $section, "\n";
      my @entries = split(',', $section);
      mkdir("/tmp/email", 0755);
      # For mail I want to store all the entries in one file and the send them all
      foreach my $entry (@entries) {
        #print $entry, " ", $object_desc, " ", $where, " ", $desc, " ", $value, "\n";
        open(OUT,">>/tmp/email/$entry") || die("Cannot Open File"); 
        print OUT $object_desc, " ", $where, " ", $desc, " ", $value, "\n";
        close OUT;
      }
      next;
    } #email
    if ($section =~ m/^email_sms\(/) {
      $section =~ s/^email_sms\(//;
      $section =~ s/\)$//;
      #print $section, "\n";
      my @entries = split(',', $section);
      mkdir("/tmp/email_sms", 0755);
      # For sms I want to send only the last message, all the prevoise ones are already in mail
      foreach my $entry (@entries) {
        #print $entry, "\n";
        open(OUT,">/tmp/email_sms/$entry") || die("Cannot Open File");
        print OUT $where, " ", $desc, " ", $value, "\n";
        close OUT;
      }
      next;
    } #email_sms
    if ($section =~ m/^file_append\(/) {
      $section =~ s/^file_append\(//;
      $section =~ s/\)$//;
      #print $section, "\n";
      my @entries = split(',', $section);
      foreach my $entry (@entries) {
        #print $entry, "\n";
        # Open the file for writing and put the line in it
        if ( open(OUT,">>$entry") ) {
          print OUT $object_desc, " ", $where, " ", $desc, " ", $value, "\n";
          close OUT;
        } else { print "[tremor][error] Cannot Open File: $entry for append"; } 
      }
      next;
    } #file_append
    die("Nieznana sekcja w receipients");
  }
  
} # sub treshold_action


# Creates the file with trigger name, then at each try to run the trigger 
# it checks if the interval is already big enough
sub check_frequency( ) {
  my $triger_name =$_[0];
  my $object_name =$_[1];
  my $object_frequency =$_[2];
  my $file ="/tmp/$triger_name.$object_name.touch";
  # print "$triger_name, $object_name, $object_frequency\n";

  # Check if the file exists, if it does not touch it and return OK
  if (-e $file) {
    #print "File does exists\n";
    my @stat = stat "$file";
    my $file_time = scalar $stat[9]; # File creation time in seconds since the epoch
    #print "File mtime = ", $file_time,  "\n";
    #print "Difference = ", time() - $file_time,  "\n";
    # The file exists, check how long was it created, decide if you need to return 0 or 1
    if ((time() - $file_time) > ($object_frequency * 60)) {
      $logger->debug("check_frequency: ACTION\n");
      # Refresh the file timestamp
      open(FH,">$file") or die "Can't create new.txt: $!";
      close(FH);
      return 0; 
    } else {
      $logger->debug("check_frequency: not a time for action\n");
      return 1; 
    }  
  } else {
    print "File does not exists for $triger_name.$object_name. Touching it and proceeding with ACTION.\n";
    open(FH,">$file") or die "Can't create new.txt: $!";
    close(FH);
    return 0; 
  }
 
  return 1;
}; # check_frequency
1;

# Actual Start of the Program
# Determining password for LDAP->orainfDbRrdoraUser user (I know, not elegant)
# WIP
open (MYFILE, '/home/orainf/.credentials') or die "Open of the file failed!";
while (<MYFILE>) {
  chomp;
  $logger->debug("$_\n");
  if ($_ =~ m/V_PASS/) {
    $logger->info("match\n");
    use vars qw($v_password);
    $v_password = $_;
    $v_password =~ s/V_PASS=//g;
    $logger->info("v_password: " . $v_password . "\n");
  } 
}
close (MYFILE); 


my $TablespaceMonitoring = TremorMonitoring->new();
$TablespaceMonitoring->name("TablespaceMonitoring");
$TablespaceMonitoring->desc("free_space_tablespaces");
$TablespaceMonitoring->filter("(orainfTremorTablespaceMonitoring=TRUE)");
$TablespaceMonitoring->password("$v_password");
$TablespaceMonitoring->attributes("['orclSystemName', 'orclNetDescString', 'orainfTremorTablespaceMonitoringTresholdL1', 'orainfTremorTablespaceMonitoringTresholdL2', 'orainfTremorTablespaceMonitoringReceipientsL1', 'orainfTremorTablespaceMonitoringReceipientsL2']");

my $FilesystemMonitoring= TremorMonitoring->new();
$FilesystemMonitoring->name("FilesystemMonitoring");
$FilesystemMonitoring->desc("free_space_filesystems");
$FilesystemMonitoring->filter("(orainfTremorFilesystemMonitoring=TRUE)");
$FilesystemMonitoring->attributes("['orclSystemName', 'orainfOsLogwatchUser']"); # He somehow does not care and returns everything

my $TnspingMonitoring= TremorMonitoring->new();
$TnspingMonitoring->name("TnspingMonitoring");
$TnspingMonitoring->desc("tnsping could not reach");
$TnspingMonitoring->filter("(orainfDbTnspingMonitoring=TRUE)");
$TnspingMonitoring->attributes("['cn']"); # He somehow does not care and returns everything

my $PortMonitoring= TremorMonitoring->new();
$PortMonitoring->name("PortMonitoring");
$PortMonitoring->desc("port could not be reached");
$PortMonitoring->filter("(orainfPortMonitoring=TRUE)");

my $RmanCorruption= TremorMonitoring->new();
$RmanCorruption ->name("RmanCorruption");
$RmanCorruption ->desc("RMAN has discovered corruptions");
$RmanCorruption ->filter("(orainfDbCheckRmanCorruption=TRUE)");
$RmanCorruption ->password("$v_password");

my $JobsPackagesMonitoring= TremorMonitoring->new();
$JobsPackagesMonitoring ->name("JobsPackagesMonitoring");
$JobsPackagesMonitoring ->desc("Broken jobs or invalid packages found");
$JobsPackagesMonitoring ->filter("(orainfDbCheckJobsPackages=TRUE)");
$JobsPackagesMonitoring ->password("$v_password");
#my $str = "Ala ma kota.\n";
#print "The answer is $str";

#exit 0;

#my @monitors_list = ($TablespaceMonitoring ,$FilesystemMonitoring ,$TnspingMonitoring ,$PortMonitoring ,$RmanCorruption ,$JobsPackagesMonitoring);

#my @monitors_list = ($TablespaceMonitoring);
#my @monitors_list = ($FilesystemMonitoring);
#my @monitors_list = ($TnspingMonitoring);
#my @monitors_list = ($PortMonitoring);
#my @monitors_list = ($RmanCorruption);
my @monitors_list = ($JobsPackagesMonitoring);

# Prepare the LDAP connection
my $ldap = Net::LDAP->new("logwatch");
$ldap = Net::LDAP->new("logwatch", timeout=>30);
my $ldap_mesg = $ldap->bind;


#print "$TablespaceMonitoring->{desc}\n";
my $tmp; # for temp string manipulation
my @entries; # array that stores answers from ldap server
my $entry; # single row returne from ldap
my @my_attributes_array; # attributes plit to allow for returning values of apecifuc atribute 
my $attr_user; # single atribute

# Pobierz temat z listy tematów
foreach my $monitor (@monitors_list) {
  # Pobierz dane dotyczace konkretnego tematu z LDAP
  $logger->info("- Section: " . $monitor->name . "\n");
  $logger->info("-- Filter: " . $monitor->filter. "\n");
  $logger->info("-- Looking for attributes: " . $monitor->attributes . "\n");
  $ldap_mesg = $ldap->search(filter=>$monitor->filter, base=>"dc=orainf,dc=com", attrs=>$monitor->attributes);
  @entries = $ldap_mesg->entries;

  foreach $entry (@entries) {
    # Przypisz znalezione wartosci dla atrybutow do objektu
    $logger->info("---- " . $monitor->name . "\n");
    $monitor->attributes_values($entry);

    # Wykonaj dzialanie zwiazane z tematem
    $monitor->action("ala ma kota");
  }
 
} # foreach $monitor
$ldap->unbind;

# Wyslij maile jezeli takie istnieja.
# Zakladam, ze sa one przechowywane w
# - /tmp/email
# - /tmp/email_sms

send_mails_from_dir('/tmp/email');
send_mails_from_dir('/tmp/email_sms');

# I do not know why I get
# Too many arguments for TremorMonitoring::send_mails_from_dir at ./tremon.pl line 394, near "'/tmp/email')"
# Execution of ./tremon.pl aborted due to compilation errors.
# If I try to move this block
sub send_mails_from_dir ( ) {
  my $dirname =$_[0];
  # Skip if the directory does not exists
  if (!-e $dirname && !-d $dirname) { 
    print "The $dirname does not exists, skiping send_mails_from_dir\n";
    return;
  }

  #print "Sending mail from", $dirname, "\n";
  opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
  while (defined(my $file = readdir(DIR)))  {
  if ( (-e "$dirname/$file") && (-r "$dirname/$file") && (-T "$dirname/$file") ) {
    #print "$dirname/$file\n";
    # The name of the file is the email address
    open(MAIL,"|mail $file");
    print MAIL <<"END" ;
Tremor Monitoring Presents:

END
    # The contents of the file is the message body
    open(IN,"$dirname/$file");
    while(my $line = <IN>) {
      print MAIL $line, "\n";
    }
    close (IN) or warn $! ? "Blad: $!" : "Blad ze statusem $?";
    close (MAIL) or warn $! ? "Blad: $!" : "Blad ze statusem $?";
    # After sending the mail delete the file
    mkdir("/tmp/already_send", 0755);
    my $timenow = time;
    rename "$dirname/$file","/tmp/already_send/$file.$timenow";
  } # if
  } # while
  closedir(DIR);
} # sub send_mails_from_dir



