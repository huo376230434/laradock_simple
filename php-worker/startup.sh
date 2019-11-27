#!/bin/bash



php -r '$path="/var/www";var_dump($path); $handler = opendir($path); $arr = [];$crontab_path = "/etc/crontabs/root";\
            while( ($filename = readdir($handler)) !== false ) {\
                if($filename != "." && $filename != ".." && is_dir($path . "/" . $filename) && file_exists($path . "/" . $filename."/artisan")){\
                    $command_str = "* * * * *  php /var/www/$filename/artisan schedule:run >> /dev/null 2>&1".PHP_EOL;\
                    if (!strstr(file_get_contents($crontab_path), $command_str)) file_put_contents($crontab_path, $command_str, FILE_APPEND);\
                } }'

crond -l 2 -b

 /usr/bin/supervisord -n -c /etc/supervisord.conf


