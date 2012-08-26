######################################################################################
# 
# An Oracle instance runs two types of processes - Server and Background. 
#
# Server processes  : are created to handle requests from sessions connected 
#                     to the instance
#
# Background processes : as the name says, are processes running behind the scene 
#                        and are meant to perform certain maintenance activities 
#                        or to deal with abnormal conditions arising in the lifetime 
#                        of the instance. 
# 
# Not all background processes are mandatory for an instance. 
# Each background process is meant for a specific purpose and its role is well defined. 
# Background processes are visible as separate operating system processes in Unix/Linux. 
# In Windows, these run as separate threads within the same process.
# 
# Background processes are invoked automatically when the instance is started. 
# 
# 
# Usage      : show_ora_shm.sh
# Parametres : None
# Platform   : Solaris 
# 
######################################################################################

GLB_TmpDir=/users/oracle/tmp

showSystemInfo()
{
    cat<<QQQ
################
#### SYSTEM ####
################
#### zone info ( list )
`zoneadm list -cv 2>/dev/null`
#### current zone ( name )
`zonename 2>/dev/null`
#### user info ( id group project )
`id -p`
#### System info
`prtdiag 2>/dev/null`
`prtconf 2>/dev/null`
################
#### ORACLE ####
################
QQQ
}

Main()
{
  tmpFile=${GLB_TmpDir}/oipcs.tmp.$$

  showSystemInfo

  cat<<EndOfCat>>$tmpFile
{
EndOfCat

  ###############################################################################
  # Background processes list
  BgrdPrc="`ps -ef|grep -v grep|grep ora_.*|awk '{print $2}'`"
  # Shadow processes list
  #ShadPrc="`ps -ef|grep -v grep|grep oracle[a-ZA-Z].*|awk '{print $2}'`"
  ###############################################################################

  # ipcs -m sample output
  #
  # m   25920563   0xcf96d571 --rw-r-----   oracle      dba
  # m    2135604   0x3d60ae0  --rw-r-----   oracle      dba

  ipcs -m | while read p1 p2 p3 p4 p5 p6
  do
    if [ "$p5" = "oracle" ]
    then
        cat<<EndOfCat>>$tmpFile
tab["$p2"]="<orphaned>";
EndOfCat
    fi
  done

  ###########################################################
  # Background processes anon, heap, stack memory segments
  ###########################################################

  ##############################################################
  # shared memory ( detects the shmid token if the pmap output )
  ##############################################################

  for i in $BgrdPrc
  do
      #pmap -F $i | head -1

      # output 
      #	10511:  oracleBDDEV (LOCAL=NO)
      #	6237:   oracleDIVTEST3 (LOCAL=NO)
      #	27268:  oracleDIVTEST2 (LOCAL=NO)

      pmap $i | grep shmid | \
          sed 's/\(.*shmid=0x\)\([0-9a-h]*\)\(.*\)/\2/' | \
          while read id
          do
              shmidHex=`echo $id | tr "[a-h]" "[A-H]"`
              shmidDec=`echo "ibase=16;$shmidHex" | bc`
              sid=`pmap -F $i | head -1 | sed 's/\(.*ora_[a-z][a-z0-9][a-z0-9][a-z0-9]_\)\([^ ]*\)\(.*\)/\2/'`
              cat<<EndOfCat>>$tmpFile
tab["$shmidDec"]="$sid";
EndOfCat
          done
  done 

  cat<<EndOfCat>>$tmpFile
if ( \$1 == "m" )
    {
        if ( \$5 == "oracle" && \$6 == "dba" )
        {
            if ( tab[\$2] == "" ) 
            {
                tab[\$2] = "<zombie>"
            }
            printf("%- 10.10s % 10d % 10d M\n", tab[\$2], \$2, \$10/(1024*1024));

            total += \$10/(1024*1024);
        }
    }
    else
    {
    }

}
END {
    printf("total shared memory allocated to Oracle : % d M\n", total );
}
EndOfCat

    #echo $tmpFile created

    ipcs -am | nawk -f $tmpFile

    #rm -f $tmpFile
}

Main
