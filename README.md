# percona-mysql-backup-with-encryption

The following scripts will take percona full backup and incremental with encryption

create key with the following command

<code>
openssl enc -aes-256-cbc -pass pass:Password -P -md sha1 | grep iv | cut -d'=' -f2
</code>

