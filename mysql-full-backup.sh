#!/bin/bash

source /etc/mysql-backup.conf

TODAY_DATE=`date +'%Y-%m-%d'`

FULL_BASE_DIR=$BASE_DIR/$TODAY_DATE/full
mkdir -p $FULL_BASE_DIR

LSN_BASE_DIR=$BASE_DIR/$TODAY_DATE/lsn
mkdir -p $LSN_BASE_DIR

LSN_BASE_DIR_FULL=$LSN_BASE_DIR/full
mkdir -p  $LSN_BASE_DIR_FULL



cd $FULL_BASE_DIR

echo "innobackupex --no-timestamp --encrypt=$ENC_ALG --encrypt-key=$ENC_KEY   \
        --user=$MYSQL_USER --password=$MYSQL_PWD \
        --extra-lsndir=$BACKUP_BASE_DIR/$TODAY_DATE/lsn/full \
        $BACKUP_BASE_DIR/$TODAY_DATE/full"

OUT=$(  innobackupex --no-timestamp --encrypt=$ENC_ALG --encrypt-key=$ENC_KEY --user=$MYSQL_USER --password=$MYSQL_PWD --extra-lsndir=$LSN_BASE_DIR_FULL $FULL_BASE_DIR 2>>  $BASE_DIR/$TODAY_DATE-log)

if [ "$?" == "1" ]; then
        echo 'Backup Failed'
        echo '=============='
        cat $BACKUP_BASE_DIR/$TODAY_DATE-log

else
        echo "Bckup Completed"
        echo "$TODAY_DATE" > $BASE_DIR/last_full_backup.log
        rm -f $BASE_DIR/last_inc_backup.log
        touch $BASE_DIR/last_inc_backup.log

fi
