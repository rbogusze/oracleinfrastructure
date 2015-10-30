#!/bin/bash
#$Id: _base_script_block.sh,v 1.1 2012-05-07 13:47:27 remik Exp $

(. ./report_wiki.wrap 2>&1) | tee /var/www/html/dokuwiki/data/pages/lt_checks.txt
