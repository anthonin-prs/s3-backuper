# S3 Backuper
Simple file backup to S3

#### Setup
- Create your favorite S3 bucket
- Rename `setup/config_template.json` to `setup/config.json`
- Report any informations into `setup/config.json`
- Run `setup.sh`


#### Usage
- Create a config file like [config.json](config.json)
    - One item = 1 backed up folder
    ```
    name:             Name of your backup
    source_folder:    Local folder you want to backup
    dest_bucket:      Bucket your backup should be uploaded to
    retention_days:   Duration (in days) after which your backup could be deleted in cleanup step
    ```
- Run `backup.sh config.json`

Enjoy !
