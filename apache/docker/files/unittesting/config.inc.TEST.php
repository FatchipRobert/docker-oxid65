<?php
error_reporting(E_ALL & ~E_STRICT & ~E_DEPRECATED & ~E_WARNING & ~E_NOTICE);
$this->dbName = 'dockertest'; // database name
$this->dbUser = 'root'; // database user name
$this->dbPwd  = 'dockerroot'; // database user password
$this->iUtfMode = 0;
$this->iDebug = 1;
#$this->blSkipViewUsage = true;

ini_set('error_log', '/var/www/html/source/log/php_unit.log');