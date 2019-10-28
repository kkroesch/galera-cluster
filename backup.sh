# See https://mariadb.com/kb/en/library/incremental-backup-and-restore-with-mariabackup/

# Create backup user
mysql <<-EOF
    CREATE USER 'mariabackup'@'localhost' IDENTIFIED BY 'mypassword';
    GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'mariabackup'@'localhost';
EOF

# Initial full backup
mariabackup --backup --target-dir=/var/backups/mysql/full --user=mariabackup --password=mypassword

# Incremental backup
export ARCHIVE=$(date +'%A')
mariabackup --backup --target-dir=/var/backups/mysql/${ARCHIVE} --incremental-basedir=/var/backups/mysql/full  --user=mariabackup --password=mypassword

# Restore backup
mariabackup --prepare --target-dir=/var/backups/mysql/full
mariabackup --prepare --target-dir=/var/backups/mysql --incremental-dir=/var/backups/mysql/${ARCHIVE}
systemctl stop mysql
rm -rf /var/lib/mysql/*
mariabackup --copy-back --target-dir=/var/backups/mysql/full
chown -R mysql:mysql /var/lib/mysql/
# First Node
galera_new_cluster

# Other nodes
systemctl restart mysql

# Test backup
mysql playground <<-EOL
    SELECT * FROM equipment
EOL
