#!/bin/bash
ssh -t orainf@logwatch tail -f /tmp/global_listener_raw.log > /tmp/global_listener_raw.log
