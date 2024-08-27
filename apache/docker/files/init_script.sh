#!/usr/bin/env bash
set -e

CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"
if [ ! -e /$CONTAINER_FIRST_STARTUP ];
then
    touch /$CONTAINER_FIRST_STARTUP

    sudo -u www-data composer create-project --no-dev oxid-esales/oxideshop-project . dev-b-6.5-ce

    chmod -R 777 /var/www/html

    while ! mysqladmin ping -h"mysql.$DOMAIN" --silent; do
        sleep 1
        echo "Waiting for MYSQL server"
    done

    echo "MYSQL SERVER IS UP!"

    echo "Copy config.inc.php file"
    cp -f /oxid/config.inc.php source/config.inc.php

    echo "Install demodata"
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --host=mysql.$DOMAIN $MYSQL_DATABASE < /var/www/html/source/Setup/Sql/database_schema.sql
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD --host=mysql.$DOMAIN $MYSQL_DATABASE < /var/www/html/source/Setup/Sql/initial_data.sql
    php /var/www/html/vendor/bin/oe-eshop-db_views_generate
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -f --host=mysql.$DOMAIN $MYSQL_DATABASE < /var/www/html/vendor/oxid-esales/oxideshop-demodata-ce/src/demodata.sql
    cp -R /var/www/html/vendor/oxid-esales/oxideshop-demodata-ce/src/out/pictures/ /var/www/html/source/out/pictures/
fi

echo "#####################################"
echo "###### Docker setup completed! ######"
echo "#####################################"

exec "$@"