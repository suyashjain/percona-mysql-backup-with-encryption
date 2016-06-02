#!/bin/bash

source /etc/mysql-backup.conf

TODAY_DATE=`date +'%Y-%m-%d-%H-%M-%S'`

LAST_FULL_BKP_DATE=`cat $BASE_DIR/last_full_backup.log`

BKP_BASE=$BASE_DIR/$LAST_FULL_BKP_DATE

INC_DIR=$BKP_BASE/inc/$TODAY_DATE

mkdir -p $INC_DIR

EXTRA_LSN_DIR=$BKP_BASE/lsn/inc/$TODAY_DATE

mkdir -p $EXTRA_LSN_DIR

LAST_LSN=''


LAST_FULL_LSN=$(cat $BKP_BASE/lsn/full/xtrabackup_checkpoints | grep to_lsn | cut -d'=' -f2)

LAST_INC_BKP=`cat $BASE_DIR/last_inc_backup.log`

LOG_FILE=$BKP_BASE/inc/$TODAY_DATE.log


LAST_LSN=$LAST_FULL_LSN

echo "Last Full Backup LSN:$LAST_LSN"

if  [ ! -z "$LAST_INC_BKP" ]; then

        echo "Checking For last inc lsn file  $BKP_BASE/lsn/inc/$LAST_INC_BKP/xtrabackup_checkpoints"
        echo "There was an previous incrementl backup on $LAST_INC_BKP"

        LAST_LSN=$(cat $BKP_BASE/lsn/inc/$LAST_INC_BKP/xtrabackup_checkpoints | grep to_lsn | cut -d'=' -f2)
else
        echo "This is the First Incremental Backup For $LAST_FULL_BKP_DATE"
fi

echo "Last LSN:$LAST_LSN"

PARAMS='--no-timestamp'
PARAMS=${PARAMS}" --user=$MYSQL_USER"
PARAMS=${PARAMS}" --password=$MYSQL_PWD"
PARAMS=${PARAMS}" --incremental"
PARAMS=${PARAMS}" --encrypt=${ENC_ALG}"
PARAMS=${PARAMS}" --encrypt-key=${ENC_KEY}"
PARAMS=${PARAMS}" --incremental-lsn ${LAST_LSN}"
PARAMS=${PARAMS}" --extra-lsndir=$EXTRA_LSN_DIR"
PARAMS=${PARAMS}" ${INC_DIR}"

echo "innobackupex $PARAMS  2>> $LOG_FILE"
OUT=$(innobackupex $PARAMS  2>> $LOG_FILE)

if [ "$?" == "1" ]; then

        echo 'Backup Failed'

else

        echo $TODAY_DATE > $BASE_DIR/last_inc_backup.log
        echo 'Incremental Backup Completed'
fi
