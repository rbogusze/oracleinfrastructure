#!/usr/local/bin/tclsh8.5
package require Oratcl
#EDITABLE OPTIONS##################################################
set connectstr "system/manager@oracle" 

# Sample interval in seconds
set interval 1

set sqc {select sum(value) from v$sysstat where name = 'user commits' or name = 'user rollbacks'}

if {[catch {set ldc [oralogon $connectstr] }]} {
  puts "Transaction Counter" "Connection Failed" 
}

if {[catch { set curc [ oraopen $ldc ]}]} {
  puts "Transaction Counter" "Transaction Count Cursor Open Failed" 
}

if {[catch {oraparse $curc $sqc}]} {
  puts "Transaction Counter" "Transaction Count Cursor Open Failed" 
}

set new 0
set old 0
set skip_first 1
set run_me 1
while { $run_me  } {
  oraexec $curc
  orafetch  $curc -datavariable output
  set new $output
  set diff [ expr ( $new - $old ) / $interval * 60 ]
  if {$skip_first == 0} {
    puts -nonewline [clock format [clock seconds] -format "\[%H:%M:%S\]"] 
    puts -nonewline " " 
    puts $diff
  } else {
    set skip_first 0
  }

  set old $new

  # Think time in ms
  after [ expr $interval * 1000 ]
}

oraclose $curc

