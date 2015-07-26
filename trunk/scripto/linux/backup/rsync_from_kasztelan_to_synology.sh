#!/bin/bash
rsync -a --no-group --no-perms --omit-dir-times --progress --delete /KASZTELAN/zdjecia /SYNOLOGY_NFS/KASZTELAN_rsync > /tmp/rsync_from_kasztelan_to_synology.log
rsync -a --no-group --no-perms --omit-dir-times --progress --delete /KASZTELAN/mirror /SYNOLOGY_NFS/KASZTELAN_rsync >> /tmp/rsync_from_kasztelan_to_synology.log
cat /tmp/rsync_from_kasztelan_to_synology.log | mail -s "Rsync-log `date -I`" remigiusz.boguszewicz@gmail.com
