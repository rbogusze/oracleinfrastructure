tail -f /tmp/global_listener_raw.log | grep -v service_update | ./get_parser.sh | logstalgia -
