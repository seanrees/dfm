#!/bin/sh
#
# Usage: install.sh [-isu]
#   -i: Install files.
#   -s: Include "secure" files as well.
#   -u: Update files in git.
#

# Base paths to install.
paths="data"
mode="install"

cwd=$(pwd -P)
base="$(dirname ${cwd}/${0})/.."

# Arg parsing.
args=$(getopt isu $*)
if [ $? != 0 ]; then
    echo "Usage: $0 [-s]"
    exit 2
fi
set -- $args

for i
do
    case "$i"
    in
        -i)
            mode="install"
            shift;;
        -s)
            paths="${paths} secure"
            shift;;
        -u)
            mode="update"
            shift;;
        --)
            shift;
            break;;
    esac
done

# Real work.
if [ "x${mode}" = "xinstall" ]; then
    for path in ${paths}
    do
        echo "Installing ${base}/${path}..."
        cp -Rpf ${base}/${path}/.* ${HOME}

        # In case there are non dot-files.
        if [ -f ${base}/${path}/* ]; then
            cp -Rpf ${base}/${path}/* ${HOME}
        fi
    done
fi

if [ "x${mode}" = "xupdate" ]; then
    echo "Not yet implemented."
fi
