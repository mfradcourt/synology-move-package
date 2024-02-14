# Synology-move-package
A bash script that moves packages from one Synology NAS volume to another.
Inspired by [@Saintdle's guide](https://veducate.co.uk/synology-moving-a-package-between-volumes/)

## Disclaimer
This script has been tested on the following version of DSM:
- DSM 7.2.1-69057 Update 3

## Usage
### Preparation
1. Log in to Synology NAS using SSH as admin.
2. Run `sudo -i` to change user to root
3. Clone this repository or `wget` the raw file to a safe location, usually root user home
4. Mark the `.sh` file as executable by `chmod +x migrate-7.sh`
5. Determine the source and destination volumes by navigating to `/` and `ll`. `cd / && ll`
6. Once you have located you source volume, you can check the directory name of a specific package

### Executing the Script

Check the packages and run the script by `~/migrate-7.sh -s <Source Volume> -d <Destination Volume> -p <Package Directory Name or ALL>`  

Example:
`~/migrate-7.sh -s volume1 -d volume2 -p ALL`

### Using the Script

| Option | Description                                                                                       |
|--------|---------------------------------------------------------------------------------------------------|
| `-s`   | Source (SOURCE_VOLUME) volume, should be in the form of `volumeX` e.g. `volume1`                  |
| `-d`   | Destination (DESTINATION_VOLUME) volume, should be in the form of `volumeX` e.g. `volume2`        |
| `-p`   | You can either specify the name of a specific package (ex: MariaDB10) or all packages using "ALL" |
| `-h`   | Show Help                                                                                         |

