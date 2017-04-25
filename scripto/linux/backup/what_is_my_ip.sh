#!/bin/bash
#dig +short myip.opendns.com @resolver1.opendns.com | mail -s "myip `date '+%d/%m/%Y_%H:%M:%S'`" remigiusz.boguszewicz@gmail.com
echo -n "`date '+%d/%m/%Y_%H:%M:%S'` " >> ~/osobiste/komputery/my_ip.txt
dig +short myip.opendns.com @resolver1.opendns.com >> ~/osobiste/komputery/my_ip.txt
