sudo apt install postgresql postgresql-contrib postgresql-client -y
sudo apt install mysql-server -y
#mysql -uroot -h127.0.0.1 -p -P3306
#create database db_cs;
#mysql -uroot -h127.0.0.1 -p -P3306 db_cs

sudo -u postgres psql
ALTER USER postgres PASSWORD '1';
#psql "postgresql://postgres:1@127.0.0.1:5432"
#create database db_cs;
#psql "postgresql://postgres:1@127.0.0.1:5432/db_cs"