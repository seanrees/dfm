#!/bin/sh
#
# Usage: install.sh [-isu]
#   -c: Install auto-update cron.
#   -i: Install files.
#   -p: Run git pull first.
#   -s: Include "secure" files as well.
#   -t: Timeout command after a few seconds.
#   -u: Update files in git.
#

# Base paths to install. These are affected by args.
paths="data"
mode="install"
pull="false"

# Useful parameters for the rest of the script.
cwd=$(pwd -P)
base="$(dirname ${cwd}/${0})/.."
hostname=$(hostname)
whoami="${USER}@${hostname}"
mypid=$$
tpid=

# Arg parsing.
args=$(getopt cipstu $*)
if [ $? != 0 ]; then
    echo "Usage: $0 [-s]"
    exit 2
fi
set -- $args

# Just in case we're on FreeBSD
PATH=${PATH}:/usr/local/bin

for i
do
    case "$i"
    in
        -c)
            mode="cron"
            shift;;
        -i)
            mode="install"
            shift;;
        -p)
            pull="true"
            shift;;
        -s)
            paths="${paths} secure"
            shift;;
        -t)
            (sleep 5; kill -9 ${mypid} 2>&1 >/dev/null) &
            tpid=$!
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
if [ "x${mode}" = "xcron" ]; then
    if [ ! -f ${HOME}/bin/dfm ]; then
        echo "Dotfile manager not installed. Run dfm -i."
        exit 3
    fi

    tmp=$(mktemp ${TMPDIR-/tmp}/dfm-cron-XXXXXX)
    crontab -l 2>/dev/null | grep -v bin/dfm >${tmp}

    cat <<EOF >> ${tmp}
*/5 * * * * $HOME/bin/dfm -ipt 2>&1 >/dev/null
EOF
    crontab ${tmp}
    rm -f ${tmp}
fi

if [ "x${mode}" = "xinstall" ]; then
    if [ "x${pull}" = "xtrue" ]; then
        git pull
    fi

    for path in ${paths}; do
        echo "Installing ${base}/${path}..."
        cd ${base}/${path}
        for dir in $(find . -type d); do
            mkdir -p ${HOME}/${dir}
        done
        for file in $(find . -type f); do
            cp -fp ${file} ${HOME}/${file}
        done
    done

    mkdir -p ${HOME}/bin
    cat <<EOF > ${HOME}/bin/dfm
#!/bin/sh
#Generated by ${whoami} on $(date)
cd ${cwd}
${0} \$*
EOF
    chmod +x ${HOME}/bin/dfm
fi

if [ "x${mode}" = "xupdate" ]; then
    for path in ${paths}; do
        cd ${base}/${path}

        for i in $(find . -type f); do
            cp -Rpf ${HOME}/${i} ${base}/${path}/${i}
        done

        cd ${base}
        git add --all ${path}

        cd ${cwd}
    done

    cd ${base}
    git commit -m "${whoami} ran ${mode} with paths: ${paths}"
    git push origin master
fi

# If we ran with a timeout, then kill the timeout watcher.
if [ "x${tpid}" != "x" ]; then
    kill -15 ${tpid}
fi
