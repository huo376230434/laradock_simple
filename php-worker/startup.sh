#!/bin/bash




php /opt/init.php

crond -l 2 -b

 /usr/bin/supervisord -n -c /etc/supervisord.conf


