#!/bin/bash
INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`

cat << EOF
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/messages]
datetime_format = %b %d %H:%M:%S
file = /var/log/messages
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/messages

[/var/log/mysqld.log]
datetime_format = %Y-%m-%d %H:%M:%S
file = /var/log/mysqld.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/mysqld.log

[/var/log/php-fpm/www-error.log]
datetime_format = %d/%b/%Y:%H:%M:%S %z
file = /var/log/php-fpm/www-error.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/php-fpm/www-error.log

EOF

for logfile in $(find /var/log/nginx/ -name '*.access.log'); do
  logfile_name=${logfile##*/}
  logfile_name_without_ext=${logfile_name%.*}
  logfile_name_without_ext=${logfile_name_without_ext%.*}
  if [[ "$logfile" =~ "backend" ]]; then
    logfile_name_without_ext=${logfile_name_without_ext%.*}
    logstream_name="-${logfile_name_without_ext}"
    if [ "$logstream_name" = "-$INSTANCE_ID" ]; then
      logstream_name=""
    fi
    #echo "backend.access.log: ${logfile}"
    cat << EOF
[$logfile]
datetime_format = %d/%b/%Y:%H:%M:%S %z
file = $logfile
buffer_duration = 5000
log_stream_name = {instance_id}$logstream_name
initial_position = start_of_file
log_group_name = /var/log/nginx/backend.access.log

EOF
  else
    if [[ "$logfile" =~ "access" ]]; then
      #echo "access.log: ${logfile}"
      logstream_name="-${logfile_name_without_ext}"
      if [ "$logstream_name" = "-$INSTANCE_ID" ]; then
        logstream_name=""
      fi
      if [ "$logfile_name" != "access.log" ]; then
         cat << EOF
[$logfile]
datetime_format = %d/%b/%Y:%H:%M:%S %z
file = $logfile
buffer_duration = 5000
log_stream_name = {instance_id}$logstream_name
initial_position = start_of_file
log_group_name = /var/log/nginx/access.log

EOF
      fi
    fi
  fi
done

for logfile in $(find /var/log/nginx/ -name '*.error.log'); do
  logfile_name=${logfile##*/}
  logfile_name_without_ext=${logfile_name%.*}
  logfile_name_without_ext=${logfile_name_without_ext%.*}
  if [ "$logfile_name" != "error.log" ]; then
    logstream_name="-${logfile_name_without_ext}"
    if [ "$logstream_name" = "-$INSTANCE_ID" ]; then
      logstream_name=""
    fi
    cat << EOF
[$logfile]
datetime_format = %d/%b/%Y:%H:%M:%S %z
file = $logfile
buffer_duration = 5000
log_stream_name = {instance_id}$logstream_name
initial_position = start_of_file
log_group_name = /var/log/nginx/error.log

EOF
  fi
done

