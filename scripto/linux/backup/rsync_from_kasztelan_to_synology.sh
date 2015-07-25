#!/bin/bash
rsync -a --no-group --no-perms --omit-dir-times --progress /KASZTELAN/zdjecia /SYNOLOGY_NFS/KASZTELAN_rsync
