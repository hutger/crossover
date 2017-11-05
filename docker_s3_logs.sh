#!/bin/bash

# description: Rotate DOCKER logs and transfer backup files to AWS S3
# The script can be executed using crontab, eg.:
#  * */1 * * *   docker_s3_logs.sh


# Credentials for AWS s3 access
# Add informations below or use AWS credential files
#export AWS_ACCESS_KEY_ID=""
#export AWS_SECRET_ACCESS_KEY=""

# S3 Bucket
S3_BUCKET="docker-s3-logs"

# Define "since" parameter (in days)
LOGS_SINCE="7"

# --------------------------------------

for CONTAINER_NAME in `docker ps -a --format status=running --format '{{.Names}}'`
do
	NOW=`date +%Y-%m-%d_%H-%M-%S`

	# Defining backup filename
	BACKUP_FILE="Backup_"$CONTAINER_NAME"_logs-$NOW"

	# Generating backup files
	docker logs --since `expr $LOGS_SINCE \* 24` $i > $BACKUP_FILE 2>&1

	# GZIP backup file
	gzip $BACKUP_FILE

	# Upload backup file to s3 bucket
	aws s3 cp $BACKUP_FILE.gz s3://$S3_BUCKET

	# Confirm if the backup file was uploaded to the bucket
	aws s3 ls s3://$S3_BUCKET | grep $BACKUP_FILE.gz > /dev/null 2>&1
	if [ $? -eq 0 ]; then echo "OK"; else echo "NOK"; fi

	# Deleting the local backup file
	rm -f $BACKUP_FILE.gz
done
