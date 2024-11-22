sh /var/www/html/updatemodule.sh
sudo -uwww-data cp /unittesting/base.php /var/www/html/vendor/oxid-esales/testing-library/base.php
sudo -uwww-data cp /unittesting/bootstrap.php /var/www/html/vendor/oxid-esales/testing-library/bootstrap.php
php vendor/bin/runtests /var/www/html/source/modules/fc/fcpayone/tests/unit/