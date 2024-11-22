cp -a /var/www/html/vendor/payone-gmbh/oxid-6/* /var/www/html/source/modules/fc/fcpayone/
php /var/www/html/vendor/bin/oe-console oe:module:install-configuration /var/www/html/source/modules/fc/fcpayone/
php /var/www/html/vendor/bin/oe-console oe:cache:clear