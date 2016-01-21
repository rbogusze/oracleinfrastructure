tail -f /tmp/global_listener_raw.log | grep -v service_update | ./parser.sh | logstalgia --no-bounce --hide-paddle --sync -
