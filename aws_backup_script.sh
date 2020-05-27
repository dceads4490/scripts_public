#!/bin/bash
# This is a simple script for backing up directories to a local copy and an AWS bucket
# First create local BACKUP_DEPOT and a S3 bucket to backup data to
# Directory names can have spaces and will work with this script
# You will need to run "aws configure" from the CLI before the aws s3 sync will work
# This uses rsync to copy only updated files to a local repository that will be synced to aws.
#  - After the first run, only changes are copied. 
#
# I use a cron entry as follows to pipe the output to a log file that I can check occassionally.
04  01  * * * /home/my_user/projects/scripts/aws_backup_script.sh >> /home/my_user/my_user-backup.log 2>&1

# Create array with directories to be backed up.
# Add directory names with complete path in double quotes
declare -a dir_list=("Directory 1" "Directory 2" "Directory 3")

# Define BACKUP_DEPOT and AWS_BUCKET
BACKUP_DEPOT="Some depot directory to store backup repository"
AWS_BUCKET="Your aws-bucket for backup"

# Loop through dir_list and rsync each directory
for ldir in "${dir_list[@]}"
do
   echo "Going to backup up '${ldir}'"
   rsync -av "${ldir}" "${BACKUP_DEPOT}"
   # log the failure but continue
   if [[ $? -ne 0 ]] 
      then
      	echo "rsync of '${ldir}' failed!"
   fi
done

# sync changes to AWS
echo "Going to start aws s3 sync"
# You have to run "aws configure" before this command will work
aws s3 sync "${BACKUP_DEPOT}" s3://${AWS_BUCKET}/
