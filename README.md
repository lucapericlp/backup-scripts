# backup-scripts

Trying to create redundancy for data stored in GDrive? Use AWS S3 with the
`DEEP_ARCHIVE` storage class using these scripts.

## Usage
### Pre-requisites
- `rclone` installed
- Google Drive with existing data

### rclone setup
Setup configurations for both a Google Drive & AWS S3 with DEEP_ARCHIVE storage class via the interactive script.
```bash
rclone config
```
For the examples, I'll set up GDrive under `gdrive` & the S3 config under `glacier`

### AWS setup
```bash
export AWS_ACCESS_KEY_ID={value-here}
export AWS_SECRET_ACCESS_KEY={value-here}
terraform init
terraform plan
terraform apply
```

### Sync
```bash
rclone sync gdrive:my-folder glacier:my-bucket-name
rclone sync gphotos:media/all glacier:my-bucket-name/gphotos
```
