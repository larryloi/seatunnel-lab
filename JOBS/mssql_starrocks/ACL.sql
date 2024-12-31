--- Starrocks access control 

mysql -P 9030 -h 127.0.0.1 -u root --prompt="StarRocks > "



CREATE USER 'admin'@'%' IDENTIFIED WITH mysql_native_password BY 'Abcd1234' DEFAULT ROLE db_admin, user_admin;

CREATE ROLE APPS;

GRANT ALL ON *.* TO ROLE APPS ;

GRANT ALL PRIVILEGES ON DATABASE * TO ROLE APPS;

CREATE USER 'seatunnel_sink'@'%' IDENTIFIED WITH mysql_native_password BY 'Abcd1234' DEFAULT ROLE APPS;