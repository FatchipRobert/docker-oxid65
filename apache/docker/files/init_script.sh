#!/usr/bin/env bash
set -e

echo "Restart ssh server"
/etc/init.d/ssh restart

CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"
if [ ! -e /$CONTAINER_FIRST_STARTUP ];
then
    touch /$CONTAINER_FIRST_STARTUP

    sudo -u www-data composer create-project oxid-esales/oxideshop-project /var/www/html/ dev-b-6.5-ce

    chmod -R 777 /var/www/html
    
    echo "Copy config.inc.php file"
    sudo -uwww-data cp -f /oxid/config.inc.php /var/www/html/source/config.inc.php

    while ! mysqladmin ping -h"mysql.$DOMAIN" --silent; do
        sleep 1
        echo "Waiting for MYSQL server"
    done

    echo "MYSQL SERVER IS UP!"

    echo "Install demodata"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --host=mysql.$DOMAIN $MYSQL_DATABASE < /var/www/html/source/Setup/Sql/database_schema.sql
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --host=mysql.$DOMAIN $MYSQL_DATABASE < /var/www/html/source/Setup/Sql/initial_data.sql
    sudo -uwww-data php /var/www/html/vendor/bin/oe-eshop-db_views_generate
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -f --host=mysql.$DOMAIN $MYSQL_DATABASE < /var/www/html/vendor/oxid-esales/oxideshop-demodata-ce/src/demodata.sql
    sudo -uwww-data cp -R /var/www/html/vendor/oxid-esales/oxideshop-demodata-ce/src/out/pictures/ /var/www/html/source/out/pictures/

    echo "Get module from Git"
    sudo -uwww-data rm -rf /var/www/html/vendor/payone-gmbh/*
    sudo -uwww-data rm -rf /var/www/html/source/fc/fcpayone/*
    cd /var/www/html/vendor/payone-gmbh/
    sudo -uwww-data git clone -b OX6-164-PayPalV2 https://github.com/FatchipRobert/oxid-6.git

    echo "Copy Unittest config"
    sudo -uwww-data cp /unittesting/config.inc.TEST.php /var/www/html/source/config.inc.TEST.php    
    sudo -uwww-data cat /unittesting/config.inc.php_addToEnd >> /var/www/html/source/config.inc.php
    sudo -uwww-data cp /unittesting/test_config.yml /var/www/html/test_config.yml

    sudo -uwww-data cp /unittesting/base.php /var/www/html/vendor/oxid-esales/testing-library/base.php
    sudo -uwww-data cp /unittesting/bootstrap.php /var/www/html/vendor/oxid-esales/testing-library/bootstrap.php

    sudo -uwww-data cp /unittesting/updatemodule.sh /var/www/html/updatemodule.sh
    sudo -uwww-data cp /unittesting/starttests.sh /var/www/html/starttests.sh
    sudo -uwww-data cp /unittesting/startcoverage.sh /var/www/html/startcoverage.sh

    sudo -uwww-data sh /var/www/html/updatemodule.sh

    sudo -uwww-data /var/www/html/vendor/bin/oe-console oe:module:activate fcpayone

    echo "CREATE DATABASE $MYSQL_DATABASE_TEST;" | mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD --host=mysql.$DOMAIN
    mysqldump -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD --host=mysql.$DOMAIN $MYSQL_DATABASE | mysql -u$MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD --host=mysql.$DOMAIN $MYSQL_DATABASE_TEST

    sudo -uwww-data php /var/www/html/vendor/bin/runtests /var/www/html/source/modules/fc/fcpayone/tests/unit/ || true
fi

echo "#####################################"
echo "###### Docker setup completed! ######"
echo "#####################################"

exec "$@"