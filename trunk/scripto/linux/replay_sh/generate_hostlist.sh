#!/bin/bash
# $Header: /home/remik/osobiste/cvs_repo/scripto/oracle/replay_sh/generate_hostlist.sh,v 1.1 2012-05-07 13:32:52 remik Exp $

# Set the variable V_COND that determines the filter, then run ask_ldap command below.

$HOME/scripto/perl/ask_ldap.pl "$V_COND" "['remikDbOracleUser', 'orclSystemName', 'cn', 'orclOracleHome', 'orclSid']" | awk '{ print $1"#"$2"#"$3"#"$4"#"$5 }' | sort 

# Podaj hosty dla baz bedace w replikacji HAL
export V_COND='(pgfDbInReplication=TRUE)'

# Podaj hosty dla baz bedace w replikacji HAL + produkcyjne
export V_COND='(&(pgfDbInReplication=TRUE)(remikDbType=PRODUCTION))'

# Podaj hosty dla baz nie bedace w replikacji HAL
export V_COND='(&(remikDbCustomer=HAL)(remikDbType=RETIREMENT)(!(pgfDbInReplication=TRUE)))'

# Podaj hosty dla baz HALa wszystkie
export V_COND='(&(remikDbCustomer=HAL)(|(remikDbType=RETIREMENT)(remikDbType=PRODUCTION)))'

# Podaj hosty dla baz uzywajace replikowanego tnsnames z CVS
export V_COND='pgfTnsnamesCvs=TRUE'

# Podaj hosty dla baz z konkretnej master zony
export V_COND='(&(remikDbOracleRdbms=TRUE)(pgfMasterZoneName=bielik))'

# RETIREMENT
export V_COND='(&(remikDbOracleRdbms=TRUE)(remikDbType=RETIREMENT))'

# STANDBY
export V_COND='(&(remikDbOracleRdbms=TRUE)(remikDbType=STANDBY))'

# *************************************************************************
# Infrastructure changes - according to /HalInfrastructureDziennikPokladowy
# *************************************************************************
# 
# 1 day - all(DEVELOPMENT, TEST)
export V_COND='(&(remikDbOracleRdbms=TRUE)(|(remikDbType=DEVELOPMENT)(remikDbType=TEST)))'

# 1 week - all(RETIREMENT, STANDBY) 
export V_COND='(&(remikDbOracleRdbms=TRUE)(|(remikDbType=RETIREMENT)(remikDbType=STANDBY)))'

# 1 week - all(ASSIST) 
export V_COND='(&(remikDbOracleRdbms=TRUE)(remikDbType=ASSIST))'

# 1 week - all(PRODUCTION) 
export V_COND='(&(remikDbOracleRdbms=TRUE)(remikDbType=PRODUCTION))'

# all(ALL) - sum of all the above taken into consideration during infrastructure changes
export V_COND='(&(remikDbOracleRdbms=TRUE)(|(remikDbType=DEVELOPMENT)(remikDbType=TEST)(remikDbType=RETIREMENT)(remikDbType=STANDBY)(remikDbType=ASSIST)(remikDbType=PRODUCTION)))'

# all(resonable) - all resonable
export V_COND='(&(remikDbOracleRdbms=TRUE)(|(remikDbType=RETIREMENT)(remikDbType=STANDBY)(remikDbType=ASSIST)(remikDbType=PRODUCTION)))'
# *************************************************************************
