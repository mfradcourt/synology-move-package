#!/bin/bash
set -e

Help() {
    printf '\n%s\n\t%s' '-s' 'Source (SOURCE_VOLUME) volume, should be in the form of volumeX'
    printf '\n%s\n\t%s' '-d' 'Destination (DESTINATION_VOLUME) volume, should be in the form of volumeX'
    printf '\n%s\n\t%s' '-p' 'You can either specify the name of a specific package (ex: MariaDB10) or all package using "ALL"'

    exit 1
}

StartPackage() {
    local package_name=$1
    echo "Starting package $package_name"

    [ -e /var/packages/$package_name/scripts/start-stop-status ] && "/var/packages/$package_name/scripts/start-stop-status start" &
    sleep 5
}

StopPackage() {
    local package_name=$1
    echo "Stopping package $package_name"

    [ -e /var/packages/$package_name/scripts/start-stop-status ] && "/var/packages/$package_name/scripts/start-stop-status stop" &
    sleep 5
}

MoveAllPackages() {
    for f in /$SOURCE_VOLUME/\@appstore/*
    do
        package_name="${f##*/}"
        echo $package_name

        StopPackage $package_name
        MovePackage $package_name
        StartPackage $package_name
    done
    exit 1
}

MovePackage() {
    local package_name=$1
    echo "Moving package $package_name"

    [ -e /var/packages/$package_name/etc ] && rm -rf /var/packages/$package_name/etc
    [ -e /var/packages/$package_name/home ] && rm -rf /var/packages/$package_name/home
    [ -e /var/packages/$package_name/share ] && rm -rf /var/packages/$package_name/share
    [ -e /var/packages/$package_name/target ] && rm -rf /var/packages/$package_name/target
    [ -e /var/packages/$package_name/tmp ] && rm -rf /var/packages/$package_name/tmp
    [ -e /var/packages/$package_name/var ] && rm -rf /var/packages/$package_name/var

    [ -e /$SOURCE_VOLUME/\@appconf/$package_name ] && mv /$SOURCE_VOLUME/\@appconf/$package_name /$DESTINATION_VOLUME/\@appconf
    [ -e /$SOURCE_VOLUME/\@apphome/$package_name ] && mv /$SOURCE_VOLUME/\@apphome/$package_name /$DESTINATION_VOLUME/\@apphome
    [ -e /$SOURCE_VOLUME/\@appshare/$package_name ] && mv /$SOURCE_VOLUME/\@appshare/$package_name /$DESTINATION_VOLUME/\@appshare
    [ -e /$SOURCE_VOLUME/\@appstore/$package_name ] && mv /$SOURCE_VOLUME/\@appstore/$package_name /$DESTINATION_VOLUME/\@appstore
    [ -e /$SOURCE_VOLUME/\@apptemp/$package_name ] && mv /$SOURCE_VOLUME/\@apptemp/$package_name /$DESTINATION_VOLUME/\@apptemp
    [ -e /$SOURCE_VOLUME/\@appdata/$package_name ] && mv /$SOURCE_VOLUME/\@appdata/$package_name /$DESTINATION_VOLUME/\@appdata

    ln -s /$DESTINATION_VOLUME/\@appconf/$package_name /var/packages/$package_name/etc
    ln -s /$DESTINATION_VOLUME/\@apphome/$package_name /var/packages/$package_name/home
    ln -s /$DESTINATION_VOLUME/\@appshare/$package_name /var/packages/$package_name/share
    ln -s /$DESTINATION_VOLUME/\@appstore/$package_name /var/packages/$package_name/target
    ln -s /$DESTINATION_VOLUME/\@apptemp/$package_name /var/packages/$package_name/tmp
    ln -s /$DESTINATION_VOLUME/\@appdata/$package_name /var/packages/$package_name/var
}

SOURCE_VOLUME='NONE'
DESTINATION_VOLUME='NONE'
PACKAGE_NAME='NONE'

opts=":s:d:p:h"
while getopts $opts option
do
    case ${option} in
        s) SOURCE_VOLUME=${OPTARG};;
        d) DESTINATION_VOLUME=${OPTARG};;
        p) PACKAGE_NAME=${OPTARG};;
        h) Help;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

if [ $SOURCE_VOLUME != 'NONE' ] && [ $DESTINATION_VOLUME != 'NONE' ]; then
    if [ $PACKAGE_NAME == 'ALL' ]; then
        MoveAllPackages
    fi

    if [ $PACKAGE_NAME != '' ] && [ -e /$SOURCE_VOLUME/\@appconf/$PACKAGE_NAME ]; then
        StopPackage $PACKAGE_NAME
        MovePackage $PACKAGE_NAME
        StartPackage $PACKAGE_NAME
    fi
else
    Help
fi
