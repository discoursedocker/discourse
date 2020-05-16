#!/bin/bash
env > ~/boot_env
conf=${DISCOURSE_WWW_PATH}/config/discourse.conf
# find DISCOURSE_ env vars, strip the leader, lowercase the key
/usr/local/bin/ruby -e 'ENV.each{|k,v| puts "#{$1.downcase} = '\''#{v}'\''" if k =~ /^DISCOURSE_(.*)/}' > $conf