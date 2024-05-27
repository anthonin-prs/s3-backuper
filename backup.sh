#!/bin/bash


conf_file=$@

PATH=$PATH:/usr/local/bin/

jq -r -c .backups[] $conf_file | while read backup_task
do
    name=$(echo $backup_task | jq -r -c .name)
    source_folder=$(echo $backup_task | jq -r -c .source_folder)
    dest_bucket=$(echo $backup_task | jq -r -c .dest_bucket)
    retention_days=$(echo $backup_task | jq -r -c .retention_days)
    exclusions=$(echo $backup_task | jq  -c .excluded[])
    folder_name=$(echo $source_folder | rev  | cut -d '/' -f 1 | rev)
    archive_name="$folder_name-$(date +%Y_%m_%d).tar.gz"
    log_file_name="$folder_name-$(date +%Y_%m_%d).log"


    echo "Running '$name' cleanup: deleting backup older than $retention_days days from s3://$dest_bucket " | tee $log_file_name
    for s3_file in $(aws s3 ls $dest_bucket | awk '{ print $4 }')
    do
        file_date_string=$(echo $s3_file | cut -d '.' -f 1 | rev | cut -c -10 | rev | sed "s/_/-/g")
        file_date=$(date -d "$file_date_string" +%s)
        retention_limit=$(date -d "$retention_days days ago" +%s)


        if [[ $retention_limit -ge $file_date ]]; then
            echo "  - Deleting s3://$dest_bucket/$s3_file" | tee -a $log_file_name
            aws s3 rm s3://$dest_bucket/$s3_file --quiet
        fi

    done

    echo "Running '$name' backup: $source_folder => s3://$dest_bucket" | tee -a $log_file_name

    echo "  - Compressing $source_folder to $archive_name" | tee -a $log_file_name
    exclusion_args=""
    for exclusion in $exclusions
    do
        exclusion_args=$exclusion_args" --exclude=$exclusion"
    done
    command="sudo tar"$exclusion_args" -c --use-compress-program=pigz -f $archive_name $source_folder"
    command="sudo tar"$exclusion_args" -czf $archive_name $source_folder"
    eval $command
    echo "  - Uploading $archive_name to s3://$dest_bucket" | tee -a $log_file_name
    aws s3 cp $archive_name s3://$dest_bucket
    aws s3 cp $log_file_name s3://$dest_bucket

    rm -rf "$archive_name"
    rm -rf "$log_file_name"

done
