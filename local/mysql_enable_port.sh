# this runs in active session for a site and outputs the site's port
mysql -e "CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY 'root'; GRANT ALL ON *.* TO 'root'@'127.0.0.1';"
mysql -e "SHOW VARIABLES WHERE Variable_name = 'port';"
