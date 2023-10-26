# Docker setup for Oxid 6.5

This Docker setup installs a Oxid 6.5 shop with demodata.  
It is meant to be used just like a real linux webserver.  
So you have to connect to it via ssh and sftp.  
It has no Docker volumes to not slow it down with file management and symlink stuff when used in Windows.
This also means that when the containers are deleted the files in it are gone so beware.  
I use it with PHPStorm in a remote host with SFTP access configuration.

## Important URLs
Shop: https://localhost  
Admin: https://localhost/admin (Login:  admin // admin)  
phpmyadmin: http://localhost:8080/ (Login: docker // docker)  
SSH/SFTP: root@localhost Port: 2222 (Login: docker)

## Docker setup

### create container
docker-compose build
### fire up container
docker-compose up -d  
  
To create multiple setups, name your setup manually:    
docker-compose -pMYPROJECT up -d
